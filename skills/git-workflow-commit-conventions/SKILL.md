---
name: git-workflow-commit-conventions
description: 'Enforcing Conventional Commits and automated commit linting. Trigger: "setup commit linting", "Conventional Commits rules", "commit message format".'
metadata:
  category: git-workflow
  tags: "git, conventional-commits, commitlint, changelog, automation"
---

# Commit Conventions

## Purpose

Creates a readable, automatable commit history.

## When to Use / When NOT to Use

- **Use**: Changelog generation, semantic release, team history.
- **NOT**: Initial repo commit or WIP branches.

## Prerequisites & Assumptions

- Commitlint tool installed.

## Step-by-Step Workflow

1. Adopt Conventional Commits specification.
2. Install `commitlint` & `husky`.
3. Enforce in pre-commit hook.
4. Validate in CI pipeline.

## Enterprise Rules & Standards

- **MUST**: Use format `type(scope): description` (e.g., `feat(auth): add login`).
- **MUST**: Keep subject line < 50 chars, imperative mood.
- **SHOULD**: Reference issue IDs in footer.
- **MUST NOT**: Use past tense in subject ("added" vs "add").

## Examples

- **Bad**: `fixed stuff`
- **Good**: `feat(auth): add OAuth2 login support`

## Checklist

- [ ] Commitlint installed.
- [ ] Pre-commit hook active.
- [ ] Format followed.

## Common Pitfalls

- Vague messages ("update code").
- Massive commits covering multiple features.

## References

- [Conventional Commits](https://www.conventionalcommits.org/)
