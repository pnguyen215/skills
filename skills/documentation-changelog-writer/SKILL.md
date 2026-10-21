---
name: documentation-changelog-writer
description: 'Generate, update, and review high-quality CHANGELOG.md files based on Git history and repository conventions. Trigger: "write changelog", "update changelog", "generate release notes", "summarize git commits", "review changelog", "draft release notes".'
metadata:
  category: documentation
  tags: "documentation, changelog, release-notes, technical-writing, release-management"
---

## Purpose

Act as an expert Technical Writer and Release Engineer to generate, update, and review high-quality `CHANGELOG.md` files. The primary goal is to translate raw Git history, code changes, and PRs into user-facing, evidence-backed release documentation. The skill strictly distinguishes between **Drafting** (generating from verified changes), **Updating** (integrating into existing history without damage), and **Reviewing** (identifying factual errors or omissions), ensuring every entry accurately reflects added features, fixes, deprecations, and breaking changes.

## When to Use / When NOT to Use

**Use when:**

- Creating a new `CHANGELOG.md` for a repository that lacks one.
- Adding new release entries to an existing changelog based on Git diffs or commit history.
- Preparing release notes for a specific version or summarizing changes between Git refs/tags/branches.
- Reviewing and improving an existing changelog for accuracy, consistency, and completeness.
- Identifying potential breaking changes and migration requirements from recent code changes.

**Do NOT use when:**

- The task is to write a `README.md`, Architecture Decision Record (ADR), or general technical documentation.
- The user wants to automatically create Git tags, publish releases to package registries, or write marketing announcements (unless explicitly requested and authorized).
- The request is to rewrite or "clean up" the entire historical changelog just to impose a new preferred style (preserve history unless explicitly asked to migrate).

## Prerequisites & Assumptions

- **Evidence-Based Writing:** You MUST inspect actual Git history (`git log`, `git diff`), source code, tests, and manifests before writing. MUST NOT rely solely on commit messages, as they often lack context, are poorly written, or are inaccurate.
- **Preserve History:** When updating an existing `CHANGELOG.md`, you MUST preserve all historical entries, formatting, and document structure. MUST NOT silently delete or rewrite past release dates, versions, or claims.
- **Zero Fabrication:** You MUST NOT invent version numbers, release dates, features, fixes, security vulnerability IDs, or migration requirements. If evidence is insufficient, MUST flag it for confirmation.
- **Convention First:** You MUST detect and follow the repository's existing changelog format (e.g., Keep a Changelog, SemVer, specific heading styles) rather than imposing a new one.

## Step-by-Step Workflow

1. **Determine Scope:** Establish the target file, release version (if known), release date, base/target Git references, and task type (Draft, Update, or Review).
2. **Inspect Conventions:** Read the current `CHANGELOG.md` (if it exists) to determine heading structure, versioning/date formats, category names, bullet length, and breaking change markers.
3. **Gather Evidence:** Use Git tools (e.g., `git log --oneline <base>..<target>`, `git diff --stat`) and inspect relevant source files to understand the actual impact of the changes.
4. **Build Change Inventory:** Group verified changes logically. Identify duplicates, implementation-only refactors, and test-only edits that should be excluded from user-facing notes.
5. **Draft/Update:** Write the changelog entries using the established format. Insert new releases at the top (reverse chronological order). Merge related commits into coherent bullets.
6. **Validate & Review:** Verify each entry against the underlying code changes. Ensure no unsupported claims are made. Check for formatting consistency and valid Markdown.
7. **Report:** Summarize the file modified, the version/date used, main categories documented, identified breaking changes, and any assumptions requiring user confirmation.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

### Change Classification

