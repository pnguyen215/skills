---
name: golang
description: 'Enterprise Go standards: modules, generics, slog, context propagation, concurrency. Trigger: "Go best practices", "write idiomatic Go", "golang review".'
metadata:
  category: language-specific
  tags: "golang, go-modules, generics, slog, concurrency, context"
---

# Enterprise Go Standards

## Purpose

Ensures Go code is idiomatic, performant, and secure. Responsibility boundary: writes and reviews Go code against these standards within the named scope; does NOT perform dedicated security, cross-platform or GoDoc audits, and does NOT restructure code outside the scope.

## When to Use / When NOT to Use

- **Use**: Writing new Go services, reviewing Go PRs, modernizing legacy Go.
- **NOT**: Quick bash/python scripts.
- **NOT**: Dedicated security audits (use `golang-audit-security`) or cross-platform audits (use `golang-audit-cross-platform`).
- **NOT**: Writing or auditing GoDoc comments (use `golang-godoc-engineer`).

## Prerequisites & Assumptions

- Go 1.21+ (Modules, Generics, `slog`).

### Scope & Context Resolution

- **Supported scopes**: repository/module, package/directory, file, type, function. Default: the file or function the user names; if none, the code snippet or change under discussion.
- **Rule 1 - Explicit context**: user-stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to Go code inside the resolved scope; a review request is analysis-only and MUST NOT edit code.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Use Go modules and strict versioning.
3. Apply structured logging (`log/slog`) in the resolved scope.
4. Propagate `context.Context` everywhere within it.
5. Handle errors explicitly and wrap with `%w`.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Propagate `context.Context` as the first argument.
- **MUST**: Wrap errors with `%w` for chainability.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use `slog` for structured, JSON-friendly logs.
- **MUST NOT**: Use `init()` for complex logic or side effects.
- **MUST NOT**: Change exported signatures of callers outside the scope to thread `context.Context` without approval.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `func Get() { log.Println("error") }`
- **Good**: `func Get(ctx context.Context) error { return fmt.Errorf("failed: %w", err) }`
- **Good (scope)**: Prompt "only fix error wrapping in `store.go`" -> change `fmt.Errorf` calls in `store.go`; mention missing `ctx` in `handler.go` as a note.
- **Bad (scope)**: Same prompt -> also migrating logging to `slog` and renaming packages across the module.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Context passed.
- [ ] Errors wrapped.
- [ ] Slog used.

## Common Pitfalls

- Goroutine leaks (missing `context` cancellation).
- Ignoring errors or using `panic` for control flow.
- Scope creep: modernizing neighbouring packages when one file was named.

## References (official docs, standards)

- [Effective Go](https://go.dev/doc/effective_go)
- [log/slog package](https://pkg.go.dev/log/slog)
- [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments)
