---
name: replify-strutil
description: 'Standardizes string manipulation, validation, and transformation using replify/pkg/strutil. Trigger: "string manipulation replify", "slugify string", "use strutil", "string validation".'
metadata:
  category: ecosystem-replify
  tags: "replify, golang, strings, validation, transformation"
---

# replify/strutil: Comprehensive String Utilities

## Purpose

Eliminates boilerplate and edge-case bugs in string handling by leveraging the comprehensive, well-tested `strutil` API for validation, transformation, and formatting. This skill replaces hand-written string helpers with `strutil` calls inside the requested scope; it does NOT touch non-string logic or fluent string building.

## When to Use / When NOT to Use

- **Use**: URL slug generation, input validation (`IsEmpty`, `IsAlpha`), safe trimming, and display formatting (`Truncate`).
- **NOT**: High-performance binary parsing, byte-level operations, or hot-loop string concatenation (use `strchain` or `strings.Builder`).
- **NOT**: Chainable string building or indentation management (use `replify-strchain`).

## Prerequisites & Assumptions

- `github.com/polarixa/replify/pkg/strutil` imported.

### Scope & Context Resolution

- **Supported scopes**: repository/module, directory/package, file, function/method. Default: the files the user names; if none, the Go package in the working directory.
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to string-handling code (and the `strutil` import) inside the resolved scope. MUST NOT alter other logic or other packages.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply Scope & Context Resolution; state the resolved scope and mutation boundary in one line at the start of the output.
2. Replace custom regex or `strings.*` boilerplate in scope with `strutil` equivalents.
3. Use `strutil.Slugify` for generating URL-friendly keys from user input.
4. Use `strutil.Truncate` with ellipsis for UI/display strings to prevent layout breaking.
5. Use `strutil.DefaultIfBlank` for safe fallback values.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Use `strutil.IsEmpty` or `strutil.IsBlank` instead of `s == ""` or `len(s) == 0` to correctly handle whitespace-only inputs.
- **MUST**: Use `strutil.Slugify` for generating URL routes or resource identifiers from human-readable titles.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use `strutil.DefaultIfEmpty` for fallback values instead of manual `if/else` blocks.
- **MUST NOT**: Re-implement functions like `Capitalize`, `Strip`, `Chomp`, or `Truncate` locally within the codebase.
- **MUST NOT**: Replace string code outside the resolved scope or on byte-level hot paths.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `if len(strings.TrimSpace(s)) == 0 { s = "default" }`
- **Good**: `s = strutil.DefaultIfBlank(s, "default")`
- **Good (scoped)**: Prompt "use strutil in `slug.go` only" -> replace manual slug code in `slug.go`; note custom `trim()` helpers in `util/`.
- **Bad (scope-expanding)**: Same prompt -> delete `util/` helpers and rewrite every package's string checks.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Replaced manual string checks with `strutil` validators.
- [ ] `Slugify` used for all URL/resource keys.
- [ ] No custom string utility functions exist in the project.

## Common Pitfalls

- Confusing `IsEmpty` (checks length) with `IsBlank` (checks whitespace).
- Using `Truncate` without considering UTF-8 rune boundaries (though `strutil` handles this safely).
- Scope creep: removing project-wide helpers when asked to convert one file.

## References (official docs, standards)

- `github.com/polarixa/replify/pkg/strutil` API Documentation
