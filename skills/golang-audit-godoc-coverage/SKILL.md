---
name: golang-audit-godoc-coverage
description: 'Audits and generates GoDoc-compliant inline documentation for pkg.go.dev readiness. Trigger: "audit godoc", "fix pkg.go.dev comments", "generate GoDoc examples", "coverage gap report".'
metadata:
  category: language-specific
  tags: "golang, godoc, documentation, audit, pkg-go-dev"
---

# Go Audit: GoDoc Coverage & Standards

## Purpose

Ensures every exported Go identifier has precise, authoritative comments that satisfy `go doc` and `pkg.go.dev` rendering standards, producing a formal Coverage Gap Report. This skill edits doc comments only; it does NOT change logic, signatures or unexported code.

## When to Use / When NOT to Use

- **Use**: Preparing libraries for public release, open-source onboarding, fixing `pkg.go.dev` rendering issues.
- **NOT**: Internal microservices where inline docs are not published to a registry.
- **NOT**: Generating or refactoring GoDoc beyond an audit (use `golang-godoc-engineer`).
- **NOT**: Writing ADRs, runbooks or READMEs (use `documentation-technical-writing`).

## Prerequisites & Assumptions

- Go 1.19+ (for doc link syntax). Target package is compilable.

### Scope & Context Resolution

- **Supported scopes**: package (default), directory/module, file, type, function/method.
- **Rule 1 - Explicit context in the prompt**: Stated Go version, package, style requirements and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at package scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to doc comments (and `Example` functions) inside the resolved scope. MUST NOT alter code logic.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Scan `.go` files in scope for exported identifiers (Packages, Types, Interfaces, Functions, Vars).
3. Generate a **Coverage Gap Report** identifying missing or low-quality comments.
4. Apply strict GoDoc formatting rules (first sentence summary, cross-references).
5. Output corrected source files without altering logic.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: First sentence MUST be a complete sentence ending with `.` (e.g., `NewNode constructs a new Node.`).
- **MUST**: Use `[TypeName]` or `[pkg.Func]` for cross-references (Go 1.19+).
- **MUST**: Include an `Example:` block for constructors and core APIs.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST NOT**: Restate the function signature inside the comment body.
- **MUST NOT**: Add comments to unexported identifiers unless behavior is critical and non-obvious.
- **MUST NOT**: Edit identifiers in packages outside the resolved scope; list them in the report instead.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `// NewNode is a function that returns a node.` (Redundant, weak summary)
- **Good**:

```go
// NewNode constructs a new [Node] with the given functional options applied.
//
// Example:
//  n := graph.NewNode(graph.WithLabel("API"))
func NewNode(opts ...Option) *Node { ... }
```

- **Good (scoped)**: Prompt "audit only `NewNode`" -> report and fix the comment on `NewNode`; note undocumented `Edge` as a finding without editing it.
- **Bad (scope-expanding)**: Same prompt -> rewrite comments for every exported identifier in the package.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Coverage Gap Report produced for every exported identifier in scope.
- [ ] Each first sentence is complete and ends with `.`.
- [ ] Cross-references use `[TypeName]` / `[pkg.Func]`.
- [ ] Constructors and core APIs have an `Example:` block.
- [ ] `go doc` / `go vet ./...` runs clean and logic is unchanged.

## Common Pitfalls

- Restating the signature ("NewNode is a function that returns a node").
- Documenting unexported helpers, adding noise.
- Using pre-1.19 plain-text references that do not render as links.
- Auditing the whole module when only one package was requested.

## References (official docs, standards)

- [Go Doc Comments](https://go.dev/doc/comment)
- [Effective Go: Commentary](https://go.dev/doc/effective_go#commentary)
- [pkg.go.dev About](https://pkg.go.dev/about)
