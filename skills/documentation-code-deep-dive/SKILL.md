---
name: documentation-code-deep-dive
description: 'Analyze existing source code and add comprehensive, context-aware inline comments (what, why, how, impact) without changing implementation or execution behavior. Supports file, function, module, or whole-codebase scope, selectable comment language and detail level. Trigger: "document this code", "add inline comments", "explain this code with comments", "deep dive and comment this module", "comment every function", "make this code understandable for juniors".'
metadata:
  category: documentation
  tags: "code-documentation, inline-comments, code-analysis, comments, mentoring, behavior-preserving"
---

# Code Deep Dive & Documentation

## Purpose

Act as a Senior Software Engineer, Software Architect, and Technical Mentor who reads existing source code until it is genuinely understood, then documents it with accurate, contextual inline comments. Comments explain not only _what_ the code does but _why_ it exists, _how_ it works, and _how_ it interacts with the surrounding system, as a senior would explain it to a junior teammate.

The skill is **documentation-only and behavior-preserving**: the final diff MUST consist exclusively of comments and documentation. Principle: **understand first, document second, verify last.**

## When to Use / When NOT to Use

**Use when:**

- Adding inline comments, function/class docs, or step-by-step explanations to existing code.
- Onboarding material is needed directly in the source for developers unfamiliar with a codebase.
- Complex algorithms, business rules, or data flows need explaining in place.

**Do NOT use when:**

- The user only wants an explanation in chat with no file changes (use `code-quality-codebase-analyst` or `design-concept-explainer`).
- The task is language-specific API documentation with strict tooling conventions (use `golang-godoc-engineer`, `java-javadoc-engineer`, `python-pydoc-engineer`, or `shell-shdoc-engineer`).
- The task is to refactor, fix, optimize, or rename code (use `code-quality-refactoring`).
- The task is a README, ADR, runbook, or OpenAPI spec (use `documentation-readme-generator`, `documentation-technical-writing`, or `documentation-api-documentation`).
- The task is to review a PR or diff (use `code-quality-code-review`).

## Prerequisites & Assumptions

- **Source is ground truth.** Every claim in a comment MUST be verifiable from the available implementation. Never document assumed behavior.
- **Version control is preferred** for the final integrity check (`git diff`). If unavailable, compare against the original text and state that limitation.
- **Unavailable context** (external services, config, libraries, generated code) MUST be reported, not guessed.

### Inputs

| Input              | Values                                     | Default    | Meaning                                                                                                                                                                                            |
| ------------------ | ------------------------------------------ | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `scope`            | `file` \| `function` \| `module` \| `all`  | `all`      | How much code to document.                                                                                                                                                                         |
| `target`           | path, function name(s), module name(s)     | empty      | What to document; empty only when `scope=all`.                                                                                                                                                     |
| `comment_language` | any natural language                       | `English`  | Language of all comments.                                                                                                                                                                          |
| `detail_level`     | `concise` \| `detailed` \| `comprehensive` | `detailed` | `concise`: purpose and non-obvious logic only. `detailed`: every function plus significant blocks. `comprehensive`: adds step-by-step walk-throughs, edge cases, and cross-component interactions. |

### Scope & Context Resolution

- **Rule 1 - Explicit context in the prompt**: The user's stated scope, target, language, detail level, and constraints are authoritative. Apply them strictly. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT the behavior-preservation rule (never alter functional code), which stays mandatory; flag the conflict instead.
- **Rule 2 - No extra context**: With no explicit input, use the defaults above (`scope=all`, `English`, `detailed`) and this skill as the sole context. MUST NOT import unrelated requirements.
- **Rule 3 - Explicit scope**:
  - `file` -> only the named file.
  - `function` -> only the named function(s), plus the context needed to understand them.
  - `module` -> all relevant files and components of the named module.
  - `all` -> the entire provided codebase.
  - MUST NOT silently expand scope. Out-of-scope code MAY be read for context but MUST NOT be modified; report relevant undocumented dependencies or unverifiable external behavior as notes.
- **Mutation boundary**: Only comments/documentation inside the resolved scope may change.

## Step-by-Step Workflow

