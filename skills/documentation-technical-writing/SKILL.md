---
name: documentation-technical-writing
description: 'Authoring ADRs, runbooks, RFCs, and inline code documentation. Trigger: "write ADR", "create runbook", "improve GoDoc", "technical spec".'
metadata:
  category: documentation
  tags: "documentation, adr, runbook, rfc, technical-writing"
---

# Technical Writing

## Purpose

Documents decisions, operations, and deep technical concepts. This skill writes and edits the named document only; it does NOT change application logic or invent decisions that were not made.

## When to Use / When NOT to Use

- **Use**: Architecture decisions, incident runbooks, deep dives.
- **NOT**: Marketing copy or user-facing tutorials.
- **NOT**: README files (use `documentation-readme-generator` or `documentation-collapsible-readme`).
- **NOT**: Full GoDoc audits (use `golang-godoc-engineer`) or changelogs (use `documentation-changelog-writer`).

## Prerequisites & Assumptions

- Context and audience understanding.

### Scope & Context Resolution

- **Supported scopes**: single document (ADR, runbook, RFC; default), documentation directory, file (inline docs), function/method or type (doc comment).
- **Rule 1 - Explicit context in the prompt**: Stated audience, format, template, dates and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at single-document scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to the named document or doc comments. MUST NOT edit code logic or other documents.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Identify audience (devs, ops, external).
3. Choose format (ADR, Runbook, RFC).
4. Draft with clear headings and diagrams, within the resolved scope.
5. Peer review and publish.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Use standard templates for ADRs/Runbooks.
- **MUST**: Date and version documents.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use diagrams over text where possible.
- **MUST NOT**: Use ambiguous language (e.g., "soon", "later").
- **MUST NOT**: Rewrite or restyle neighbouring documents while editing the named one.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: "We will fix the database later."
- **Good**: "ADR-001: Migrate to PostgreSQL by Q3 2024."
- **Good (scoped)**: Prompt "only the runbook for the payments queue" -> write that runbook; note missing runbooks for other queues.
- **Bad (scope-expanding)**: Same prompt -> also rewrite the ADR index and every existing runbook into a new template.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Template used.
- [ ] Peer reviewed.
- [ ] Diagrams included.

## Common Pitfalls

- Stale docs that contradict code.
- Too verbose, burying the key point.
- Restructuring the whole docs tree when asked for one document.

## References (official docs, standards)

- [Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
