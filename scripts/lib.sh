#!/usr/bin/env bash
# =============================================================================
# scripts/lib.sh
# -----------------------------------------------------------------------------
# Shared library sourced by install.sh, uninstall.sh, upgrade.sh,
# sync_claude.sh and sync_opencode.sh.
#
# This file contains NO top-level side effects other than function and
# variable definitions, so it is always safe to `source` it. All state
# directories are created lazily, inside functions, the first time they are
# actually needed.
#
# Design goals (see README.md "Safety guarantees" for the user-facing view):
#   * Never require root/sudo. Every path this library writes to lives under
#     the invoking user's HOME (or an explicit --project-dir the user chose).
#   * Never touch a directory this repo did not create. All writes go through
#     manifest_add()/manifest_remove() so uninstall/upgrade only ever remove
#     or replace entries this tool itself installed.
#   * Be idempotent: calling link_skill() twice with the same inputs is a
#     harmless no-op on the second call.
#   * Work the same way on Linux, macOS, and Windows (Git Bash / MSYS2 / WSL).
#
# IMPORTANT Claude Code compatibility note:
#   Older Claude Code releases (before v2.1.280) watched for a file literally
#   named `manifest.json` *inside* `~/.claude/skills/` and used its presence
#   to decide which skill folders to move into `~/.claude/skills/.trash/`.
#   To stay safe on every Claude Code version, this installer NEVER writes
#   any manifest file inside a tool's skills directory. All of this tool's
#   bookkeeping lives under a separate state directory (see state_dir()),
#   well outside `~/.claude/skills/` and `.claude/skills/`.
# =============================================================================

# ---- Guard against being executed directly (it must be sourced) -----------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "scripts/lib.sh is a library and must be sourced, not executed." >&2
  exit 2
fi

# ---- Constants --------------------------------------------------------------
# GitHub repository this installer manages. Override with AGENT_SKILLS_REPO
# for forks, and AGENT_SKILLS_REF for a specific branch/tag/commit.
AGENT_SKILLS_REPO="${AGENT_SKILLS_REPO:-pnguyen215/skills}"
AGENT_SKILLS_REF="${AGENT_SKILLS_REF:-master}"
AGENT_SKILLS_NAME="pnguyen215-skills"

# Exit codes (documented in each script's --help and in README.md).
EXIT_OK=0
EXIT_GENERIC=1
EXIT_USAGE=2
EXIT_PREREQ=3
EXIT_FS=4
EXIT_NETWORK=5

# Populated by parse_common_args(); scripts read these after calling it.
OPT_TOOL="all"          # claude | opencode | all
OPT_SCOPE="personal"    # personal | project | all
OPT_PROJECT_DIR=""      # resolved in resolve_project_dir()
OPT_MODE="auto"         # auto | symlink | copy
OPT_DRY_RUN="0"
OPT_YES="0"
OPT_SKILLS=""           # comma-separated allow-list, empty = all
OPT_VERBOSE="0"
OPT_REF="${AGENT_SKILLS_REF}"

# ---- Logging ----------------------------------------------------------------
# All logging goes to stderr so stdout can be reserved for machine-readable
# output in the future without breaking existing pipelines.
_c_reset=""; _c_red=""; _c_yellow=""; _c_green=""; _c_blue=""
if [[ -t 2 ]]; then
  _c_reset=$'\033[0m'; _c_red=$'\033[31m'; _c_yellow=$'\033[33m'
  _c_green=$'\033[32m'; _c_blue=$'\033[34m'
fi

log_info()  { printf '%s[info]%s  %s\n'  "${_c_blue}"   "${_c_reset}" "$*" >&2; }
log_warn()  { printf '%s[warn]%s  %s\n'  "${_c_yellow}" "${_c_reset}" "$*" >&2; }
log_err()   { printf '%s[error]%s %s\n'  "${_c_red}"    "${_c_reset}" "$*" >&2; }
log_ok()    { printf '%s[ok]%s    %s\n'  "${_c_green}"  "${_c_reset}" "$*" >&2; }
log_debug() { [[ "${OPT_VERBOSE}" == "1" ]] && printf '[debug] %s\n' "$*" >&2 || true; }

die() {
  local code="${2:-${EXIT_GENERIC}}"
  log_err "$1"
  exit "${code}"
}

# ---- OS detection -------------------------------------------------------------
# Sets OS_KIND to one of: linux, macos, windows-git-bash, windows-msys, wsl
# Windows-native cmd.exe/PowerShell are out of scope: this is a bash script,
# so it only ever runs under Git Bash, MSYS2, Cygwin, or WSL on Windows.
detect_os() {
  local uname_s
  uname_s="$(uname -s 2>/dev/null || echo unknown)"
  case "${uname_s}" in
    Linux*)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        OS_KIND="wsl"
      else
        OS_KIND="linux"
      fi
      ;;
    Darwin*) OS_KIND="macos" ;;
    MINGW*|MSYS*) OS_KIND="windows-git-bash" ;;
    CYGWIN*) OS_KIND="windows-msys" ;;
    *) OS_KIND="unknown" ;;
  esac
  log_debug "Detected OS_KIND=${OS_KIND} (uname -s: ${uname_s})"
  export OS_KIND
}

is_windows_like() {
  [[ "${OS_KIND}" == windows-* ]]
}

# ---- Prerequisite checks ----------------------------------------------------
have_cmd() { command -v "$1" >/dev/null 2>&1; }

require_cmd() {
  have_cmd "$1" || die "Required command '$1' was not found on PATH. ${2:-}" "${EXIT_PREREQ}"
}

