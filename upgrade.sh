#!/usr/bin/env bash
# =============================================================================
# upgrade.sh
# -----------------------------------------------------------------------------
# PURPOSE
#   Update the skills this tool manages to the latest content for the
#   configured ref (default: the master branch), then bring every tool's
#   skills directory in sync with it:
#     * re-link/re-copy every skill recorded in the manifest (keeping the mode
#       it was installed with: symlink or copy),
#     * install skills that were ADDED upstream since your last install, into
#       the same tool/scope directories you already use (disable: --no-new),
#     * flag (never delete) skills that were removed upstream; removing them is
#       uninstall.sh's job (or use sync_claude.sh / sync_opencode.sh, which
#       mirror upstream exactly).
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
#   See `./upgrade.sh --help`. Accepts the same filters as install.sh.
#   --no-new   Do not install skills that are new upstream; only refresh the
#              ones already installed.
#
# EXIT CODES
#   0 success | 1 generic failure | 2 invalid usage | 3 missing prerequisite
#   4 filesystem error | 5 network error
#
# SAFETY
#   * The tool-managed cache clone is shallow (--depth 1) and treated as a
#     disposable cache: it is synced to upstream with a forced checkout (no
#     merge). If that fails, a fresh copy is downloaded and swapped in at the
#     SAME path, so existing symlinks stay valid.
#   * A full (non-shallow) clone you manage yourself is never rewritten: it
#     only gets a plain fast-forward, and is never deleted.
#   * New upstream skills never overwrite a directory this tool did not create.
#   * Idempotent: running it with no upstream changes is a harmless no-op.
# =============================================================================
set -euo pipefail

# -----------------------------------------------------------------------------
# Locate scripts/lib.sh.
#
# * Normal run (./upgrade.sh, bash upgrade.sh): BASH_SOURCE[0] is this file, so
#   lib.sh sits next to it in scripts/.
# * Remote run (curl ... | bash -s -- ...): bash reads the script from STDIN.
#   There is no file on disk, so we download ONLY lib.sh into a throw-away temp
#   dir. The skill content itself lives in a persistent cache directory managed
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
OPT_NO_NEW="0"
# shellcheck source=scripts/lib.sh
source "${SCRIPT_DIR}/scripts/lib.sh"

print_help() {
  cat <<EOF
upgrade.sh - update skills managed by this tool to the latest content.

USAGE
  ./upgrade.sh [options]
  curl -fsSL https://raw.githubusercontent.com/${AGENT_SKILLS_REPO}/${AGENT_SKILLS_REF}/upgrade.sh | bash -s -- [options]

$(print_common_help_options)

ADDITIONAL OPTIONS
  --no-new  Only refresh skills that are already installed; do not install
            skills that were added upstream since your last install.

EXAMPLES
  # Pull the latest content, refresh installed skills, install new ones
  ./upgrade.sh --yes

  # Upgrade only the skills installed for OpenCode's project scope
  ./upgrade.sh --tool opencode --scope project
EOF
}

parse_upgrade_args() {
  local args=() i
  parse_common_args "$@"
  # parse_common_args() doesn't know script-specific flags; re-scan leftovers.
  args=("${REMAINING_ARGS[@]:-}")
  REMAINING_ARGS=()
  for ((i = 0; i < ${#args[@]}; i++)); do
    case "${args[$i]:-}" in
      --no-new) OPT_NO_NEW="1" ;;
      "") : ;;
      *) REMAINING_ARGS+=("${args[$i]}") ;;
    esac
  done
}

main() {
  parse_upgrade_args "$@"
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
    log_warn "No manifest found; nothing to upgrade. Run install.sh first (or sync_claude.sh / sync_opencode.sh)."
    exit "${EXIT_OK}"
  fi

  local source_dir
  if source_dir="$(recall_source_dir)" && [[ -d "${source_dir}" ]]; then
    log_debug "Reusing recorded source directory: ${source_dir}"
  else
    source_dir="$(resolve_source_dir "${SCRIPT_DIR}")"
  fi

  if [[ "${OPT_DRY_RUN}" == "1" ]]; then
    log_info "[dry-run] would refresh ${source_dir} to ref '${OPT_REF}', re-link manifest entries and install new upstream skills."
    exit "${EXIT_OK}"
  fi

  refresh_source "${source_dir}"
  remember_source_dir "${source_dir}"

  # 1) Refresh everything already installed, keeping its recorded mode.
  local relinked=0 target_root
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
        target_root="$(dirname "${r_target}")"
        if [[ ! -d "${source_dir}/skills/${r_skill}" ]]; then
          log_warn "Skill '${r_skill}' no longer exists upstream; leaving your installed copy as-is. Run uninstall.sh --skills ${r_skill} to remove it."
          continue
        fi
        link_skill_keep_mode "${r_skill}" "${source_dir}" "${target_root}" \
          "${r_tool}" "${r_scope}" "${r_mode:-}"
        relinked=$((relinked + 1))
      done < <(manifest_rows "${tool}" "${scope}")
    done < <(expand_scopes)
  done < <(expand_tools)

  # 2) Install skills that are new upstream, into the roots already in use.
  local added=0
  if [[ "${OPT_NO_NEW}" != "1" ]]; then
    sync_new_skills "${source_dir}"
    added="${SYNC_ADDED:-0}"
  fi

  log_ok "Upgrade complete. ${relinked} installed skill(s) re-checked/re-linked, ${added} new skill(s) installed."
  log_info "Restart your Claude Code / OpenCode session so it reloads the skills directory."
}

main "$@"