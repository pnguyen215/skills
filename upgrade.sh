#!/usr/bin/env bash
# =============================================================================
# upgrade.sh
# -----------------------------------------------------------------------------
# PURPOSE
#   Update the skills this tool manages to the latest content for the
#   configured ref (default: the master branch), then re-link/re-copy only
#   the skills recorded in the manifest. Skills you never installed are left
#   untouched; a skill that was removed from the upstream repository is
#   flagged, not silently deleted (removing it is uninstall.sh's job, so
#   that destructive action always requires an explicit, separate command).
#
# USAGE
#   Local, after cloning:
#     ./upgrade.sh [options]
#
#   Remote one-liner:
#     curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/upgrade.sh \
#       | bash -s -- [options]
#
# OPTIONS
#   See `./upgrade.sh --help`. Accepts the same filters as install.sh so you
#   can upgrade only one tool/scope/skill subset. `--ref` lets you move the
#   managed clone to a different branch or tag.
#
# EXIT CODES
#   0 success | 1 generic failure | 2 invalid usage | 3 missing prerequisite
#   4 filesystem error | 5 network error
#
# SAFETY
#   * The tool-managed cache clone is shallow (--depth 1). Such a clone is
#     treated as a disposable cache: it is synced to upstream with a forced
#     checkout (no merge, so shallow/unrelated-history and force-pushed
#     upstreams can never break the upgrade). If an in-place update fails for
#     any reason, a fresh copy is downloaded and swapped in at the SAME path,
#     so existing symlinks stay valid.
#   * A full (non-shallow) clone -- e.g. one you manage yourself -- is never
#     rewritten: it only gets a plain fast-forward, and is never deleted.
#   * Only re-links skills that are already in the manifest (i.e. that you
#     installed before) -- it does not silently install new skills that
#     were added upstream since your last install. Run install.sh again
#     (optionally with --skills) to pick up new skills.
#   * Idempotent: running it with no upstream changes is a harmless no-op.
# =============================================================================
set -euo pipefail

# -----------------------------------------------------------------------------
# Locate scripts/lib.sh.
#
# * Normal run (./install.sh, bash install.sh): BASH_SOURCE[0] is this file, so
#   lib.sh sits next to it in scripts/.
# * Remote run (curl ... | bash -s -- ...): bash reads the script from STDIN.
#   There is no file on disk, BASH_SOURCE is empty (referencing [0] under
#   `set -u` is an "unbound variable" error) and scripts/lib.sh does not exist
#   locally. In that case we download ONLY lib.sh into a throw-away temp dir.
#   The skill content itself is later cloned into a persistent cache directory
#   by resolve_source_dir(), so nothing installed ever points at the temp dir.
#
# Optional overrides: AGENT_SKILLS_REPO, AGENT_SKILLS_REF, AGENT_SKILLS_LIB_URL
# -----------------------------------------------------------------------------
_self="${BASH_SOURCE[0]:-}"
if [[ -n "${_self}" && -f "${_self}" && -f "$(dirname "${_self}")/scripts/lib.sh" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${_self}")" >/dev/null 2>&1 && pwd)"
else
  SCRIPT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/pnguyen215-skills.XXXXXX")" \
    || { echo "[error] cannot create a temporary directory" >&2; exit 4; }
  trap 'rm -rf "${SCRIPT_DIR}"' EXIT
  mkdir -p "${SCRIPT_DIR}/scripts"
  _lib_url="${AGENT_SKILLS_LIB_URL:-https://raw.githubusercontent.com/${AGENT_SKILLS_REPO:-pnguyen215/skills}/${AGENT_SKILLS_REF:-master}/scripts/lib.sh}"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "${_lib_url}" -o "${SCRIPT_DIR}/scripts/lib.sh" \
      || { echo "[error] failed to download ${_lib_url}" >&2; exit 5; }
  elif command -v wget >/dev/null 2>&1; then
    wget -q "${_lib_url}" -O "${SCRIPT_DIR}/scripts/lib.sh" \
      || { echo "[error] failed to download ${_lib_url}" >&2; exit 5; }
  else
    echo "[error] need curl or wget to run this script from a pipe" >&2
    exit 3
  fi
fi
unset _self _lib_url

REMAINING_ARGS=()
# shellcheck source=scripts/lib.sh
source "${SCRIPT_DIR}/scripts/lib.sh"

print_help() {
  cat <<EOF
upgrade.sh - update skills managed by this tool to the latest content.

USAGE
  ./upgrade.sh [options]
  curl -fsSL https://raw.githubusercontent.com/${AGENT_SKILLS_REPO}/${AGENT_SKILLS_REF}/upgrade.sh | bash -s -- [options]

$(print_common_help_options)

EXAMPLES
  # Pull the latest content and re-link everything this tool manages
  ./upgrade.sh --yes

  # Upgrade only the skills installed for OpenCode's project scope
  ./upgrade.sh --tool opencode --scope project
EOF
}

# -----------------------------------------------------------------------------
# is_shallow_clone <dir>
#   True when <dir> is a shallow git clone. The tool always creates its own
#   cache clone with --depth 1, so "shallow" is how we recognise a disposable,
#   tool-managed clone as opposed to a full clone the user manages themselves.
# -----------------------------------------------------------------------------
is_shallow_clone() {
  local dir="$1"
  [[ "$(git -C "${dir}" rev-parse --is-shallow-repository 2>/dev/null || echo false)" == "true" ]]
}

# -----------------------------------------------------------------------------
# sync_git_clone <dir> <managed:0|1>
#   Bring an existing git clone to OPT_REF.
#   Return codes: 0 ok | 1 update failed (clone may be damaged/diverged)
#                 2 could not fetch the ref from the remote (network/ref)
#
#   managed=1 (shallow cache): fetch --depth 1, then a FORCED checkout of
#     `-B <ref> origin/<ref>`. This resets the local branch and working tree to
#     upstream without needing any shared history, so it can never fail with
#     "refusing to merge unrelated histories" and survives upstream force-pushes.
#   managed=0 (full clone): never add --depth (that would turn the user's
#     clone shallow), never reset anything; only a plain fast-forward.
# -----------------------------------------------------------------------------
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

# -----------------------------------------------------------------------------
# refresh_by_download <dir>
#   Download a fresh copy of the source and swap it in at <dir> (same path, so
#   any symlinks recorded in the manifest remain valid). Also used as the
#   fallback when an in-place git update of a managed clone fails.
# -----------------------------------------------------------------------------
refresh_by_download() {
  local source_dir="$1"
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/${AGENT_SKILLS_NAME}.upgrade.XXXXXX")" \
    || die "cannot create a temporary directory" "${EXIT_FS}"
  fetch_source_into "${tmp}"
  [[ -d "${tmp}/skills" ]] \
    || { rm -rf "${tmp}"; die "downloaded source has no skills/ directory (${AGENT_SKILLS_REPO}@${OPT_REF})" "${EXIT_NETWORK}"; }

  # Report which skill slugs changed, added, or were removed, by comparing
  # the SKILL.md files of the old and new managed source.
  local old_list new_list
  old_list="$(mktemp)"; new_list="$(mktemp)"
  list_available_skills "${source_dir}" 2>/dev/null | sort > "${old_list}" || true
  list_available_skills "${tmp}" | sort > "${new_list}"
  log_info "Skill changes vs. previous managed copy:"
  comm -13 "${old_list}" "${new_list}" | sed 's/^/    + added: /'   >&2 || true
  comm -23 "${old_list}" "${new_list}" | sed 's/^/    - removed: /' >&2 || true
  rm -f "${old_list}" "${new_list}"

  rm -rf "${source_dir}"
  mv "${tmp}" "${source_dir}" \
    || die "failed to move the fresh copy into ${source_dir}" "${EXIT_FS}"
}

# Updates SOURCE_DIR in place and prints a short human-readable summary of
# what changed. Returns 0 even when there is nothing new (that is not an
# error), so the caller always proceeds to re-link afterwards.
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
    # In a shallow clone the old commit may no longer be reachable, so the
    # change list is best-effort and must never abort the upgrade.
    if git -C "${source_dir}" diff --name-status "${before}" "${after}" >/dev/null 2>&1; then
      log_info "Changed files:"
      git -C "${source_dir}" diff --name-status "${before}" "${after}" 2>/dev/null \
        | sed 's/^/    /' >&2 || true
    else
      log_info "(detailed change list unavailable for a shallow clone)"
    fi
  fi
}

