#!/usr/bin/env bash
# =============================================================================
# sync_opencode.sh
# -----------------------------------------------------------------------------
# PURPOSE
#   One command that makes opencode's skills directory mirror the LATEST skills of
#   the repository: pulls the newest content, installs new skills, refreshes
#   installed ones (symlink/copy mode preserved) and removes skills that were
#   deleted upstream. Safe to run any number of times. Works even if you never
#   ran install.sh before.
#
# USAGE
#   Local, after cloning:
#     ./sync_opencode.sh [options]
#
#   Remote one-liner:
#     curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/sync_opencode.sh \
#       | bash -s -- --yes
#
# OPTIONS
#   Same as install.sh (see --help), plus --no-prune to keep skills that were
#   deleted upstream. --tool is fixed to opencode.
#
# SAFETY
#   * Pre-existing folders this tool did not create are never touched.
#   * Never uses sudo; only writes under $HOME or an explicit --project-dir.
#
# EXIT CODES
#   0 success | 1 generic failure | 2 invalid usage | 3 missing prerequisite
#   4 filesystem error | 5 network error
# =============================================================================
set -euo pipefail

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

sync_main "opencode" "$@"