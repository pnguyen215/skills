---
name: ci-cd-release-management
description: 'Automate semantic versioning, changelogs, artifact publishing. Trigger: "automate release", "semantic release setup", "publish package".'
metadata:
  category: ci-cd
  tags: "ci-cd, release, semver, changelog, publishing"
---

# Release Management

## Purpose

Standardizes the process of tagging, documenting, and publishing software releases.

## When to Use / When NOT to Use

- **Use**: Publishing packages to npm/PyPI/Maven, generating release notes, tagging git commits.
- **NOT**: Internal experimental builds not meant for consumption.

## Prerequisites & Assumptions

- Conventional Commits enforced. Registry credentials configured securely.

## Step-by-Step Workflow

1. Analyze commits since last tag.
2. Bump semantic version (Major/Minor/Patch).
3. Generate `CHANGELOG.md`.
4. Create Git tag and publish artifacts.

## Enterprise Rules & Standards

- **MUST**: Follow Semantic Versioning (SemVer) strictly.
- **MUST**: Auto-generate changelogs from commit messages.
- **SHOULD**: Sign release artifacts and Git tags (GPG/Sigstore).
- **MUST NOT**: Modify published immutable artifacts (e.g., Docker tags).

## Examples

- **Bad**: Manually editing `package.json` version and pushing.
- **Good**: Using `semantic-release` to automate version bump and publish.

## Checklist

- [ ] SemVer enforced.
- [ ] Changelog auto-generated.
- [ ] Artifacts signed.

## Common Pitfalls

- Forgetting to update lockfiles before release.
- Publishing broken releases without rollback strategy.

## References

- [Semantic Versioning 2.0.0](https://semver.org/)
