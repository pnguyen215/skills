---
name: golang-audit-godoc-coverage
description: 'Audits and generates GoDoc-compliant inline documentation for pkg.go.dev readiness. Trigger: "audit godoc", "fix pkg.go.dev comments", "generate GoDoc examples", "coverage gap report".'
metadata:
  category: language-specific
---

# Go Audit: GoDoc Coverage & Standards

## Purpose

Ensures every exported Go identifier has precise, authoritative comments that satisfy `go doc` and `pkg.go.dev` rendering standards, producing a formal Coverage Gap Report.

## When to Use / When NOT to Use

- **Use**: Preparing libraries for public release, open-source onboarding, fixing `pkg.go.dev` rendering issues.
- **NOT**: Internal microservices where inline docs are not published to a registry.

## Prerequisites & Assumptions

- Go 1.19+ (for doc link syntax). Target package is compilable.

## Step-by-Step Workflow

1. Scan all `.go` files for exported identifiers (Packages, Types, Interfaces, Functions, Vars).
2. Generate a **Coverage Gap Report** identifying missing or low-quality comments.
3. Apply strict GoDoc formatting rules (first sentence summary, cross-references).
4. Output corrected source files without altering logic.

## Enterprise Rules & Standards (Non-Negotiable)

- **MUST**: First sentence MUST be a complete sentence ending with `.` (e.g., `NewNode constructs a new Node.`).
- **MUST**: Use `[TypeName]` or `[pkg.Func]` for cross-references (Go 1.19+).
- **MUST**: Include an `Example:` block for constructors and core APIs.
- **MUST NOT**: Restate the function signature inside the comment body.
- **MUST NOT**: Add comments to unexported identifiers unless behavior is critical and non-obvious.

## Examples

- **Bad**: `// NewNode is a function that returns a node.` (Redundant, weak summary)
- **Good**:

```go
// NewNode constructs a new [Node] with the given functional options applied.
//
// Example:
//  n := graph.NewNode(graph.WithLabel("API"))
func NewNode(opts ...Option) *Node { ... }
```