1. **Resolve scope and context.** State the resolved `scope`, `target`, `comment_language`, `detail_level`, and mutation boundary in one line.
2. **Inspect structure.** Identify language, framework, architecture, project layout, and the files in scope. List them to track progress.
3. **Read before writing (mandatory).** Read each target file completely. Review existing comment style, doc conventions, and naming to stay consistent.
4. **Phase 1 - Analyze.** For each file/component determine: responsibility, role in the architecture, dependencies, main execution paths, inputs/outputs/state transitions, business rules, side effects, edge cases. Trace important calls into dependencies (read-only). Cover inputs/outputs, initialization and state changes, branching and loops, error propagation, and external API interactions.
5. **Summarize the mental model** (architecture, responsibilities, execution flow) before commenting anything.
6. **Phase 2 - Document.** Add comments per the rules below, using the language's idiomatic comment and doc syntax and the requested `detail_level`.
7. **Phase 3 - Quality review.** Re-read each comment against the code (not against assumptions). Fix inaccuracies, contradictions, inconsistent terminology, and noise.
8. **Phase 4 - Integrity verification.** Run `git diff` (or equivalent) and confirm every changed line is a comment. Report, never silently fix, any suspected defect in the code.
9. **Report.** Produce the output sections below, listing any file not completed and why.

For large codebases: process files incrementally, keep terminology consistent, track done/remaining files, never silently skip a file, and continue until the scope is covered.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

### Documentation Content

- **MUST** explain, where relevant: WHAT the code does, WHY it is needed, HOW it works, and its IMPACT on surrounding execution flow.
- **MUST** document important imports/dependencies, constants and variables, function/method declarations (purpose, parameters, return values, side effects, callees, error conditions), classes/interfaces/components (responsibility, architectural role, relationships, state, lifecycle), conditionals, loops, data transformations, object initialization, error handling, external API calls, and non-trivial expressions.
- **MUST** give complex logic and algorithms a step-by-step explanation: logic, operation order, decision points, data transformations, performance considerations, edge cases, side effects.
- **MUST** use the documentation conventions of the language (e.g., doc-comment forms for functions/classes) and follow the existing project style.
- **MUST** explain code in its real context and prefer WHY/HOW over restating the syntax.
- **MUST** clearly separate verified behavior from reasonable inference (e.g., "Inferred: likely to avoid X; not stated in source"). If the reason cannot be established, say so rather than inventing one.
- **SHOULD NOT** comment syntax-only lines, closing braces, or statements already fully explained by an adjacent block comment.
- **SHOULD** keep terminology identical across files for the same concept.

### Behavior Preservation (non-negotiable)

- **MUST NOT** remove, add, reorder, or alter any executable statement.
- **MUST NOT** rename identifiers, change signatures, conditions, loops, control flow, return values, exception behavior, configuration, or dependencies.
- **MUST NOT** refactor, optimize, reformat, or "tidy" code; keep the diff minimal and comment-only (watch for tooling that auto-formats on save).
- **MUST NOT** add dependencies or invent business rules, intentions, or undocumented behavior.
- **MUST NOT** delete existing comments unless demonstrably incorrect and necessary for accuracy; report such a case before changing it.
- **MUST** report suspected bugs, dead code, or risky logic as findings instead of fixing them.
- **MUST** take care that comments cannot alter semantics: no comment inside a string/template literal, no pragma-like or directive-like comment (`// eslint-disable`, `# type: ignore`, `//go:build`, `// +build`, `#!shebang`, `# noqa`, `@ts-ignore`, magic encoding lines, etc.) added or disturbed, and no code-generation or doc-tool markers broken.

### Output Format

Provide results in this order:

1. **Codebase Overview** - structure, main responsibilities, important dependencies, high-level execution flow.
2. **Documentation Summary** - files, functions, and classes covered; important algorithms and business rules explained.
3. **Documented Source Code** - for each file: clear path, complete source with comments, nothing truncated. When files were edited in place and the user can read the diff, list changed paths and show the full content only if requested or if the files are small; state which choice was made.
4. **Technical Insights** - non-obvious logic, architectural decisions, dependencies/interactions, edge cases, side effects, limitations; only what the source supports.
5. **Verification Results** - files reviewed vs. documented, scope coverage, integrity check method and outcome, **Functional changes: NONE**, unresolved issues or unavailable context.
6. **Remaining Work** - files not yet documented, reasons, and context that could not be inspected (write "None" if complete).

