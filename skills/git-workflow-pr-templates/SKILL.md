---
name: git-workflow-pr-templates
description: 'Designing effective Pull Request templates to ensure review readiness. Trigger: "create PR template", "standardize pull requests", "PR description".'
metadata:
  category: git-workflow
---

# PR Templates

## Purpose

Ensures PRs contain sufficient context for reviewers.

## When to Use / When NOT to Use

- **Use**: Standardizing reviews, reducing back-and-forth comments.
- **NOT**: Emergency hotfixes (use issue templates).

## Prerequisites & Assumptions

- GitHub/GitLab PR support.

## Step-by-Step Workflow

1. Create `.github/PULL_REQUEST_TEMPLATE.md`.
2. Add sections: Context, Changes, Testing, Screenshots.
3. Add checklists for self-review.
4. Enforce via bot if possible.

## Enterprise Rules & Standards

- **MUST**: Include "What" and "Why" sections.
- **MUST**: Include testing steps and edge cases covered.
- **SHOULD**: Add screenshots/videos for UI changes.
- **MUST NOT**: Leave template placeholders blank.

## Examples

- **Bad**: PR with empty description.
- **Good**: Detailed PR with context, test plan, and screenshots.

## Checklist

- [ ] Template created.
- [ ] Sections defined.
- [ ] Enforced by team.

## Common Pitfalls

- Overly long templates that devs ignore.
- Missing "How to test" instructions.

## References

- [GitHub PR Templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository)