# At least one of git or curl/wget is required to fetch the repository
# content when this script is run via the remote one-liner (curl | bash).
check_fetch_prereqs() {
  if have_cmd git; then
    return 0
  fi
  if have_cmd curl || have_cmd wget; then
    return 0
  fi
  die "None of 'git', 'curl', or 'wget' were found. Install one of them and retry." "${EXIT_PREREQ}"
}

# ---- Path helpers -------------------------------------------------------------
# Resolve $HOME in a way that behaves the same in Git Bash, WSL, macOS, Linux.
user_home() {
  printf '%s\n' "${HOME:?HOME is not set; cannot resolve a user-owned install path}"
}

xdg_config_home() { printf '%s\n' "${XDG_CONFIG_HOME:-$(user_home)/.config}"; }
xdg_data_home()   { printf '%s\n' "${XDG_DATA_HOME:-$(user_home)/.local/share}"; }
xdg_state_home()  { printf '%s\n' "${XDG_STATE_HOME:-$(user_home)/.local/state}"; }

# Directory where this tool keeps its own bookkeeping: the manifest and
# backups. Deliberately NOT inside ~/.claude/skills or .claude/skills -- see
# the Claude Code compatibility note at the top of this file.
state_dir() {
  local d
  d="$(xdg_state_home)/${AGENT_SKILLS_NAME}"
  mkdir -p "${d}/backups"
  printf '%s\n' "${d}"
}

# Directory holding the managed cache clone of the skills repository.
cache_dir() {
  local d
  d="$(xdg_data_home)/${AGENT_SKILLS_NAME}"
  mkdir -p "${d}"
  printf '%s\n' "${d}"
}

manifest_file() { printf '%s/manifest.tsv' "$(state_dir)"; }
source_conf_file() { printf '%s/source.conf' "$(state_dir)"; }

# Resolve the project directory used for --scope project / --scope all.
# Defaults to the current working directory. Accepts --project-dir to
# override. Always resolved to an absolute path so later runs (from a
# different cwd) still find the same install.
resolve_project_dir() {
  local dir="${OPT_PROJECT_DIR:-$(pwd)}"
  ( cd "${dir}" 2>/dev/null && pwd ) || die "Cannot resolve --project-dir '${dir}'" "${EXIT_USAGE}"
}

# skills_root_for TOOL SCOPE PROJECT_DIR
# Prints the absolute path of the skills directory for one (tool, scope)
# pair. This is the ONLY function in the whole codebase that is allowed to
# know these paths, so changing a path later means changing it in one place.
skills_root_for() {
  local tool="$1" scope="$2" project_dir="$3"
  case "${tool}:${scope}" in
    claude:personal)   printf '%s/.claude/skills\n' "$(user_home)" ;;
    claude:project)     printf '%s/.claude/skills\n' "${project_dir}" ;;
    opencode:personal) printf '%s/opencode/skills\n' "$(xdg_config_home)" ;;
    opencode:project)   printf '%s/.opencode/skills\n' "${project_dir}" ;;
    *) die "Internal error: unknown tool/scope pair '${tool}:${scope}'" "${EXIT_GENERIC}" ;;
  esac
}

# Expand "all" into the concrete list(s) this run should act on.
expand_tools() {
  case "${OPT_TOOL}" in
    all) printf 'claude\nopencode\n' ;;
    claude|opencode) printf '%s\n' "${OPT_TOOL}" ;;
    *) die "Invalid --tool '${OPT_TOOL}' (expected claude|opencode|all)" "${EXIT_USAGE}" ;;
  esac
}

expand_scopes() {
  case "${OPT_SCOPE}" in
    all) printf 'personal\nproject\n' ;;
    personal|project) printf '%s\n' "${OPT_SCOPE}" ;;
    *) die "Invalid --scope '${OPT_SCOPE}' (expected personal|project|all)" "${EXIT_USAGE}" ;;
  esac
}

# ---- Source resolution --------------------------------------------------------
# Decide where the canonical `skills/` content comes from, then make sure it
# is present and up to date. Two modes:
#   * "local"  - the script is being run from inside an existing clone
#                (a sibling `skills/` directory next to this script).
#   * "managed" - the script has no local `skills/` sibling (this is the
#                remote one-liner: curl | bash), so it clones/downloads the
#                repository into cache_dir() and manages it from there.
# Either way, the *absolute* path that was used is recorded in
# source_conf_file() so uninstall.sh and upgrade.sh (which may be invoked
# later, from a different directory or even after the local clone was
# deleted) can still find the right content.
#
# An EXISTING managed clone is refreshed on every call (best effort, never
# fatal) so a reinstall after an uninstall never reuses stale cached content.
resolve_source_dir() {
  local script_dir="$1"
  local candidate="${script_dir}/skills"

  if [[ -d "${candidate}" && -f "${script_dir}/README.md" ]]; then
    log_debug "Using local clone as source: ${script_dir}"
    printf '%s\n' "${script_dir}"
    return 0
  fi

  # Remote / piped execution: no usable local clone. Use (or create) the
  # managed cache clone instead.
  local managed
  managed="$(cache_dir)/repo"
  if [[ -d "${managed}/.git" ]]; then
    log_debug "Reusing existing managed clone: ${managed}"
    refresh_managed_clone "${managed}"
  elif [[ -d "${managed}/skills" ]]; then
    log_debug "Reusing existing managed download: ${managed}"
  else
    fetch_source_into "${managed}"
  fi
  printf '%s\n' "${managed}"
}

