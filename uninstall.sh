#!/usr/bin/env bash
# =============================================================================
# uninstall.sh
# -----------------------------------------------------------------------------
# PURPOSE
#   Remove skills that install.sh/upgrade.sh/sync_*.sh previously installed.
#   It removes exactly the (tool, scope, skill) rows found in the manifest,
#   then sweeps up leftover symlinks that point into this tool's own source
#   clone (these are always created by this tool, but may have lost their
#   manifest row, e.g. when the same skill was installed into two projects).
#   It never touches a directory or symlink that points anywhere else, so a
#   skill folder you created by hand with the same name is left alone.
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
#   filters as install.sh.
#
#   --purge      Also delete this tool's own state (manifest, backups) AND the
#                managed cache clone after removing the skills.
#   --no-sweep   Only remove manifest-tracked entries; skip the leftover-symlink
#                sweep.
#
# EXIT CODES
#   0 success | 1 generic failure | 2 invalid usage | 4 filesystem error
#
# SAFETY
#   * Never uses sudo; only deletes inside $HOME or an explicit --project-dir.
#   * Idempotent: running it twice, or on an already-clean system, is a
#     harmless no-op.
# =============================================================================
set -euo pipefail

# -----------------------------------------------------------------------------
# Locate scripts/lib.sh (see upgrade.sh for the full explanation).
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
OPT_PURGE="0"
OPT_NO_SWEEP="0"
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
  --purge     Also remove this tool's state directory (manifest, backups) and
              the managed cache clone after uninstalling the skills.
  --no-sweep  Do not remove leftover symlinks that point into this tool's
              source clone but are missing from the manifest.

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
  # Re-scan the leftovers for script-specific flags.
  args=("${REMAINING_ARGS[@]:-}")
  REMAINING_ARGS=()
  for ((i = 0; i < ${#args[@]}; i++)); do
    case "${args[$i]:-}" in
      --purge) OPT_PURGE="1" ;;
      --no-sweep) OPT_NO_SWEEP="1" ;;
      "") : ;;
      *) REMAINING_ARGS+=("${args[$i]}") ;;
    esac
  done
}

# Remove symlinks that point into this tool's own source clone but have no
# manifest row. Honours --tool, --scope, --skills and --dry-run.
sweep_untracked_links() {
  local project_dir sources tool scope root src entry slug swept=0
  project_dir="$(resolve_project_dir)"
  sources="$(managed_source_dirs)"

  while IFS= read -r tool; do
    while IFS= read -r scope; do
      while IFS= read -r root; do
        [[ -n "${root}" ]] || continue
        while IFS= read -r src; do
          [[ -n "${src}" ]] || continue
          while IFS= read -r entry; do
            [[ -n "${entry}" ]] || continue
            slug="$(basename "${entry}")"
            if [[ -n "${OPT_SKILLS}" ]]; then
              case ",${OPT_SKILLS}," in
                *",${slug},"*) ;;
                *) continue ;;
              esac
            fi
            # Still tracked by the manifest -> handled by the main loop.
            if manifest_rows | awk -F'\t' -v p="${entry}" '$4==p {f=1} END{exit !f}'; then
              continue
            fi
            if [[ "${OPT_DRY_RUN}" == "1" ]]; then
              log_info "[dry-run] would remove untracked link '${entry}'"
            else
              rm -f "${entry}"
              log_ok "Removed untracked link for '${slug}' from ${tool}/${scope} (${entry})"
            fi
            swept=$((swept + 1))
          done < <(find_untracked_links "${root}" "${src}")
        done <<< "${sources}"
      done < <(
        {
          skills_root_for "${tool}" "${scope}" "${project_dir}"
          manifest_roots | awk -F'\t' -v t="${tool}" -v s="${scope}" '$1==t && $2==s {print $3}'
        } | sort -u
      )
    done < <(expand_scopes)
  done < <(expand_tools)

  if [[ "${swept}" -gt 0 ]]; then
    log_ok "Swept ${swept} leftover link(s) that were not in the manifest."
  fi
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

  local have_manifest="1"
  if ! manifest_exists; then
    have_manifest="0"
    log_info "No manifest found at $(manifest_file); nothing tracked by this tool."
  fi

  # The manifest stores the absolute target path computed at install time for
  # each row, so --project-dir is not needed to remove tracked entries.
  local rows_total=0
  if [[ "${have_manifest}" == "1" ]]; then
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
  fi

  if [[ "${rows_total}" -gt 0 ]]; then
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
  else
    log_info "No manifest entries match tool=${OPT_TOOL} scope=${OPT_SCOPE} skills='${OPT_SKILLS:-*}'."
  fi

  if [[ "${OPT_NO_SWEEP}" != "1" ]]; then
    sweep_untracked_links
  fi

  if [[ "${OPT_PURGE}" == "1" && "${OPT_DRY_RUN}" != "1" ]]; then
    local sd cd
    sd="$(state_dir)"
    cd="$(cache_dir)"
    if confirm "Also delete this tool's state (${sd}) and managed clone (${cd}/repo)?"; then
      rm -rf "${sd}" "${cd}/repo"
      rmdir "${cd}" 2>/dev/null || true
      log_ok "Removed state directory ${sd} and managed clone ${cd}/repo."
    fi
  fi

  log_info "Restart your Claude Code / OpenCode session so it reloads the skills directory."
}

main "$@"