## Examples (good vs. bad, with realistic code or output)

**Good: contextual comments (Go), code unchanged**

```go
// reserveStock atomically decrements available inventory for an order.
// It must run inside the caller's transaction so a later payment failure
// rolls the reservation back (see OrderService.Process).
// Returns ErrInsufficientStock when qty exceeds what is available.
func reserveStock(tx *sql.Tx, sku string, qty int) error {
	// Conditional UPDATE makes check-and-decrement a single statement,
	// avoiding a read-then-write race between concurrent orders.
	res, err := tx.Exec(
		"UPDATE stock SET available = available - ? WHERE sku = ? AND available >= ?",
		qty, sku, qty,
	)
	if err != nil {
		return err
	}
	// Zero rows affected means the WHERE guard failed: not enough stock.
	if n, _ := res.RowsAffected(); n == 0 {
		return ErrInsufficientStock
	}
	return nil
}
```

**Bad: restates syntax and invents intent**

```go
// loop through items
for _, item := range items {
	// call reserveStock for speed optimization   <-- invented reason
	reserveStock(tx, item.SKU, item.Qty)
}
```

_Why it's bad: repeats the code, fabricates an "optimization" rationale, and ignores the discarded error (which should be reported as a finding, not fixed)._

**Good: reporting instead of fixing**

> Finding (not modified): `reserveStock`'s error is discarded in `Process` (`order.go`, loop over `items`). Documented as "result is ignored in the source"; fixing it is out of scope.

**Scope handling**

- **Prompt**: `scope=function`, `target=reserveStock`.
- **Good**: Documents `reserveStock`, reads its caller for context, notes the unverified `stock` table schema, edits nothing else.
- **Bad**: Comments the whole `order` package and renames `qty` to `quantity`.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope, target, comment language, and detail level resolved and stated.
- [ ] Every in-scope file read completely before editing.
- [ ] Architecture, execution flow, and dependencies summarized before commenting.
- [ ] Every important function, class, component, and logical block documented at the requested detail level.
- [ ] Complex logic and algorithms have step-by-step explanations.
- [ ] Verified behavior is distinguished from inference; no invented rationale.
- [ ] Comments match the code, use consistent terminology, and add no noise.
- [ ] Existing comments preserved (or correction reported first).
- [ ] No directive/pragma comments or string literals disturbed.
- [ ] `git diff` shows comment-only changes; functional changes: NONE.
- [ ] No out-of-scope file modified; unavailable context reported.
- [ ] All six output sections provided; remaining work listed.

## Common Pitfalls

- **Narrating syntax:** `i++ // increment i` adds noise. Explain intent and effect instead.
- **Inventing the why:** Plausible but unsupported rationale ("for performance") misleads maintainers. Mark it as inference or omit it.
- **Silent "fixes":** Correcting an off-by-one or swallowed error while commenting breaks the behavior-preservation contract. Report it.
- **Comment drift:** Describing what the code _should_ do rather than what it does. Re-verify each comment against the implementation.
- **Breaking directives:** Inserting comments that shift line numbers used by tooling, or touching `//go:generate`, `# noqa`, `eslint-disable`, or shebang lines.
- **Auto-formatter churn:** Editor or hook reformatting adds unrelated diff lines. Check the diff and revert formatting-only changes.
- **Scope creep:** Documenting neighboring modules because they are "related". Read them for context only.
- **Skipping files in large scopes:** Always track completed and remaining files and report gaps explicitly.

## References (official docs, standards)

- Language-specific documentation conventions: Go Doc Comments (`go.dev/doc/comment`), JavaDoc, PEP 257, JSDoc/TSDoc, Rustdoc.
- Existing project `CONTRIBUTING.md`, style guides, and linter configs (comment style and line-length rules).
- Sibling skills: `code-quality-codebase-analyst` (analysis), `golang-godoc-engineer`, `java-javadoc-engineer`, `python-pydoc-engineer`, `shell-shdoc-engineer` (language-specific API docs).