# fetch_source_into DEST
# Clones (preferred, enables `git pull` + `git log` later) or downloads a
# tarball of AGENT_SKILLS_REPO@OPT_REF into DEST. DEST's parent must already
# exist (cache_dir() creates it); DEST itself must NOT exist yet.
fetch_source_into() {
  local dest="$1"
  check_fetch_prereqs
  mkdir -p "$(dirname "${dest}")"

  if have_cmd git; then
    log_info "Cloning ${AGENT_SKILLS_REPO}@${OPT_REF} into ${dest} ..."
    git clone --quiet --branch "${OPT_REF}" --depth 1 \
      "https://github.com/${AGENT_SKILLS_REPO}.git" "${dest}" \
      || die "git clone failed for ${AGENT_SKILLS_REPO}@${OPT_REF}" "${EXIT_NETWORK}"
    return 0
  fi

  log_info "git not found; downloading a tarball of ${AGENT_SKILLS_REPO}@${OPT_REF} instead."
  local tmp_dl tmp_tar
  # BSD/macOS mktemp requires the XXXXXX at the very end, so create a temp
  # directory and put the archive inside it instead of using a suffix.
  tmp_dl="$(mktemp -d "${TMPDIR:-/tmp}/${AGENT_SKILLS_NAME}.XXXXXX")"
  tmp_tar="${tmp_dl}/source.tar.gz"
  local url="https://codeload.github.com/${AGENT_SKILLS_REPO}/tar.gz/refs/heads/${OPT_REF}"
  if have_cmd curl; then
    curl -fsSL "${url}" -o "${tmp_tar}" || die "curl download failed: ${url}" "${EXIT_NETWORK}"
  else
    wget -q "${url}" -O "${tmp_tar}" || die "wget download failed: ${url}" "${EXIT_NETWORK}"
  fi
  mkdir -p "${dest}"
  tar -xzf "${tmp_tar}" -C "${dest}" --strip-components=1 \
    || die "Failed to extract archive ${tmp_tar}" "${EXIT_FS}"
  rm -rf "${tmp_dl}"
}

# Record which absolute source directory this install run used, so a later
# upgrade/uninstall (possibly from a different shell session) uses the same
# one instead of guessing.
remember_source_dir() {
  local src="$1"
  mkdir -p "$(state_dir)"
  printf '%s\n' "${src}" > "$(source_conf_file)"
}

recall_source_dir() {
  local f
  f="$(source_conf_file)"
  [[ -f "${f}" ]] || return 1
  cat "${f}"
}

# ---- Source refresh helpers ---------------------------------------------------
# True when DIR is a shallow git clone. The tool's own cache clone is always
# created with --depth 1, so "shallow" identifies a disposable managed clone
# (as opposed to a full clone the user manages themselves).
is_shallow_clone() {
  local dir="$1"
  [[ -f "${dir}/.git/shallow" ]] && return 0
  [[ "$(git -C "${dir}" rev-parse --is-shallow-repository 2>/dev/null || echo false)" == "true" ]]
}

# sync_git_clone DIR MANAGED(0|1)
# Bring an existing git clone to OPT_REF.
# Return: 0 ok | 1 update failed | 2 could not fetch the ref (network / ref).
#
# managed=1 (shallow cache): fetch --depth 1, then a FORCED checkout of
#   `-B <ref> origin/<ref>`. No merge is involved, so it can never fail with
#   "refusing to merge unrelated histories" and it survives upstream
#   force-pushes.
# managed=0 (full clone): never add --depth (that would turn the user's clone
#   shallow) and never reset anything; only a plain fast-forward.
sync_git_clone() {
  local dir="$1" managed="$2"
  # Deliberately an unquoted string (not an array): empty arrays trip
  # `set -u` on the bash 3.2 that ships with macOS.
  local depth_flag=""
  [[ "${managed}" == "1" ]] && depth_flag="--depth 1"

  # shellcheck disable=SC2086
  if git -C "${dir}" fetch --quiet ${depth_flag} origin \
       "+refs/heads/${OPT_REF}:refs/remotes/origin/${OPT_REF}" 2>/dev/null; then
    if [[ "${managed}" == "1" ]]; then
      git -C "${dir}" checkout --quiet --force -B "${OPT_REF}" \
        "refs/remotes/origin/${OPT_REF}" 2>/dev/null || return 1
      # The managed clone is a disposable cache: drop stray untracked files so
      # it mirrors upstream exactly (a deleted skill must really disappear).
      git -C "${dir}" clean -fdq 2>/dev/null || true
    else
      git -C "${dir}" checkout --quiet "${OPT_REF}" 2>/dev/null \
        || git -C "${dir}" checkout --quiet -b "${OPT_REF}" "origin/${OPT_REF}" 2>/dev/null \
        || return 1
      git -C "${dir}" merge --ff-only --quiet "origin/${OPT_REF}" 2>/dev/null || return 1
    fi
  # shellcheck disable=SC2086
  elif git -C "${dir}" fetch --quiet ${depth_flag} origin \
       "+refs/tags/${OPT_REF}:refs/tags/${OPT_REF}" 2>/dev/null; then
    git -C "${dir}" checkout --quiet --force --detach "refs/tags/${OPT_REF}" 2>/dev/null \
      || return 1
  else
    return 2
  fi
  return 0
}

