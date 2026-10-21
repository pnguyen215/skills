#!/usr/bin/env bash
# =============================================================================
# scripts/validate-tags.sh
# -----------------------------------------------------------------------------
# PURPOSE
#   Gate used by `make validate`: every skills/<slug>/SKILL.md MUST declare
#   `metadata.tags` in its frontmatter:
#
#       metadata:
#         category: security
#         tags: "security, owasp, input-validation"
#
# RULES
#   * `tags` is present and non-empty, a single comma-separated string.
#   * 3 to 8 tags per skill.
#   * Each tag is lowercase kebab-case ([a-z0-9] groups joined by single '-').
#   * No duplicate tags within one skill.
#
# EXIT CODES
#   0 all skills valid | 1 at least one violation
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIN_TAGS=3
MAX_TAGS=8
TAG_RE='^[a-z0-9]+(-[a-z0-9]+)*$'

# Prints the raw value of metadata.tags (quotes stripped), or nothing.
extract_tags() {
  awk '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---"  { exit }
    /^metadata:/           { m = 1; next }
    m && /^[^ ]/           { m = 0 }
    m && /^  tags:/        { sub(/^  tags:[ \t]*/, ""); print; exit }
  ' "$1" | sed -e 's/[[:space:]]*$//' -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/"
}

status=0; total=0
for dir in "${ROOT}"/skills/*/; do
  total=$((total + 1))
  rel="skills/$(basename "${dir}")/SKILL.md"
  file="${dir}SKILL.md"
  [[ -f "${file}" ]] || { echo "ERROR: ${rel}: file not found" >&2; status=1; continue; }

  raw="$(extract_tags "${file}")"
  if [[ -z "${raw}" ]]; then
    echo "ERROR: ${rel}: missing metadata.tags (add e.g.  tags: \"golang, security, audit\"  under metadata:)" >&2
    status=1; continue
  fi

  count=0; seen=","
  old_ifs="${IFS}"; IFS=','
  # shellcheck disable=SC2206
  parts=(${raw})
  IFS="${old_ifs}"
  for part in "${parts[@]}"; do
    tag="$(printf '%s' "${part}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    count=$((count + 1))
    if ! [[ "${tag}" =~ ${TAG_RE} ]]; then
      echo "ERROR: ${rel}: invalid tag '${tag}' (use lowercase kebab-case)" >&2; status=1; continue
    fi
    case "${seen}" in
      *",${tag},"*) echo "ERROR: ${rel}: duplicate tag '${tag}'" >&2; status=1 ;;
    esac
    seen="${seen}${tag},"
  done

  if [[ "${count}" -lt "${MIN_TAGS}" || "${count}" -gt "${MAX_TAGS}" ]]; then
    echo "ERROR: ${rel}: ${count} tag(s); expected ${MIN_TAGS}-${MAX_TAGS}" >&2; status=1
  fi
done

if [[ "${status}" -eq 0 ]]; then
  echo "Tags OK: all ${total} skills have valid metadata.tags."
fi
exit "${status}"