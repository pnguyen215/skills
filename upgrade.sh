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
#   * Re-fetches content with `git pull` (preferred) or a fresh tarball
#     download; it never force-pushes or rewrites the managed clone's
#     history, and it never touches a *local* clone you manage yourself
#     (see scripts/lib.sh: resolve_source_dir()) beyond a plain `git pull`.
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

# Updates SOURCE_DIR in place and prints a short human-readable summary of
# what changed. Returns 0 even when there is nothing new (that is not an
# error), so the caller always proceeds to re-link afterwards.
refresh_source() {
  local source_dir="$1"
  if [[ -d "${source_dir}/.git" ]]; then
    log_info "Updating git clone at ${source_dir} ..."
    local before after
    before="$(git -C "${source_dir}" rev-parse HEAD 2>/dev/null || echo unknown)"
    # Explicit refspec: a plain `git fetch origin <ref>` does not create
    # origin/<ref> in a shallow single-branch clone, so the merge below would fail.
    if git -C "${source_dir}" fetch --quiet --depth 1 origin \
         "+refs/heads/${OPT_REF}:refs/remotes/origin/${OPT_REF}" 2>/dev/null; then
      git -C "${source_dir}" checkout --quiet "${OPT_REF}" 2>/dev/null \
        || git -C "${source_dir}" checkout --quiet -b "${OPT_REF}" "origin/${OPT_REF}" \
        || die "git checkout of '${OPT_REF}' failed in ${source_dir}" "${EXIT_GENERIC}"
      git -C "${source_dir}" merge --ff-only --quiet "origin/${OPT_REF}" \
        || die "git fast-forward failed; resolve manually in ${source_dir}" "${EXIT_GENERIC}"
    elif git -C "${source_dir}" fetch --quiet --depth 1 origin \
         "+refs/tags/${OPT_REF}:refs/tags/${OPT_REF}" 2>/dev/null; then
      git -C "${source_dir}" checkout --quiet --detach "refs/tags/${OPT_REF}" \
        || die "git checkout of tag '${OPT_REF}' failed in ${source_dir}" "${EXIT_GENERIC}"
    else
      die "git fetch failed for ${AGENT_SKILLS_REPO}@${OPT_REF}" "${EXIT_NETWORK}"
    fi
    after="$(git -C "${source_dir}" rev-parse HEAD 2>/dev/null || echo unknown)"
    if [[ "${before}" == "${after}" ]]; then
      log_info "Already up to date (${after})."
    else
      log_info "Updated ${before} -> ${after}. Changed files:"
      git -C "${source_dir}" diff --name-status "${before}" "${after}" | sed 's/^/    /' >&2
    fi
  else
    log_info "No .git metadata at ${source_dir}; re-downloading a fresh tarball."
    local tmp
    tmp="$(mktemp -d "${TMPDIR:-/tmp}/${AGENT_SKILLS_NAME}.upgrade.XXXXXX")"
    fetch_source_into "${tmp}"
    # Report which skill slugs changed, added, or were removed, by comparing
    # the SKILL.md files of the old and new managed source.
    local old_list new_list
    old_list="$(mktemp)"; new_list="$(mktemp)"
    list_available_skills "${source_dir}" | sort > "${old_list}" 2>/dev/null || true
    list_available_skills "${tmp}" | sort > "${new_list}"
    log_info "Skill changes vs. previous managed copy:"
    comm -13 "${old_list}" "${new_list}" | sed 's/^/    + added: /'   >&2 || true
    comm -23 "${old_list}" "${new_list}" | sed 's/^/    - removed: /' >&2 || true
    rm -f "${old_list}" "${new_list}"
    rm -rf "${source_dir}"
    mv "${tmp}" "${source_dir}"
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