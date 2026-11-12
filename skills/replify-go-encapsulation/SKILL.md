---
name: replify-go-encapsulation
description: 'Enforces extreme struct encapsulation, nil-receiver safety, and defensive copying in Go. Trigger: "encapsulate struct", "defensive copy Go", "nil-safe getter", "refactor struct encapsulation".'
metadata:
  category: ecosystem-replify
  tags: "replify, golang, encapsulation, nil-safety, defensive-copy"
---

# Go: Extreme Struct Encapsulation

## Purpose

Guarantees memory safety and airtight API boundaries by preventing external mutation of internal state and handling nil pointers gracefully, based on strict enterprise refactoring rules. Responsibility boundary: edits the named struct and its accessors (and call sites that break); does NOT redesign options/setter APIs or logging.

## When to Use / When NOT to Use

- **Use**: All domain models, public DTOs, configuration structs, and library APIs.
- **NOT**: Simple internal loop variables or pure data-transfer structs within a single trusted package boundary where performance is absolutely critical.
- **NOT**: Functional options or fluent setter design (use `replify-go-api-design`).
- **NOT**: General Go idioms unrelated to encapsulation (use `golang`).

## Prerequisites & Assumptions

- Go standard library.
- Willingness to generate or write verbose accessor methods.

### Scope & Context Resolution

- **Supported scopes**: project/repository, package, file, struct/type, method. Default when none is given: the struct(s) the user names; if none is named, ask which type or package to encapsulate instead of refactoring the whole project.
- **Rule 1 - Explicit context in the prompt**: the user's stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to the named struct, its accessors/mutators, and the minimal call-site updates needed to compile; call-site changes in other packages MUST be listed and approved before applying.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Make all struct fields unexported (lowercase).
3. Generate Getters with nil-receiver guards (`if s == nil { return zero }`).
4. Generate Setters that perform defensive copies for slices/maps.
5. Add targeted mutators (`AddX`, `RemoveX`) for collections instead of exposing the slice.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: All struct fields MUST be unexported (lowercase) without exception.
- **MUST**: Every pointer-receiver Getter MUST implement a nil guard to prevent panics on uninitialized pointers.
- **MUST**: Slices, maps, and pointers MUST be deep-copied in Getters/Setters to prevent external mutation of internal state.
- **MUST NOT**: Expose internal slices/maps directly via Getters (e.g., `func (u *User) Tags() []string`).
- **MUST NOT**: Encapsulate other structs in the package that were not named.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `func (u *User) Tags() []string { return u.tags }` (Leaks reference, allows external mutation)
- **Good**: `func (u *User) Tags() []string { if u == nil { return nil }; c := make([]string, len(u.tags)); copy(c, u.tags); return c }`

**Scope handling**

- **Prompt**: "Encapsulate only the `User` struct."
- **Good**: Unexports `User` fields, adds nil-safe getters and copying setters; lists `Order` and `Account` as notes.
- **Bad**: Encapsulates every struct in the package and rewrites all callers.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] All fields unexported.
- [ ] Nil guards present on all pointer-receiver getters.
- [ ] Defensive copies implemented for slices/maps.
- [ ] Targeted mutators (`AddTag`, `RemoveTag`) created.
- [ ] `go build ./...` and `go vet ./...` pass for the affected package.

## Common Pitfalls

- Forgetting to copy the slice in the Setter, allowing the caller to modify the original slice after passing it in.
- Over-encapsulating simple internal structs, leading to unnecessary boilerplate.
- Shallow-copying slices of pointers or nested maps, which still shares inner state.
- Encapsulating neighbouring types and rewriting their callers when one struct was requested.

## References (official docs, standards)

- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments)
- [The Go Programming Language Specification: Method sets](https://go.dev/ref/spec#Method_sets)