# Best-effort refresh of the managed cache clone. Never fatal: when offline we
# keep working with the cached copy. Full (user-managed) clones are not touched.
refresh_managed_clone() {
  local dir="$1" rc=0
  if ! is_shallow_clone "${dir}"; then
    return 0
  fi
  sync_git_clone "${dir}" 1 || rc=$?
  case "${rc}" in
    0) log_debug "Managed clone refreshed to ${OPT_REF}." ;;
    2) log_warn "Could not reach ${AGENT_SKILLS_REPO}@${OPT_REF}; using the cached copy." ;;
    *) log_warn "Could not update the managed clone in place; using the cached copy." ;;
  esac
  return 0
}

# Download a fresh copy and swap it in at DIR (same path, so symlinks that
# point into it stay valid). Also the fallback when an in-place git update of
# a managed clone fails.
refresh_by_download() {
  local source_dir="$1" tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/${AGENT_SKILLS_NAME}.upgrade.XXXXXX")" \
    || die "cannot create a temporary directory" "${EXIT_FS}"
  # fetch_source_into requires DEST to not exist yet.
  rmdir "${tmp}" 2>/dev/null || true
  fetch_source_into "${tmp}"
  [[ -d "${tmp}/skills" ]] \
    || { rm -rf "${tmp}"; die "downloaded source has no skills/ directory (${AGENT_SKILLS_REPO}@${OPT_REF})" "${EXIT_NETWORK}"; }

  # Report which skill slugs were added or removed.
  local old_list new_list
  old_list="$(mktemp)"; new_list="$(mktemp)"
  OPT_SKILLS="" list_available_skills "${source_dir}" 2>/dev/null | sort > "${old_list}" || true
  OPT_SKILLS="" list_available_skills "${tmp}" | sort > "${new_list}"
  log_info "Skill changes vs. previous managed copy:"
  comm -13 "${old_list}" "${new_list}" | sed 's/^/    + added: /'   >&2 || true
  comm -23 "${old_list}" "${new_list}" | sed 's/^/    - removed: /' >&2 || true
  rm -f "${old_list}" "${new_list}"

  rm -rf "${source_dir}"
  mv "${tmp}" "${source_dir}" \
    || die "failed to move the fresh copy into ${source_dir}" "${EXIT_FS}"
}

# refresh_source DIR
# Updates DIR to the latest OPT_REF and prints a short summary of what
# changed. Returns 0 even when there is nothing new (that is not an error),
# so callers always proceed to re-link afterwards.
refresh_source() {
  local source_dir="$1"

  if [[ ! -d "${source_dir}/.git" ]]; then
    log_info "No .git metadata at ${source_dir}; re-downloading a fresh tarball."
    refresh_by_download "${source_dir}"
    return 0
  fi

  log_info "Updating git clone at ${source_dir} ..."

  local managed=0
  if is_shallow_clone "${source_dir}"; then
    managed=1
  fi

  local before after rc=0
  before="$(git -C "${source_dir}" rev-parse HEAD 2>/dev/null || echo unknown)"

  sync_git_clone "${source_dir}" "${managed}" || rc=$?

  case "${rc}" in
    0) ;;
    2)
      die "git fetch failed for ${AGENT_SKILLS_REPO}@${OPT_REF} (network issue, or the ref does not exist)" "${EXIT_NETWORK}"
      ;;
    *)
      if [[ "${managed}" == "1" ]]; then
        log_warn "In-place update failed; replacing the managed clone with a fresh copy."
        refresh_by_download "${source_dir}"
        return 0
      fi
      die "could not fast-forward ${source_dir} to '${OPT_REF}'. This is a full clone you manage, so it was left untouched. Resolve it manually (e.g. 'git -C ${source_dir} pull --ff-only') or remove that directory and re-run." "${EXIT_GENERIC}"
      ;;
  esac

  after="$(git -C "${source_dir}" rev-parse HEAD 2>/dev/null || echo unknown)"
  if [[ "${before}" == "${after}" ]]; then
    log_info "Already up to date (${after})."
  else
    log_info "Updated ${before} -> ${after}."
    # In a shallow clone the old commit may be unreachable, so the change
    # list is best-effort and must never abort the run.
    if git -C "${source_dir}" diff --name-status "${before}" "${after}" >/dev/null 2>&1; then
      log_info "Changed files:"
      git -C "${source_dir}" diff --name-status "${before}" "${after}" 2>/dev/null \
        | sed 's/^/    /' >&2 || true
    else
      log_info "(detailed change list unavailable for a shallow clone)"
    fi
  fi
}

