---
name: ci-cd-release-management
description: 'Automate semantic versioning, changelogs, artifact publishing. Trigger: "automate release", "semantic release setup", "publish package".'
metadata:
  category: ci-cd
  tags: "ci-cd, release, semver, changelog, publishing"
---

# Release Management

## Purpose

Standardizes the process of tagging, documenting, and publishing software releases. Responsibility boundary: designs and edits release configuration (version bump, changelog, tag, publish steps); does NOT write feature code, build general CI pipelines, or publish artifacts on its own without an explicit request.

## When to Use / When NOT to Use

- **Use**: Publishing packages to npm/PyPI/Maven, generating release notes, tagging git commits.
- **NOT**: Internal experimental builds not meant for consumption.
- **NOT**: General build/test pipeline design (use `ci-cd-pipelines`).
- **NOT**: Enforcing commit message format (use `git-workflow-commit-conventions`).
- **NOT**: Hand-writing a changelog from Git history (use `documentation-changelog-writer`).

## Prerequisites & Assumptions

- Conventional Commits enforced. Registry credentials configured securely.

### Scope & Context Resolution

- **Supported scopes**: repository (default), release/publish pipeline file, single package in a monorepo, release config file (e.g. `.releaserc`), single release/tag.
- **Rule 1 - Explicit context**: The user's stated requirements, constraints, versions, targets and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line. Security/data-loss rules (credential handling, immutable artifacts) stay mandatory; flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at repository scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to release configuration, version/changelog files and release pipeline steps in scope. MUST NOT push tags or publish artifacts unless explicitly asked.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Analyze commits since last tag (within the resolved package/scope).
3. Bump semantic version (Major/Minor/Patch).
4. Generate `CHANGELOG.md`.
5. Create Git tag and publish artifacts.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Follow Semantic Versioning (SemVer) strictly.
- **MUST**: Auto-generate changelogs from commit messages.
- **SHOULD**: Sign release artifacts and Git tags (GPG/Sigstore).
- **MUST NOT**: Modify published immutable artifacts (e.g., Docker tags).
- **MUST NOT**: Rewrite the whole CI pipeline or other packages' release config when asked about one release step.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Manually editing `package.json` version and pushing.
- **Good**: Using `semantic-release` to automate version bump and publish.
- **Scope - Good**: Prompt "only the `api` package in this monorepo" -> edit only `packages/api` release config; note that `web` lacks a changelog step without changing it.
- **Scope - Bad**: Same prompt -> migrating every package to a new versioning scheme and rewriting the root workflow.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] SemVer enforced.
- [ ] Changelog auto-generated.
- [ ] Artifacts signed.

## Common Pitfalls

- Forgetting to update lockfiles before release.
- Publishing broken releases without rollback strategy.
- Reconfiguring releases for every package in a monorepo when only one was requested.

## References (official docs, standards)

- [Semantic Versioning 2.0.0](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
