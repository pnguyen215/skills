---
name: code-review
description: 'Comprehensive PR review checklists focusing on architecture, security, and maintainability. Trigger: "review this PR", "code review checklist", "PR feedback".'
---

# Code Review

## Purpose

Ensures code meets enterprise standards before merge.

## When to Use / When NOT to Use

- **Use**: Reviewing PRs, mentoring junior devs, architectural alignment.
- **NOT**: Automated formatting (use linters instead).

## Prerequisites & Assumptions

- Working branch with passing CI. Access to CI logs.

## Step-by-Step Workflow

1. Read PR description and linked issues.
2. Check architecture, SOLID principles, and tests.
3. Verify security and observability.
4. Approve or request specific changes.

## Enterprise Rules & Standards

- **MUST**: Review for SOLID principles and error handling.
- **MUST**: Check for hardcoded secrets and PII.
- **SHOULD**: Suggest refactoring, not just point out flaws.
- **MUST NOT**: Nitpick formatting handled by linters.

## Examples

- **Bad**: "LGTM" without reading tests.
- **Good**: "Consider extracting this logic to reduce cyclomatic complexity."

## Checklist

- [ ] Architecture sound.
- [ ] Security checked.
- [ ] Tests added/updated.

## Common Pitfalls

- Rubber-stamping large PRs.
- Ego-driven reviews and bike-shedding.

## References

- [Google Engineering Practices: Code Review](https://google.github.io/eng-practices/review/)
