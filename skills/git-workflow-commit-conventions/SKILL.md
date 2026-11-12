---
name: git-workflow-commit-conventions
description: 'Enforcing Conventional Commits and automated commit linting. Trigger: "setup commit linting", "Conventional Commits rules", "commit message format".'
metadata:
  category: git-workflow
  tags: "git, conventional-commits, commitlint, changelog, automation"
---

# Commit Conventions

## Purpose

Creates a readable, automatable commit history. Responsibility boundary: defines commit message rules and commit-lint configuration; does NOT rewrite existing history, commit, or push unless the user explicitly asks.

## When to Use / When NOT to Use

- **Use**: Changelog generation, semantic release, team history.
- **NOT**: Initial repo commit or WIP branches.
- **NOT**: Branching models or branch protection (use `git-workflow-branching`).
- **NOT**: PR description templates (use `git-workflow-pr-templates`).
- **NOT**: Generating changelogs from history (use `documentation-changelog-writer`).

## Prerequisites & Assumptions

- Commitlint tool installed.

### Scope & Context Resolution

- **Supported scopes**: project/repository, commit-lint config file, hook file, CI job, single commit message. Default when none is given: the commit-lint configuration and hooks of the current repository.
- **Rule 1 - Explicit context in the prompt**: the user's stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules (no history rewrites of shared branches), which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to commit-lint config, hooks and CI validation steps; MUST NOT amend, rebase or force-push existing commits.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Adopt Conventional Commits specification.
3. Install `commitlint` & `husky`.
4. Enforce in pre-commit hook.
5. Validate in CI pipeline (only if CI is within the resolved scope).

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Use format `type(scope): description` (e.g., `feat(auth): add login`).
- **MUST**: Keep subject line < 50 chars, imperative mood.
- **SHOULD**: Reference issue IDs in footer.
- **MUST NOT**: Use past tense in subject ("added" vs "add").
- **MUST NOT**: Rewrite or reword existing commits when asked only to set up rules.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `fixed stuff`
- **Good**: `feat(auth): add OAuth2 login support`

**Scope handling**

- **Prompt**: "Only add commitlint config; do not touch CI."
- **Good**: Adds `commitlint.config.js` and the hook; notes that CI validation is still missing.
- **Bad**: Also edits the CI workflow and rebases history to fix old messages.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Commitlint installed.
- [ ] Pre-commit hook active.
- [ ] Format followed.

## Common Pitfalls

- Vague messages ("update code").
- Massive commits covering multiple features.
- Rewriting history or editing CI when only local lint setup was requested.

## References (official docs, standards)

- [Conventional Commits](https://www.conventionalcommits.org/)
