#!/usr/bin/env bash
# =============================================================================
# scripts/skills-table.sh
# -----------------------------------------------------------------------------
# PURPOSE
#   Build the "Available Skills" table (Category | Skill | Tags) from each
#   skills/<slug>/SKILL.md frontmatter (`metadata.category`, `metadata.tags`),
#   so README.md can never drift from the real skills.
#
# USAGE
#   ./scripts/skills-table.sh          # print the table to stdout
#   ./scripts/skills-table.sh --write  # replace the block between the markers
#                                      #   <!-- skills-table:start --> and
#                                      #   <!-- skills-table:end -->  in README.md
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
README="${ROOT}/README.md"
START='<!-- skills-table:start -->'
END='<!-- skills-table:end -->'

field() { # field <file> <key>  -> value of metadata.<key> (quotes stripped)
  awk -v k="$2" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---"  { exit }
    /^metadata:/           { m = 1; next }
    m && /^[^ ]/           { m = 0 }
    m && $0 ~ "^  " k ":"  { sub("^  " k ":[ \t]*", ""); print; exit }
  ' "$1" | sed -e 's/[[:space:]]*$//' -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/"
}

build_table() {
  local d slug cat tags
  for d in "${ROOT}"/skills/*/; do
    slug="$(basename "${d}")"
    [[ -f "${d}SKILL.md" ]] || continue
    cat="$(field "${d}SKILL.md" category)"; tags="$(field "${d}SKILL.md" tags)"
    printf '%s\t%s\t%s\n' "${cat:-uncategorized}" "${slug}" "${tags}"
  done | LC_ALL=C sort -t "$(printf '\t')" -k1,1 -k2,2 | awk -F'\t' '
    { c[NR] = "`" $1 "`"; s[NR] = "`" $2 "`"
      t[NR] = ""; n = split($3, a, /, */)
      for (i = 1; i <= n; i++) if (a[i] != "") t[NR] = t[NR] (t[NR] == "" ? "" : ", ") "`" a[i] "`"
      if (length(c[NR]) > w1) w1 = length(c[NR])
      if (length(s[NR]) > w2) w2 = length(s[NR])
      if (length(t[NR]) > w3) w3 = length(t[NR]) }
    function pad(x, w) { while (length(x) < w) x = x " "; return x }
    function dash(w, r) { while (length(r) < w) r = r "-"; return r }
    END {
      if (w1 < 8)  w1 = 8
      if (w2 < 5)  w2 = 5
      if (w3 < 4)  w3 = 4
      print "| " pad("Category", w1) " | " pad("Skill", w2) " | " pad("Tags", w3) " |"
      print "| " dash(w1, "") " | " dash(w2, "") " | " dash(w3, "") " |"
      for (i = 1; i <= NR; i++) print "| " pad(c[i], w1) " | " pad(s[i], w2) " | " pad(t[i], w3) " |"
    }'
}

if [[ "${1:-}" != "--write" ]]; then
  build_table
  exit 0
fi

[[ -f "${README}" ]] || { echo "[error] ${README} not found" >&2; exit 1; }
grep -qF "${START}" "${README}" && grep -qF "${END}" "${README}" \
  || { echo "[error] README.md is missing the ${START} / ${END} markers" >&2; exit 1; }

tbl="$(mktemp)"; out="$(mktemp)"
build_table > "${tbl}"
awk -v s="${START}" -v e="${END}" -v f="${tbl}" '
  $0 == s { print; while ((getline line < f) > 0) print line; skip = 1; next }
  $0 == e { skip = 0 }
  !skip   { print }
' "${README}" > "${out}"
cat "${out}" > "${README}"
rm -f "${tbl}" "${out}"
echo "Updated the Available Skills table in README.md ($(ls -d "${ROOT}"/skills/*/ | wc -l | tr -d ' ') skills)." >&2