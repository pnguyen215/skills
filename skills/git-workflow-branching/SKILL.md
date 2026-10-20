---
name: git-workflow-branching
description: 'Git branching models (Trunk-Based, GitFlow) and repository protection rules. Trigger: "setup branching strategy", "configure branch protection", "GitFlow".'
metadata:
  category: git-workflow
---

# Branching Strategy

## Purpose

Organizes parallel development and release management.

## When to Use / When NOT to Use

- **Use**: New repos, team alignment, CI/CD setup.
- **NOT**: Solo hobby projects.

## Prerequisites & Assumptions

- Git hosting (GitHub/GitLab/Bitbucket).

## Step-by-Step Workflow

1. Choose model (Trunk-Based recommended for CI/CD).
2. Define branch lifespans (short-lived features).
3. Setup branch protection rules on `main`.
4. Enforce via CI checks.

## Enterprise Rules & Standards

- **MUST**: Protect `main`/`master` branch (require PRs).
- **MUST**: Delete merged branches automatically.
- **SHOULD**: Use short-lived feature branches (< 2 days).
- **MUST NOT**: Commit directly to protected branches.

## Examples

- **Bad**: Pushing directly to `main`.
- **Good**: PR from `feature/xyz` with 2 approvals.

## Checklist

- [ ] Main protected.
- [ ] PR reviews required.
- [ ] Auto-delete merged enabled.

## Common Pitfalls

- Long-lived feature branches causing merge hell.
- Using GitFlow for continuous deployment.

## References

- [Trunk Based Development](https://trunkbaseddevelopment.com/)
