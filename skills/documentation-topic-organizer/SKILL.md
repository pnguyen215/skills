---
name: documentation-topic-organizer
description: 'Analyze Markdown files by content, propose a topic-based folder structure, and after approval move them with links, assets, and references kept valid. Trigger: "organize markdown files by topic", "restructure docs folder", "group documentation by topic", "reorganize docs hierarchy".'
metadata:
  category: documentation
  tags: "documentation, markdown, information-architecture, restructuring, link-integrity, behavior-preserving"
---

# Documentation Topic Organizer

## Purpose

Reorganizes a flat or inconsistent collection of Markdown files into a topic-based hierarchy chosen from what the files actually say, not from their filenames. Work is split into an analysis/proposal phase that changes nothing and an apply phase that runs only after explicit approval. Content is preserved byte-for-byte except for path-dependent links.

## When to Use / When NOT to Use

- **Use**: A `docs/` folder (or any Markdown tree) has grown flat, mixed, or inconsistent and needs a navigable topic structure.
- **NOT**: Rewriting or improving the prose of a README (use `documentation-collapsible-readme` or `documentation-readme-generator`).
- **NOT**: Writing new ADRs, runbooks, or RFCs (use `documentation-technical-writing`).
- **NOT**: Merging or deduplicating documents (this skill only reports duplication and recommends a strategy).
- **NOT**: Generating API reference docs (use `documentation-api-documentation`).
- **NOT**: Adding comments to source code (use `documentation-code-deep-dive`).

## Prerequisites & Assumptions

- The target directory is readable and, preferably, inside a git repository so moves are reversible. If it is not, say so and ask before applying.
- Uncommitted changes in the target are reported before Stage 3; moves must not be mixed with unrelated edits.

### Scope & Context Resolution

- **Supported scopes**: a directory tree (default: the `docs/` folder, or the repository root if none exists), or an explicit list of files.
- **Rule 1 - Explicit context in the prompt**: The user's target, naming conventions, protected paths, and desired topics are authoritative. MUST NOT add categories or expand scope beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT data-loss rules (no deletions, no content loss), which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: Without instructions, use this skill's workflow and rules at the default scope. MUST NOT import unrelated requirements.
- **Rule 3 - Explicit scope**: Move only files inside the resolved scope. Files outside it may be READ (to find inbound references) and edited ONLY to repair links that the move breaks.
- **Mutation boundary**: Stages 1-2 are strictly read-only. Stage 3 may move Markdown files, create directories and index files, and repair path references. Nothing else.

## Step-by-Step Workflow

1. **Resolve scope**: State target, file count, and the read-only boundary in one line. Exclude `node_modules`, `vendor`, build output, and generated docs unless asked.
2. **Inventory**: List every `.md` / `.markdown` file with path, size, and frontmatter presence. Note existing conventions (naming case, index file name, nav config such as `mkdocs.yml`, `_sidebar.md`, `SUMMARY.md`).
3. **Read and classify**: Read each file's content and record primary topic, secondary topics, purpose, audience, outbound links, and overlap with other files. Never classify from the filename alone.
4. **Map references**: Search for inbound references to each file in Markdown, source code, scripts, config, CI workflows, issue templates, and package metadata. Record assets (images, attachments) each file uses by relative path.
5. **Design the hierarchy**: Pick a few cohesive topic folders with clear boundaries, at most two levels deep, reusing existing names and conventions where sensible. Genuinely standalone files stay in place or at the root.
6. **Propose**: Present the analysis outputs (below) and **STOP for approval**. No file is touched before an explicit yes.
7. **Apply**: Create directories, move with `git mv` (history preserved), repair relative links and asset paths, update nav config and external references, add topic indexes only where useful.
8. **Validate**: Run the checks below and fix any regression in the moved/edited set.
9. **Report**: Summarize inventory, final tree, moves, links updated, duplicates/outdated candidates, validation results, and recommendations.

## Analysis Output (before any change)

