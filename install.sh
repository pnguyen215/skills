#!/usr/bin/env bash
# =============================================================================
# install.sh
# -----------------------------------------------------------------------------
# PURPOSE
#   Install skills from this repository into Claude Code and/or OpenCode's
#   skill directories, for the current user (personal scope) and/or a single
#   project (project scope), without requiring root/sudo and without touching
#   anything this tool did not itself create.
#
# USAGE
#   Local, after cloning:
#     ./install.sh [options]
#
#   Remote one-liner (no clone needed):
#     curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/install.sh \
#       | bash -s -- [options]
#
# OPTIONS
#   See `./install.sh --help` for the full, authoritative list. Summary:
#     --tool <claude|opencode|all>        default: all
#     --scope <personal|project|all>      default: personal
#     --project-dir <path>                default: current directory
#     --mode <auto|symlink|copy>          default: auto
#     --skills <a,b,c>                    default: all skills in the repo
#     --ref <git-ref>                     default: master
#     --dry-run | -y/--yes | -v/--verbose | -h/--help
#
# EXIT CODES
#   0  success
#   1  generic failure
#   2  invalid usage / arguments
#   3  missing prerequisite (git, or curl/wget)
#   4  filesystem error (could not create a directory, symlink, or copy)
#   5  network error (clone/download failed)
#
# SAFETY
#   * Never uses sudo and never writes outside $HOME (or an explicit
#     --project-dir the user chose).
#   * Backs up any pre-existing, non-managed skill directory before
#     overwriting it (see scripts/lib.sh: backup_path()).
#   * Records every installed skill in a manifest OUTSIDE any tool's skills
#     directory, so uninstall.sh / upgrade.sh only ever touch what this tool
#     installed.
#   * Idempotent: running install.sh twice with the same options is a no-op
#     the second time (already-correct symlinks/copies are left alone).
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
install.sh - install skills from $(printf '%s' "${AGENT_SKILLS_REPO}") into
Claude Code and/or OpenCode.

USAGE
  ./install.sh [options]
  curl -fsSL https://raw.githubusercontent.com/${AGENT_SKILLS_REPO}/${AGENT_SKILLS_REF}/install.sh | bash -s -- [options]

$(print_common_help_options)

EXAMPLES
  # Install every skill for Claude Code only, personal scope
  ./install.sh --tool claude

  # Install two specific skills into the current project, for both tools
  ./install.sh --tool all --scope project --skills golang,security-secure-coding

  # Preview what a remote install would do, without changing anything
  curl -fsSL https://raw.githubusercontent.com/${AGENT_SKILLS_REPO}/${AGENT_SKILLS_REF}/install.sh \\
    | bash -s -- --dry-run --yes
EOF
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
  log_info "Detected platform: ${OS_KIND}"
  if is_windows_like; then
    log_info "On Windows, symlinks require Developer Mode or an elevated shell."
    log_info "This tool never requests elevation; with --mode auto it falls back to copying."
  fi

  check_fetch_prereqs

  local project_dir=""
  if [[ "${OPT_SCOPE}" == "project" || "${OPT_SCOPE}" == "all" ]]; then
    project_dir="$(resolve_project_dir)"
    log_info "Project scope resolves to: ${project_dir}"
  fi

  local source_dir
  source_dir="$(resolve_source_dir "${SCRIPT_DIR}")"
  log_info "Using skill content from: ${source_dir}"
  remember_source_dir "${source_dir}"

  # NOTE: `mapfile` needs bash 4+, but macOS ships bash 3.2 -> use a read loop.
  local skills=() _s
  while IFS= read -r _s; do
    if [[ -n "${_s}" ]]; then skills+=("${_s}"); fi
  done < <(list_available_skills "${source_dir}")
  if [[ "${#skills[@]}" -eq 0 ]]; then
    die "No skills matched (check --skills filter: '${OPT_SKILLS}')" "${EXIT_USAGE}"
  fi
  log_info "Will install ${#skills[@]} skill(s): ${skills[*]}"

  if ! confirm "Proceed with installation?"; then
    log_info "Aborted by user."
    exit "${EXIT_OK}"
  fi

  local installed=0
  while IFS= read -r tool; do
    while IFS= read -r scope; do
      local target_root
      target_root="$(skills_root_for "${tool}" "${scope}" "${project_dir}")"
      for skill in "${skills[@]}"; do
        link_skill "${skill}" "${source_dir}" "${target_root}" "${tool}" "${scope}"
        installed=$((installed + 1))
      done
    done < <(expand_scopes)
  done < <(expand_tools)

  if [[ "${OPT_DRY_RUN}" == "1" ]]; then
    log_info "Dry run complete. Nothing was changed."
  else
    log_ok "Done. ${installed} (tool, scope, skill) installation(s) processed."
    log_info "Manifest: $(manifest_file)"
    log_info "Verify in Claude Code with '/skills' or in OpenCode by asking it to list skills."
  fi
}

main "$@"