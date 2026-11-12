---
name: git-workflow-pr-templates
description: 'Designing effective Pull Request templates to ensure review readiness. Trigger: "create PR template", "standardize pull requests", "PR description".'
metadata:
  category: git-workflow
  tags: "git, pull-request, templates, code-review, collaboration"
---

# PR Templates

## Purpose

Ensures PRs contain sufficient context for reviewers. It designs PR templates and PR descriptions only; it does NOT review code, change branch protection, or edit commit history.

## When to Use / When NOT to Use

- **Use**: Standardizing reviews, reducing back-and-forth comments.
- **NOT**: Emergency hotfixes (use issue templates).
- **NOT**: Reviewing the code in a PR (use `code-quality-code-review`).
- **NOT**: Branch protection rules (use `git-workflow-branching`) or commit message rules (use `git-workflow-commit-conventions`).

## Prerequisites & Assumptions

- GitHub/GitLab PR support.

### Scope & Context Resolution

- **Supported scopes**: PR template file, single PR description, project/repository. Default when none is given: the repository's single default PR template (`.github/PULL_REQUEST_TEMPLATE.md`).
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, constraints, platform, targets, and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow, and rules as the sole context at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits are limited to PR template files or the named PR description. MUST NOT edit CI workflows, bot configuration, or source code.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Create `.github/PULL_REQUEST_TEMPLATE.md` (or edit the named template).
3. Add sections: Context, Changes, Testing, Screenshots.
4. Add checklists for self-review.
5. Enforce via bot if possible, only when the user requests enforcement.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Include "What" and "Why" sections.
- **MUST**: Include testing steps and edge cases covered.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Add screenshots/videos for UI changes.
- **MUST NOT**: Leave template placeholders blank.
- **MUST NOT**: Add bots, workflows, or branch rules while editing a template.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: PR with empty description.
- **Good**: Detailed PR with context, test plan, and screenshots.

**Scope handling**

- **Prompt**: "Write the description for this PR only."
- **Good**: Produces Context, Changes, Testing for the given diff and leaves `.github/PULL_REQUEST_TEMPLATE.md` untouched.
- **Bad**: Rewrites the repository's PR template and adds a GitHub Action to enforce it.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Template created.
- [ ] Sections defined.
- [ ] Enforced by team.

## Common Pitfalls

- Overly long templates that devs ignore.
- Missing "How to test" instructions.
- Scope creep: changing the team's template when asked to write one PR description.

## References (official docs, standards)

- [GitHub PR Templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository)