- **Inventory**: all Markdown files and current paths.
- **Classification table**: `| File | Topic | Purpose | Related Documents |`.
- **Topic groups**: scope and assigned files per topic; multi-topic files get one home plus a link from the other.
- **Proposed tree**: the full folder tree.
- **Migration plan**: `| Current Path | Proposed Path | Reason |`.
- **Issues**: duplicates, overlaps, ambiguous classification, broken-link risks, outdated candidates, standalone files, case-only renames, filename collisions.

## Organization Rules

- Group by topic and responsibility, not by file type, date, or alphabet.
- Prefer lowercase kebab-case for new directories; keep existing file names unless they collide or clearly break the established convention. State any rename in the migration plan with its reason.
- Avoid single-file folders unless the topic is expected to grow; avoid deep nesting.
- Add `README.md`/`index.md` only for topics with several documents, containing overview, scope, document list, and reading order. Match the repository's existing index file name.
- Add cross-links only where they help the reader; avoid circular navigation.

## Validation Checks

- Every original file exists exactly once at its new path (count before == count after, plus new indexes).
- No file deleted; content diff for moved files is empty except edited link targets (verify with `git diff -M --stat`).
- Every relative Markdown link and image path resolves; anchors (`#heading`) still match headings.
- Frontmatter and code blocks are unchanged.
- Inbound references outside the tree (source, scripts, CI, config, nav files) point to the new paths.
- Final tree matches the approved proposal.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Read the content of every file before classifying it.
- **MUST**: Obtain explicit approval of the proposal before moving or modifying anything.
- **MUST**: Preserve content, frontmatter, anchors, code blocks, tables, images, and metadata.
- **MUST**: Update every internal and external reference affected by a move, and run the validation checks.
- **MUST**: Use `git mv` when in a git repository.
- **SHOULD**: Apply the move in one reviewable change, separate from content edits.
- **SHOULD**: Offer to leave redirect stubs or notes when published URLs (docs site, wiki, external links) may break.
- **MUST NOT**: Delete, merge, split, or rewrite documents; report duplication and a consolidation strategy instead.
- **MUST NOT**: Modify source code beyond path references to moved docs.
- **MUST NOT**: Introduce a new documentation framework or tooling.
- **MUST NOT**: Create categories for one or two files, or nest deeper than needed.
- **MUST NOT**: Fabricate validation results.

## Examples (good vs. bad, with realistic code or output)

- **Good (content-based)**: `setup.md`, `env-vars.md`, `docker-run.md` all describe first-run configuration -> `getting-started/`. `notes-2.md` has a generic name, but its content is an ADR on caching -> `architecture/decisions/`.
- **Bad (filename-based)**: Putting every file containing "api" in `api/` without reading it; one of them is a troubleshooting guide.
- **Good link repair**: `docs/guide.md` moved to `docs/features/guide.md`; `[Setup](setup.md)` becomes `[Setup](../getting-started/setup.md)`, and `.github/workflows/docs.yml` path filter is updated.
- **Bad**: Merging `install.md` and `quick-start.md` automatically because they overlap. Report as "overlap, recommend consolidating under `getting-started/`" and wait.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and read-only boundary stated.
- [ ] Every Markdown file read and classified by content.
- [ ] Inbound references (docs, code, CI, config, nav) mapped.
- [ ] Proposal with tree and migration table presented; approval received.
- [ ] Moves done with `git mv`; no deletions.
- [ ] Relative links, image paths, nav config, and external references repaired.
- [ ] Validation checks run; results reported honestly.
- [ ] Duplicates, outdated candidates, and follow-ups reported, not acted on.

## Common Pitfalls

- Classifying by filename and mis-filing files with misleading names.
- Forgetting non-Markdown references (CI path filters, `package.json` `files`, scripts, issue templates).
- Breaking anchors or image paths after a move.
- Case-only renames that fail on case-insensitive filesystems.
- Over-categorizing into many one-file folders, or creating indexes nobody needs.
- Silently merging "obviously duplicate" docs.
- Mixing content edits with moves, which hides the move in review.

## References (official docs, standards)

- [CommonMark Spec](https://spec.commonmark.org/)
- [Diataxis documentation framework](https://diataxis.fr/)
- [Google developer documentation style guide](https://developers.google.com/style)
- [git-mv](https://git-scm.com/docs/git-mv)
