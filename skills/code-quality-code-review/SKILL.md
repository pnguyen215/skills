---
name: code-quality-code-review
description: 'Comprehensive PR review checklists focusing on architecture, security, and maintainability. Trigger: "review this PR", "code review checklist", "PR feedback".'
metadata:
  category: code-quality
  tags: "code-review, pull-request, architecture, security, maintainability"
---

# Code Review

## Purpose

Ensures code meets enterprise standards before merge. Responsibility boundary: review-only; produces findings and requested changes, and does NOT edit the reviewed code.

## When to Use / When NOT to Use

- **Use**: Reviewing PRs, mentoring junior devs, architectural alignment.
- **NOT**: Automated formatting (use linters instead).
- **NOT**: Applying fixes or restructuring code (use `code-quality-refactoring`).
- **NOT**: Configuring linters or SAST (use `code-quality-static-analysis`).
- **NOT**: Mapping or explaining an unfamiliar codebase (use `code-quality-codebase-analyst`).

## Prerequisites & Assumptions

- Working branch with passing CI. Access to CI logs.

### Scope & Context Resolution

- **Supported scopes**: pull request/diff, directory/module, file, function/method, commit range. Default when none is given: the full PR diff; if no PR or diff exists, the current uncommitted changes.
- **Rule 1 - Explicit context in the prompt**: the user's stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules (hardcoded secrets, PII), which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: review-only; MUST NOT edit code. Output is review comments.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Read PR description and linked issues.
3. Check architecture, SOLID principles, and tests (only for code within the resolved scope).
4. Verify security and observability.
5. Approve or request specific changes.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Review for SOLID principles and error handling.
- **MUST**: Check for hardcoded secrets and PII.
- **SHOULD**: Suggest refactoring, not just point out flaws.
- **MUST NOT**: Nitpick formatting handled by linters.
- **MUST NOT**: Raise blocking comments on code the PR did not touch; record them as non-blocking notes.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: "LGTM" without reading tests.
- **Good**: "Consider extracting this logic to reduce cyclomatic complexity."

**Scope handling**

- **Prompt**: "Review only `internal/billing/` in this PR."
- **Good**: Comments only on changes under `internal/billing/`; mentions an unrelated auth smell as a non-blocking note.
- **Bad**: Requests changes across the whole PR and pushes fixes to the branch.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Architecture sound.
- [ ] Security checked.
- [ ] Tests added/updated.

## Common Pitfalls

- Rubber-stamping large PRs.
- Ego-driven reviews and bike-shedding.
- Reviewing or blocking on pre-existing code outside the requested scope.

## References (official docs, standards)

- [Google Engineering Practices: Code Review](https://google.github.io/eng-practices/review/)
