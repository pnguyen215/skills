---
name: git-workflow-branching
description: 'Git branching models (Trunk-Based, GitFlow) and repository protection rules. Trigger: "setup branching strategy", "configure branch protection", "GitFlow".'
metadata:
  category: git-workflow
  tags: "git, branching, trunk-based, gitflow, branch-protection"
---

# Branching Strategy

## Purpose

Organizes parallel development and release management. Responsibility boundary: defines branching models and protection rules; does NOT rewrite Git history, merge or delete branches, or change commit/PR content standards.

## When to Use / When NOT to Use

- **Use**: New repos, team alignment, CI/CD setup.
- **NOT**: Solo hobby projects.
- **NOT**: Commit message rules (use `git-workflow-commit-conventions`).
- **NOT**: PR description templates (use `git-workflow-pr-templates`).

## Prerequisites & Assumptions

- Git hosting (GitHub/GitLab/Bitbucket).

### Scope & Context Resolution

- **Supported scopes**: repository (default), single branch or protection rule, branch-protection config file, CI check set for one branch.
- **Rule 1 - Explicit context**: The user's stated requirements, constraints, versions, targets and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line. Security/data-loss rules (protected branches, no history rewrite) stay mandatory; flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at repository scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes. Widening scope requires explicit user approval.
- **Mutation boundary**: Recommendations and edits to protection/CI config files in scope only. MUST NOT force-push, delete branches, or change hosting settings unless explicitly asked.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Choose model (Trunk-Based recommended for CI/CD).
3. Define branch lifespans (short-lived features).
4. Setup branch protection rules on `main` (apply only to the branches in scope).
5. Enforce via CI checks.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Protect `main`/`master` branch (require PRs).
- **MUST**: Delete merged branches automatically.
- **SHOULD**: Use short-lived feature branches (< 2 days).
- **MUST NOT**: Commit directly to protected branches.
- **MUST NOT**: Impose a new branching model on the whole repository when asked about one branch or rule.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Pushing directly to `main`.
- **Good**: PR from `feature/xyz` with 2 approvals.
- **Scope - Good**: Prompt "protect only `release/*`" -> one rule for `release/*` (PR required, no force-push); note that `main` is unprotected without changing it.
- **Scope - Bad**: Same prompt -> migrating the repo to GitFlow and renaming branches.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Main protected.
- [ ] PR reviews required.
- [ ] Auto-delete merged enabled.

## Common Pitfalls

- Long-lived feature branches causing merge hell.
- Using GitFlow for continuous deployment.
- Changing protection on every branch when one pattern was requested.

## References (official docs, standards)

- [Trunk Based Development](https://trunkbaseddevelopment.com/)
- [GitHub: Protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [Git Branching (Pro Git)](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows)
