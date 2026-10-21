#!/usr/bin/env bash
# =============================================================================
# scripts/add-tags.sh
# -----------------------------------------------------------------------------
# PURPOSE
#   Insert (or refresh) a `tags` line under `metadata:` in the YAML frontmatter
#   of skills/<slug>/SKILL.md, using scripts/skill-tags.txt as the data source:
#
#       metadata:
#         category: golang
#         tags: "golang, slog, concurrency"
#
#   Tags are stored as ONE comma-separated string because the Agent Skills
#   standard treats `metadata` values as strings; a YAML list could be rejected
#   by some tools.
#
# USAGE
#   ./scripts/add-tags.sh              # add tags where missing (existing tags are kept)
#   ./scripts/add-tags.sh --force      # also overwrite existing tags from the data file
#   ./scripts/add-tags.sh --dry-run    # show what would change, write nothing
#   ./scripts/add-tags.sh --file <path># use a different data file
#
# BEHAVIOUR
#   * Idempotent: a second run changes nothing.
#   * Only the frontmatter of the listed skills is touched; the body is never
#     modified. A skill with no `metadata:` block gets one created.
#   * Works on Linux and macOS (bash 3.2 compatible, no GNU-only flags).
#
# EXIT CODES
#   0 success | 1 error (bad data file / invalid tag) | 2 invalid usage
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TAGS_FILE="${ROOT}/scripts/skill-tags.txt"
FORCE=0
DRY=0

usage() { sed -n '2,/^# =====*$/p' "${BASH_SOURCE[0]}" | sed '1d;$d;s/^# \{0,1\}//'; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)   FORCE=1; shift ;;
    --dry-run) DRY=1; shift ;;
    --file)    TAGS_FILE="${2:?--file requires a path}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[error] unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -f "${TAGS_FILE}" ]] || { echo "[error] tags file not found: ${TAGS_FILE}" >&2; exit 1; }

TAG_RE='^[a-z0-9]+(-[a-z0-9]+)*(, [a-z0-9]+(-[a-z0-9]+)*)*$'
updated=0; unchanged=0; missing=0; invalid=0

while IFS= read -r line || [[ -n "${line}" ]]; do
  case "${line}" in ''|'#'*) continue ;; esac
  [[ "${line}" == *:* ]] || { echo "[error] malformed line (no ':'): ${line}" >&2; invalid=$((invalid + 1)); continue; }

  slug="$(printf '%s' "${line%%:*}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  tags="$(printf '%s' "${line#*:}" | sed 's/[[:space:]]*,[[:space:]]*/, /g;s/^[[:space:]]*//;s/[[:space:]]*$//')"

  if ! [[ "${tags}" =~ ${TAG_RE} ]]; then
    echo "[error] ${slug}: invalid tags '${tags}' (need lowercase kebab-case, comma-separated)" >&2
    invalid=$((invalid + 1)); continue
  fi

  file="${ROOT}/skills/${slug}/SKILL.md"
  if [[ ! -f "${file}" ]]; then
    echo "[warn]  ${slug}: skills/${slug}/SKILL.md not found; skipped" >&2
    missing=$((missing + 1)); continue
  fi

  tmp="$(mktemp)"
  awk -v tags="${tags}" -v force="${FORCE}" '
    function tagline() { return "  tags: \"" tags "\"" }
    BEGIN { fm = 0; inmeta = 0; hasmeta = 0; done = 0 }
    NR == 1 && $0 == "---" { fm = 1; print; next }
    fm == 1 && $0 == "---" {
      if (!done) { if (!hasmeta) print "metadata:"; print tagline(); done = 1 }
      fm = 2; print; next
    }
    fm == 1 {
      if ($0 ~ /^metadata:/) { inmeta = 1; hasmeta = 1; print; next }
      if (inmeta && $0 ~ /^  tags:/) {
        if (force == "1") print tagline(); else print
        done = 1; next
      }
      if (inmeta && $0 !~ /^  /) {          # left the metadata block without tags
        if (!done) { print tagline(); done = 1 }
        inmeta = 0
      }
      print; next
    }
    { print }
  ' "${file}" > "${tmp}"

  if cmp -s "${file}" "${tmp}"; then
    unchanged=$((unchanged + 1))
  else
    if [[ "${DRY}" == "1" ]]; then
      echo "[dry-run] would update skills/${slug}/SKILL.md  ->  tags: \"${tags}\""
    else
      cat "${tmp}" > "${file}"          # keeps the file's mode and ownership
      echo "[ok]     skills/${slug}/SKILL.md  ->  tags: \"${tags}\""
    fi
    updated=$((updated + 1))
  fi
  rm -f "${tmp}"
done < "${TAGS_FILE}"

# Skills that exist on disk but have no entry in the data file (informational).
for d in "${ROOT}"/skills/*/; do
  s="$(basename "${d}")"
  grep -q "^${s}:" "${TAGS_FILE}" \
    || echo "[info]  ${s}: no entry in $(basename "${TAGS_FILE}") (fine if it sets metadata.tags itself)" >&2
done

verb="updated"; [[ "${DRY}" == "1" ]] && verb="would be updated"
echo "Done: ${updated} ${verb}, ${unchanged} already up to date, ${missing} missing, ${invalid} invalid." >&2
[[ "${invalid}" -eq 0 ]] || exit 1