main() {
  parse_common_args "$@"
  if [[ "${#REMAINING_ARGS[@]}" -gt 0 && "${REMAINING_ARGS[0]:-}" == "--help" ]]; then
    print_help
    exit "${EXIT_OK}"
  fi
  if [[ "${#REMAINING_ARGS[@]}" -gt 0 ]]; then
    die "Unknown argument(s): ${REMAINING_ARGS[*]}" "${EXIT_USAGE}"
  fi
  validate_common_args
  detect_os
  check_fetch_prereqs

  if ! manifest_exists; then
    log_warn "No manifest found; nothing to upgrade. Run install.sh first."
    exit "${EXIT_OK}"
  fi

  local source_dir
  if source_dir="$(recall_source_dir)" && [[ -d "${source_dir}" ]]; then
    log_debug "Reusing recorded source directory: ${source_dir}"
  else
    source_dir="$(resolve_source_dir "${SCRIPT_DIR}")"
  fi

  if [[ "${OPT_DRY_RUN}" == "1" ]]; then
    log_info "[dry-run] would refresh ${source_dir} to ref '${OPT_REF}' and re-link manifest entries."
    exit "${EXIT_OK}"
  fi

  refresh_source "${source_dir}"
  remember_source_dir "${source_dir}"

  local relinked=0
  while IFS= read -r tool; do
    while IFS= read -r scope; do
      while IFS=$'\t' read -r r_tool r_scope r_skill r_target r_source r_mode r_ts; do
        [[ -n "${r_tool:-}" ]] || continue
        if [[ -n "${OPT_SKILLS}" ]]; then
          case ",${OPT_SKILLS}," in
            *",${r_skill},"*) ;;
            *) continue ;;
          esac
        fi
        local target_root
        target_root="$(dirname "${r_target}")"
        if [[ ! -d "${source_dir}/skills/${r_skill}" ]]; then
          log_warn "Skill '${r_skill}' no longer exists upstream; leaving your installed copy as-is. Run uninstall.sh --skills ${r_skill} to remove it."
          continue
        fi
        link_skill "${r_skill}" "${source_dir}" "${target_root}" "${r_tool}" "${r_scope}"
        relinked=$((relinked + 1))
      done < <(manifest_rows "${tool}" "${scope}")
    done < <(expand_scopes)
  done < <(expand_tools)

  log_ok "Upgrade complete. ${relinked} installed skill(s) re-checked/re-linked."
}

main "$@"