#!/usr/bin/env bash
# =============================================================================
# uninstall.sh
# -----------------------------------------------------------------------------
# PURPOSE
#   Remove skills that install.sh previously installed, and only those. This
#   script reads the manifest written by install.sh/upgrade.sh and removes
#   exactly the (tool, scope, skill) rows it finds there -- it never deletes
#   a directory or symlink that is not recorded in the manifest, even if it
#   looks similar (e.g. a skill folder you created by hand with the same
#   name is left untouched).
#
# USAGE
#   Local, after cloning:
#     ./uninstall.sh [options]
#
#   Remote one-liner:
#     curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/uninstall.sh \
#       | bash -s -- [options]
#
# OPTIONS
#   See `./uninstall.sh --help`. Accepts the same --tool/--scope/--skills
#   filters as install.sh, so you can remove a subset (e.g. only OpenCode,
#   only one project, only one skill) instead of everything.
#
#   --purge   Also delete this tool's own state directory (manifest, backups,
#             and the managed cache clone) after removing the skills. Without
#             --purge, backups and the manifest are kept so you can inspect
#             or restore them later.
#
# EXIT CODES
#   0 success | 1 generic failure | 2 invalid usage | 4 filesystem error
#
# SAFETY
#   * Only removes manifest-tracked entries (see scripts/lib.sh: unlink_skill()).
#   * Never uses sudo; only ever deletes inside $HOME or an explicit
#     --project-dir, and only paths this tool created.
#   * Idempotent: running it twice, or on an already-clean system, is a
#     harmless no-op.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REMAINING_ARGS=()
OPT_PURGE="0"
# shellcheck source=scripts/lib.sh
source "${SCRIPT_DIR}/scripts/lib.sh"

print_help() {
  cat <<EOF
uninstall.sh - remove skills previously installed by install.sh.

USAGE
  ./uninstall.sh [options]
  curl -fsSL https://raw.githubusercontent.com/${AGENT_SKILLS_REPO}/${AGENT_SKILLS_REF}/uninstall.sh | bash -s -- [options]

$(print_common_help_options)

ADDITIONAL OPTIONS
  --purge   Also remove this tool's state directory (manifest, backups,
            managed cache clone) after uninstalling the skills themselves.

EXAMPLES
  # Remove everything this tool ever installed, for every tool and scope
  ./uninstall.sh --tool all --scope all --yes

  # Remove one skill from Claude Code's personal skills only
  ./uninstall.sh --tool claude --scope personal --skills golang-audit-security
EOF
}

parse_uninstall_args() {
  local args=() i
  parse_common_args "$@"
  # Re-scan the leftovers for --purge, since parse_common_args() doesn't
  # know about script-specific flags.
  args=("${REMAINING_ARGS[@]:-}")
  REMAINING_ARGS=()
  for ((i = 0; i < ${#args[@]}; i++)); do
    case "${args[$i]:-}" in
      --purge) OPT_PURGE="1" ;;
      "") : ;;
      *) REMAINING_ARGS+=("${args[$i]}") ;;
    esac
  done
}

main() {
  parse_uninstall_args "$@"
  if [[ "${#REMAINING_ARGS[@]}" -gt 0 && "${REMAINING_ARGS[0]:-}" == "--help" ]]; then
    print_help
    exit "${EXIT_OK}"
  fi
  if [[ "${#REMAINING_ARGS[@]}" -gt 0 ]]; then
    die "Unknown argument(s): ${REMAINING_ARGS[*]}" "${EXIT_USAGE}"
  fi
  validate_common_args
  detect_os

  if ! manifest_exists; then
    log_info "No manifest found at $(manifest_file); nothing installed by this tool."
    exit "${EXIT_OK}"
  fi

  # Note: unlike install.sh, uninstall.sh does not need to resolve
  # --project-dir itself -- the manifest already stores the absolute
  # target path that was computed at install time for each row.
  local rows_total=0
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
        rows_total=$((rows_total + 1))
      done < <(manifest_rows "${tool}" "${scope}")
    done < <(expand_scopes)
  done < <(expand_tools)

  if [[ "${rows_total}" -eq 0 ]]; then
    log_info "No manifest entries match tool=${OPT_TOOL} scope=${OPT_SCOPE} skills='${OPT_SKILLS:-*}'."
    exit "${EXIT_OK}"
  fi

  log_info "Found ${rows_total} manifest entrie(s) to remove."
  if ! confirm "Remove ${rows_total} installed skill entrie(s)?"; then
    log_info "Aborted by user."
    exit "${EXIT_OK}"
  fi

  local removed=0
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
        unlink_skill "${r_tool}" "${r_scope}" "${r_skill}" "${r_target}"
        removed=$((removed + 1))
      done < <(manifest_rows "${tool}" "${scope}")
    done < <(expand_scopes)
  done < <(expand_tools)

  log_ok "Removed ${removed} skill installation(s)."

  if [[ "${OPT_PURGE}" == "1" && "${OPT_DRY_RUN}" != "1" ]]; then
    local sd
    sd="$(state_dir)"
    if confirm "Also delete this tool's state directory (${sd}), including backups?"; then
      rm -rf "${sd}"
      log_ok "Removed state directory ${sd}."
    fi
  fi
}

main "$@"