# ---- Skill discovery ----------------------------------------------------------
# Prints one skill slug per line for every skills/<slug>/SKILL.md under
# SOURCE_DIR, optionally filtered by OPT_SKILLS (comma-separated allow-list).
list_available_skills() {
  local source_dir="$1" slug d
  [[ -d "${source_dir}/skills" ]] || die "No 'skills/' directory found under ${source_dir}" "${EXIT_FS}"
  for d in "${source_dir}"/skills/*/; do
    [[ -f "${d}SKILL.md" ]] || continue
    slug="$(basename "${d}")"
    if [[ -n "${OPT_SKILLS}" ]]; then
      case ",${OPT_SKILLS}," in
        *",${slug},"*) printf '%s\n' "${slug}" ;;
      esac
    else
      printf '%s\n' "${slug}"
    fi
  done
}

# ---- Manifest ------------------------------------------------------------------
# Tab-separated: tool  scope  skill  target_path  source_path  mode  timestamp
# This file is the single source of truth for "what did this tool install",
# so uninstall/upgrade only ever act on rows found here.
manifest_add() {
  local tool="$1" scope="$2" skill="$3" target="$4" source="$5" mode="$6"
  local f ts
  f="$(manifest_file)"
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  manifest_remove_entry "${tool}" "${scope}" "${skill}" >/dev/null 2>&1 || true
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "${tool}" "${scope}" "${skill}" "${target}" "${source}" "${mode}" "${ts}" >> "${f}"
}

manifest_remove_entry() {
  local tool="$1" scope="$2" skill="$3" f tmp
  f="$(manifest_file)"
  [[ -f "${f}" ]] || return 0
  tmp="$(mktemp)"
  awk -F'\t' -v t="${tool}" -v s="${scope}" -v k="${skill}" \
    '!($1==t && $2==s && $3==k)' "${f}" > "${tmp}"
  mv "${tmp}" "${f}"
}

# manifest_rows [TOOL] [SCOPE]
# Prints matching manifest rows (all columns), filtered by tool/scope when
# those arguments are given and non-empty.
manifest_rows() {
  local tool="${1:-}" scope="${2:-}" f
  f="$(manifest_file)"
  [[ -f "${f}" ]] || return 0
  awk -F'\t' -v t="${tool}" -v s="${scope}" \
    '(t=="" || $1==t) && (s=="" || $2==s)' "${f}"
}

manifest_exists() {
  local f
  f="$(manifest_file)"
  [[ -f "${f}" && -s "${f}" ]]
}

# manifest_has TOOL SCOPE SKILL TARGET -> 0 when that exact row exists.
manifest_has() {
  local tool="$1" scope="$2" skill="$3" target="$4"
  manifest_rows "${tool}" "${scope}" \
    | awk -F'\t' -v k="${skill}" -v d="${target}" '$3==k && $4==d {f=1} END{exit !f}'
}

# manifest_mode_of TOOL SCOPE SKILL -> prints the recorded install mode.
manifest_mode_of() {
  local tool="$1" scope="$2" skill="$3"
  manifest_rows "${tool}" "${scope}" \
    | awk -F'\t' -v k="${skill}" '$3==k {print $6; exit}'
}

# Distinct "tool<TAB>scope<TAB>skills_root" triples recorded in the manifest.
manifest_roots() {
  local t s k target _rest
  manifest_rows | while IFS=$'\t' read -r t s k target _rest; do
    [[ -n "${t}" ]] || continue
    printf '%s\t%s\t%s\n' "${t}" "${s}" "$(dirname "${target}")"
  done | sort -u
}

# ---- Backups --------------------------------------------------------------------
# Move an existing, non-managed path out of the way before this tool
# overwrites it, so the user can always get their original content back.
backup_path() {
  local path="$1" tool="$2" scope="$3" skill="$4"
  local stamp dest
  stamp="$(date -u +%Y%m%dT%H%M%SZ)"
  dest="$(state_dir)/backups/${stamp}/${tool}-${scope}/${skill}"
  mkdir -p "$(dirname "${dest}")"
  mv "${path}" "${dest}"
  log_warn "Backed up pre-existing '${path}' to '${dest}' before replacing it."
  printf '%s\n' "${dest}"
}

# ---- Link / copy one skill ------------------------------------------------------
# link_skill SKILL SOURCE_DIR TARGET_ROOT TOOL SCOPE
# Installs (idempotently) one skill into TARGET_ROOT/SKILL, as a symlink to
# SOURCE_DIR/skills/SKILL (preferred) or a plain copy (--mode copy, or
# automatic fallback when symlinking is not possible, e.g. unprivileged
# Windows without Developer Mode).
#
# Trade-off (documented again in README.md):
#   * symlink: zero duplication, upgrade.sh instantly reflects new content
#     because the link always points at the latest pulled source. Requires
#     filesystem symlink support; on Windows this needs Developer Mode or
#     an elevated shell, which this tool deliberately never requests.
#   * copy: always works, but upgrade.sh must re-copy changed files, and a
#     local edit inside the installed copy will NOT reach the managed
#     source (and will be silently overwritten on upgrade).
link_skill() {
  local skill="$1" source_dir="$2" target_root="$3" tool="$4" scope="$5"
  local src="${source_dir}/skills/${skill}"
  local target="${target_root}/${skill}"

  [[ -d "${src}" ]] || die "Skill '${skill}' does not exist under ${source_dir}/skills" "${EXIT_USAGE}"

  if [[ "${OPT_DRY_RUN}" == "1" ]]; then
    log_info "[dry-run] would install '${skill}' -> ${target} (tool=${tool} scope=${scope} mode=${OPT_MODE})"
    return 0
  fi

  mkdir -p "${target_root}"

  # Idempotency: if target is already exactly what we'd create, skip.
  if [[ -L "${target}" ]]; then
    local current
    current="$(readlink "${target}")"
    if [[ "${current}" == "${src}" ]]; then
      log_debug "Skill '${skill}' already correctly symlinked for ${tool}/${scope}; skipping."
      manifest_add "${tool}" "${scope}" "${skill}" "${target}" "${src}" "symlink"
      return 0
    fi
  fi

  # Conflict handling: something is already at target and it is not one of
  # our own entries (or it points somewhere else) -> back it up first.
  if [[ -e "${target}" || -L "${target}" ]]; then
    local already_ours="0"
    if manifest_rows "${tool}" "${scope}" | awk -F'\t' -v k="${skill}" '$3==k{found=1} END{exit !found}'; then
      already_ours="1"
    fi
    if [[ "${already_ours}" == "1" ]]; then
      rm -rf "${target}"
    else
      backup_path "${target}" "${tool}" "${scope}" "${skill}" >/dev/null
    fi
  fi

  local used_mode="${OPT_MODE}"
  if [[ "${used_mode}" == "auto" ]]; then
    if ln -s "${src}" "${target}" 2>/dev/null; then
      used_mode="symlink"
    else
      used_mode="copy"
    fi
  elif [[ "${used_mode}" == "symlink" ]]; then
    ln -s "${src}" "${target}" || die "Failed to create symlink ${target} -> ${src} (try --mode copy on this filesystem)" "${EXIT_FS}"
  fi

  if [[ "${used_mode}" == "copy" ]]; then
    cp -R "${src}" "${target}" || die "Failed to copy ${src} -> ${target}" "${EXIT_FS}"
  fi

  manifest_add "${tool}" "${scope}" "${skill}" "${target}" "${src}" "${used_mode}"
  log_ok "Installed '${skill}' for ${tool}/${scope} (${used_mode}) -> ${target}"
}

# link_skill_keep_mode SKILL SOURCE_DIR TARGET_ROOT TOOL SCOPE RECORDED_MODE
# Same as link_skill, but when --mode was left at "auto" it re-uses the mode
# the skill was originally installed with (so a copy-mode install stays a
# copy-mode install after an upgrade). An explicit --mode always wins.
link_skill_keep_mode() {
  local skill="$1" source_dir="$2" target_root="$3" tool="$4" scope="$5" recorded="${6:-}"
  local orig_mode="${OPT_MODE}"
  if [[ "${orig_mode}" == "auto" ]]; then
    case "${recorded}" in
      copy|symlink) OPT_MODE="${recorded}" ;;
    esac
  fi
  link_skill "${skill}" "${source_dir}" "${target_root}" "${tool}" "${scope}"
  OPT_MODE="${orig_mode}"
}

# unlink_skill TOOL SCOPE SKILL TARGET
# Removes exactly one manifest-tracked skill installation. Refuses to touch
# anything not recorded in the manifest.
unlink_skill() {
  local tool="$1" scope="$2" skill="$3" target="$4"

  if [[ "${OPT_DRY_RUN}" == "1" ]]; then
    log_info "[dry-run] would remove '${skill}' from ${tool}/${scope} (${target})"
    return 0
  fi

  if [[ -L "${target}" || -e "${target}" ]]; then
    rm -rf "${target}"
    log_ok "Removed '${skill}' from ${tool}/${scope} (${target})"
  else
    log_warn "'${target}' was already gone; cleaning up manifest entry only."
  fi
  manifest_remove_entry "${tool}" "${scope}" "${skill}"
}

# ---- Upgrade / sync helpers -----------------------------------------------------
# Absolute source directories this tool may have linked skills from.
managed_source_dirs() {
  (
    recall_source_dir 2>/dev/null || true
    printf '%s\n' "$(cache_dir)/repo"
    manifest_rows | awk -F'\t' '{print $5}' | sed 's#/skills/[^/]*$##'
  ) | sort -u
}

# is_tool_link PATH [EXTRA_SOURCE_DIR]
# True when PATH is a symlink that points into <some managed source>/skills/,
# i.e. a link this tool created, whether or not the manifest still lists it.
is_tool_link() {
  local path="$1" extra="${2:-}" dest src
  [[ -L "${path}" ]] || return 1
  dest="$(readlink "${path}")"
  if [[ -n "${extra}" ]]; then
    case "${dest}" in "${extra}/skills/"*) return 0 ;; esac
  fi
  while IFS= read -r src; do
    [[ -n "${src}" ]] || continue
    case "${dest}" in "${src}/skills/"*) return 0 ;; esac
  done < <(managed_source_dirs)
  return 1
}

# Prints symlinks inside ROOT that point into SOURCE_DIR/skills (i.e. links
# created by this tool), whether or not the manifest still knows about them.
find_untracked_links() {
  local root="$1" source_dir="$2" entry dest
  [[ -d "${root}" ]] || return 0
  for entry in "${root}"/*; do
    [[ -L "${entry}" ]] || continue
    dest="$(readlink "${entry}")"
    case "${dest}" in
      "${source_dir}/skills/"*) printf '%s\n' "${entry}" ;;
    esac
  done
}

# Install skills that exist upstream but are not yet installed, for every
# (tool, scope, root) the user already installed into. Honours --tool, --scope
# and --skills. Never overwrites a pre-existing directory this tool did not
# create. Sets SYNC_ADDED to the number of newly installed skills.
SYNC_ADDED=0
sync_new_skills() {
  local source_dir="$1" added=0 t s root slug dest
  while IFS=$'\t' read -r t s root; do
    [[ -n "${t}" ]] || continue
    case "${OPT_TOOL}" in all|"${t}") ;; *) continue ;; esac
    case "${OPT_SCOPE}" in all|"${s}") ;; *) continue ;; esac
    while IFS= read -r slug; do
      [[ -n "${slug}" ]] || continue
      dest="${root}/${slug}"
      if manifest_has "${t}" "${s}" "${slug}" "${dest}"; then
        continue
      fi
      if [[ -e "${dest}" || -L "${dest}" ]]; then
        log_warn "New skill '${slug}' skipped for ${t}/${s}: ${dest} already exists and was not installed by this tool."
        continue
      fi
      link_skill "${slug}" "${source_dir}" "${root}" "${t}" "${s}"
      added=$((added + 1))
    done < <(list_available_skills "${source_dir}")
  done < <(manifest_roots)
  SYNC_ADDED="${added}"
}

# sync_tool_skills TOOL SOURCE_DIR PRUNE(0|1)
# Make TOOL's skills directory(ies) mirror SOURCE_DIR/skills for every
# --scope selected:
#   * skills already tracked in the manifest are refreshed (mode preserved),
#   * skills that are new upstream are installed,
#   * a leftover symlink into this tool's source clone is adopted,
#   * a pre-existing directory this tool did NOT create is never touched,
#   * with PRUNE=1, tracked skills that no longer exist upstream are removed,
#     together with dangling links into the managed clone.
sync_tool_skills() {
  local tool="$1" source_dir="$2" prune="${3:-1}"
  local project_dir scope root slug dest entry
  local installed=0 refreshed=0 skipped=0 pruned=0
  local wanted all_upstream rec_mode
  local r_tool r_scope r_skill r_target r_source r_mode r_ts

  project_dir="$(resolve_project_dir)"
  wanted="$(list_available_skills "${source_dir}")"
  all_upstream="$(OPT_SKILLS="" list_available_skills "${source_dir}")"
  [[ -n "${all_upstream}" ]] \
    || die "No skills found upstream under ${source_dir}/skills" "${EXIT_FS}"

  while IFS= read -r scope; do
    root="$(skills_root_for "${tool}" "${scope}" "${project_dir}")"
    log_info "Syncing ${tool}/${scope} -> ${root}"

    while IFS= read -r slug; do
      [[ -n "${slug}" ]] || continue
      dest="${root}/${slug}"
      if manifest_has "${tool}" "${scope}" "${slug}" "${dest}"; then
        rec_mode="$(manifest_mode_of "${tool}" "${scope}" "${slug}")"
        link_skill_keep_mode "${slug}" "${source_dir}" "${root}" "${tool}" "${scope}" "${rec_mode}"
        refreshed=$((refreshed + 1))
      elif [[ -L "${dest}" ]] && is_tool_link "${dest}" "${source_dir}"; then
        # Our own symlink that lost its manifest row: adopt it.
        [[ "${OPT_DRY_RUN}" == "1" ]] || rm -f "${dest}"
        link_skill "${slug}" "${source_dir}" "${root}" "${tool}" "${scope}"
        installed=$((installed + 1))
      elif [[ -e "${dest}" || -L "${dest}" ]]; then
        log_warn "Skipped '${slug}' for ${tool}/${scope}: ${dest} exists and was not installed by this tool."
        skipped=$((skipped + 1))
      else
        link_skill "${slug}" "${source_dir}" "${root}" "${tool}" "${scope}"
        installed=$((installed + 1))
      fi
    done <<< "${wanted}"

    if [[ "${prune}" == "1" ]]; then
      # Tracked skills that no longer exist upstream.
      while IFS=$'\t' read -r r_tool r_scope r_skill r_target r_source r_mode r_ts; do
        [[ -n "${r_tool:-}" ]] || continue
        if [[ -n "${OPT_SKILLS}" ]]; then
          case ",${OPT_SKILLS}," in *",${r_skill},"*) ;; *) continue ;; esac
        fi
        case $'\n'"${all_upstream}"$'\n' in
          *$'\n'"${r_skill}"$'\n'*) continue ;;
        esac
        log_info "Skill '${r_skill}' was removed upstream; removing it from ${tool}/${scope}."
        unlink_skill "${r_tool}" "${r_scope}" "${r_skill}" "${r_target}"
        pruned=$((pruned + 1))
      done < <(manifest_rows "${tool}" "${scope}")

      # Dangling links into the managed clone (skill deleted upstream).
      if [[ -d "${root}" ]]; then
        for entry in "${root}"/*; do
          [[ -L "${entry}" ]] || continue
          [[ -e "${entry}" ]] && continue
          is_tool_link "${entry}" "${source_dir}" || continue
          if [[ "${OPT_DRY_RUN}" == "1" ]]; then
            log_info "[dry-run] would remove dangling link '${entry}'"
          else
            rm -f "${entry}"
            log_ok "Removed dangling link '${entry}'"
          fi
          pruned=$((pruned + 1))
        done
      fi
    fi
  done < <(expand_scopes)

  log_ok "Sync (${tool}) done: ${installed} installed, ${refreshed} refreshed, ${pruned} pruned, ${skipped} skipped."
}

print_sync_help() {
  local tool="$1"
  cat <<EOF
sync_${tool}.sh - make ${tool}'s skills directory mirror the latest skills.

USAGE
  ./sync_${tool}.sh [options]
  curl -fsSL https://raw.githubusercontent.com/${AGENT_SKILLS_REPO}/${AGENT_SKILLS_REF}/sync_${tool}.sh | bash -s -- [options]

What it does
  1. Pulls the latest content of ${AGENT_SKILLS_REPO}@${AGENT_SKILLS_REF}.
  2. Installs every skill that is new upstream.
  3. Refreshes skills already installed (symlink/copy mode is preserved).
  4. Removes skills deleted upstream and dangling links (disable: --no-prune).
  Pre-existing folders that this tool did not create are never touched.

$(print_common_help_options)

ADDITIONAL OPTIONS
  --no-prune   Do not remove skills that were deleted upstream.

Note: --tool is fixed to '${tool}' for this script. Restart your ${tool}
session afterwards so it reloads the skills directory.
EOF
}

# sync_main TOOL [args...]
# Entry point used by sync_claude.sh / sync_opencode.sh.
sync_main() {
  local tool="$1"
  shift
  local prune=1 args=() i

  REMAINING_ARGS=()
  parse_common_args "$@"
  args=("${REMAINING_ARGS[@]:-}")
  REMAINING_ARGS=()
  for ((i = 0; i < ${#args[@]}; i++)); do
    case "${args[$i]:-}" in
      --no-prune) prune=0 ;;
      "") : ;;
      *) REMAINING_ARGS+=("${args[$i]}") ;;
    esac
  done

  if [[ "${#REMAINING_ARGS[@]}" -gt 0 && "${REMAINING_ARGS[0]:-}" == "--help" ]]; then
    print_sync_help "${tool}"
    exit "${EXIT_OK}"
  fi
  if [[ "${#REMAINING_ARGS[@]}" -gt 0 ]]; then
    die "Unknown argument(s): ${REMAINING_ARGS[*]}" "${EXIT_USAGE}"
  fi

  OPT_TOOL="${tool}"
  validate_common_args
  detect_os
  check_fetch_prereqs

  local source_dir
  if source_dir="$(recall_source_dir)" && [[ -d "${source_dir}/skills" ]]; then
    log_debug "Reusing recorded source directory: ${source_dir}"
  else
    source_dir="$(resolve_source_dir "${SCRIPT_DIR}")"
  fi

  if [[ "${OPT_DRY_RUN}" == "1" ]]; then
    log_info "[dry-run] would refresh ${source_dir} to '${OPT_REF}' and sync ${tool} (scope=${OPT_SCOPE})."
  else
    refresh_source "${source_dir}"
  fi

  sync_tool_skills "${tool}" "${source_dir}" "${prune}"

  if [[ "${OPT_DRY_RUN}" != "1" ]]; then
    remember_source_dir "${source_dir}"
  fi
  log_info "Restart your ${tool} session so it reloads the skills directory."
}

# ---- Confirmation -----------------------------------------------------------
confirm() {
  local prompt="$1" reply=""
  if [[ "${OPT_YES}" == "1" ]]; then
    return 0
  fi
  if [[ -t 0 ]]; then
    read -r -p "${prompt} [y/N] " reply
  elif ( : < /dev/tty ) 2>/dev/null; then
    # stdin is a pipe (curl | bash) but a terminal exists: ask on the terminal.
    printf '%s [y/N] ' "${prompt}" >&2
    read -r reply < /dev/tty || reply=""
  else
    # Truly non-interactive (CI, cron): refuse to guess.
    die "Refusing to proceed without --yes in a non-interactive shell. Re-run with --yes." "${EXIT_USAGE}"
  fi
  case "${reply}" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

# ---- Shared argument parsing --------------------------------------------------
# Each script calls this first, then checks for any script-specific flags it
# adds on top. Keeping parsing in one place guarantees the scripts never drift
# into accepting different flag names.
print_common_help_options() {
  cat <<'EOF'
Common options (all scripts accept these):
  --tool <claude|opencode|all>   Which tool(s) to target. Default: all
  --scope <personal|project|all> Install scope. Default: personal
  --project-dir <path>           Project root for --scope project/all. Default: current directory
  --mode <auto|symlink|copy>     How to place skill content. Default: auto
  --skills <a,b,c>                Only act on these skill slugs (comma-separated). Default: all
  --ref <git-ref>                 Branch/tag to use for remote fetch/upgrade. Default: master
  --dry-run                       Print what would happen; change nothing
  -y, --yes                       Assume "yes" to prompts (required for non-interactive use)
  -v, --verbose                   Print debug-level log lines
  -h, --help                      Show this help and exit
EOF
}

parse_common_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --tool) OPT_TOOL="${2:?--tool requires a value}"; shift 2 ;;
      --tool=*) OPT_TOOL="${1#*=}"; shift ;;
      --scope) OPT_SCOPE="${2:?--scope requires a value}"; shift 2 ;;
      --scope=*) OPT_SCOPE="${1#*=}"; shift ;;
      --project-dir) OPT_PROJECT_DIR="${2:?--project-dir requires a value}"; shift 2 ;;
      --project-dir=*) OPT_PROJECT_DIR="${1#*=}"; shift ;;
      --mode) OPT_MODE="${2:?--mode requires a value}"; shift 2 ;;
      --mode=*) OPT_MODE="${1#*=}"; shift ;;
      --skills) OPT_SKILLS="${2:?--skills requires a value}"; shift 2 ;;
      --skills=*) OPT_SKILLS="${1#*=}"; shift ;;
      --ref) OPT_REF="${2:?--ref requires a value}"; shift 2 ;;
      --ref=*) OPT_REF="${1#*=}"; shift ;;
      --dry-run) OPT_DRY_RUN="1"; shift ;;
      -y|--yes) OPT_YES="1"; shift ;;
      -v|--verbose) OPT_VERBOSE="1"; shift ;;
      -h|--help) REMAINING_ARGS=("--help"); return 0 ;;
      --) shift; REMAINING_ARGS+=("$@"); break ;;
      *)
        REMAINING_ARGS+=("$1")
        shift
        ;;
    esac
  done
}

validate_common_args() {
  case "${OPT_TOOL}" in claude|opencode|all) ;; *) die "Invalid --tool '${OPT_TOOL}'" "${EXIT_USAGE}" ;; esac
  case "${OPT_SCOPE}" in personal|project|all) ;; *) die "Invalid --scope '${OPT_SCOPE}'" "${EXIT_USAGE}" ;; esac
  case "${OPT_MODE}" in auto|symlink|copy) ;; *) die "Invalid --mode '${OPT_MODE}'" "${EXIT_USAGE}" ;; esac
}