- **MUST** classify changes into standard categories (when applicable): `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.
- **MUST NOT** create empty categories. Omit them if there are no entries for that release.
- **MUST NOT** mechanically map one commit to one bullet. Consolidate related commits into a single logical, user-facing change.
- **MUST NOT** include trivial refactors, internal implementation details, or test-only edits unless they materially affect maintainers or CI/CD.

### Breaking Changes

- **MUST** explicitly and prominently mark breaking changes (e.g., `**Breaking:**` prefix or dedicated section, matching repo convention).
- **MUST** document for breaking changes: What changed, who/what is affected, why it's incompatible, and required migration actions.
- **MUST NOT** label a change as breaking solely because it is architecturally significant; it MUST break an existing public contract, workflow, configuration format, or compatibility guarantee.

### Writing Quality & Formatting

- **MUST** use reverse chronological order (newest release first).
- **MUST** use ISO 8601 dates (`YYYY-MM-DD`) for release headings (e.g., `## [2.0.0] - 2026-10-20`).
- **MUST** use backticks for filenames, paths, commands, APIs, configuration keys, and technical identifiers.
- **MUST NOT** use vague claims like "Improved performance", "Fixed bugs", or "Updated scripts" without specific context.
- **SHOULD** answer for each bullet: What changed? Why does it matter? Who is affected? What action is required?
- **SHOULD** follow Semantic Versioning (MAJOR for breaking, MINOR for features, PATCH for fixes) if the project uses it, but MUST NOT guess versions based on commit count.

## Examples (good vs. bad, with realistic code or output)

**Good: Specific, User-Focused, and Consolidated**

```markdown
## [2.0.0] - 2026-10-20

### Added

- Added `scripts/example.sh` to support dry-run validation workflows.

### Changed

- **Breaking: flattened the skill directory layout.** Skills now reside at
  `skills/<slug>/SKILL.md`. Update any scripts or integrations that depend on
  the previous nested paths.

### Fixed

- Fixed path resolution when the repository is installed from a directory
  containing spaces.
```

**Bad: Raw Commit Dump & Vague Claims**

```markdown
## [2.0.0] - 2026-10-20

### Changed

- Updated scripts.
- Refactored the code.
- wip fix for paths
- Improved performance.
```

_Why it's bad: Dumps raw, unpolished commit messages, uses vague claims that provide zero context to the user, and fails to identify or format the breaking change properly._

## Checklist (verifiable, copy-pasteable)

- [ ] Every factual claim is supported by inspected Git diffs, code, or authoritative documentation.
- [ ] NO unsupported features, fixes, migration requirements, versions, or dates have been invented.
- [ ] Breaking changes are explicitly identified, marked, and include migration guidance.
- [ ] Related commits have been consolidated; no 1:1 commit-to-bullet mapping.
- [ ] Version sections are ordered correctly (newest first) with ISO 8601 dates.
- [ ] Technical identifiers (files, commands, APIs) are wrapped in backticks.
- [ ] Existing historical entries remain completely intact and unmodified.
- [ ] Empty categories have been removed from the new release section.

## Common Pitfalls

- **The Commit Dump:** Copy-pasting `git log` output directly into the changelog. Changelogs are for humans, not a mirror of the Git database.
- **Vague Improvements:** Writing "Fixed various bugs" or "Improved performance". If it's not specific enough to tell the user what was fixed or what got faster, it shouldn't be in the changelog.
- **Silent History Deletion:** Accidentally overwriting or deleting past release notes when appending a new version. Always insert at the top, never overwrite the bottom.
- **Invented Dates/Versions:** Assuming the current date is the release date, or guessing the next version number (e.g., jumping to 2.0.0) without verifying the actual compatibility impact or project release policy.
- **The "Breaking" Misclassification:** Labeling a massive internal refactor as "Breaking" just because it was hard to write, even though the public API and user workflows remain 100% unchanged.

## References (official docs, standards)

- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) (The industry standard format for human-readable changelogs).
- [Semantic Versioning 2.0.0](https://semver.org/) (Standard for version numbering based on API changes).
- [Conventional Commits](https://www.conventionalcommits.org/) (Standard for structuring commit messages to automate changelog generation).
