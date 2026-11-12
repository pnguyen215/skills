---
name: replify-strchain
description: 'Enforces fluent, chainable string building and indentation management using replify/pkg/strchain. Trigger: "use strchain", "string builder replify", "indentation management", "migrate strings.Builder".'
metadata:
  category: ecosystem-replify
  tags: "replify, golang, strings, fluent-api, string-builder"
---

# replify/strchain: Fluent String Building & Indentation

## Purpose

Replaces `strings.Builder` and manual string concatenation with `strchain` for readable, thread-safe, and strictly formatted string generation, especially for code, HTML, SQL, or configuration files. Responsibility boundary: edits string-building code within the named scope only; does NOT change generated output content or migrate unrelated string utilities.

## When to Use / When NOT to Use

- **Use**: Generating multi-line text, code generation, SQL building, or HTML where indentation and layout matter.
- **NOT**: Simple single-line messages (use `fmt.Sprintf` or `strutil.Join`).
- **NOT**: String validation, slugify or transformation helpers (use `replify-strutil`).

## Prerequisites & Assumptions

- `github.com/polarixa/replify/pkg/strchain` imported.

### Scope & Context Resolution

- **Supported scopes**: repository, package/directory, file, function/method. Default: the function or file the user names; if none, the string-building snippet under discussion.
- **Rule 1 - Explicit context**: user-stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to string-building code inside the resolved scope; output text MUST stay byte-identical unless the user asks otherwise.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Initialize with `strchain.New()` (single-goroutine) or `strchain.NewSafe()` (concurrent).
3. Use `.Append()`, `.Line()`, `.LineF()` for content addition.
4. Use `.Indent(level, text)` or `.Spaces(n)` for strict whitespace management.
5. Call `.Build()` or `.Bytes()` or `.String()` to finalize the output.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Eliminate all `strings.Builder` in favor of `strchain.Weaver` interface (within the resolved scope).
- **MUST**: Never hardcode leading spaces or tabs in string literals; use `.Indent()` or `.Spaces()` exclusively.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use `strchain.C(s)` to transform existing strings fluently without creating a new weaver.
- **MUST NOT**: Use `s = s + "..."` in loops or complex formatting logic.
- **MUST NOT**: Migrate `strings.Builder` usages in files outside the named scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `b.WriteString("  <div>\n")` (Hardcoded indentation)
- **Good**: `weaver.IndentLine(1, "<div>")` (Managed indentation)
- **Good (scope)**: Prompt "migrate only `renderHTML` in `render.go`" -> replace the builder in that function; list remaining `strings.Builder` usages as notes.
- **Bad (scope)**: Same prompt -> removing `strings.Builder` across the whole repository.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] `strings.Builder` removed from the resolved scope.
- [ ] Hardcoded indentation replaced with `.Indent()` or `.Spaces()`.
- [ ] Thread-safe weaver (`NewSafe`) used if shared across goroutines.

## Common Pitfalls

- Using the non-thread-safe `StringWeaver` in concurrent HTTP handlers.
- Forgetting to call `.Build()` or `.String()` to materialize the final string.
- Scope creep: migrating every `strings.Builder` in the repo when one function was named.

## References (official docs, standards)

- `github.com/polarixa/replify/pkg/strchain` Migration Guide
- [strings.Builder (Go standard library)](https://pkg.go.dev/strings#Builder)
