---
name: documentation-topic-organizer
description: 'Analyze every file in a folder, project, or target path by content, propose a grouped topic-based structure with clear, short, technical names, and after approval restructure it with links, assets, and references kept valid. Trigger: "organize markdown files by topic", "restructure this folder", "group files by topic", "reorganize this project", "clean up and rename folders".'
metadata:
  category: documentation
  tags: "documentation, markdown, information-architecture, restructuring, naming-conventions, link-integrity, behavior-preserving"
---

# Documentation Topic Organizer

## Purpose

Reorganizes everything in a target folder or project into cohesive topic groups chosen from what the files actually contain, not from their filenames, and gives every group and file a clear, short, technical name. Work is split into a read-only analysis/proposal phase and an apply phase that runs only after explicit approval. Content is preserved byte-for-byte except for path-dependent references.

## When to Use / When NOT to Use

- **Use**: A folder, docs tree, or project has grown flat, mixed, or inconsistently named and needs grouped, navigable, consistently named structure.
- **NOT**: Rewriting prose of a README (use `documentation-collapsible-readme` or `documentation-readme-generator`).
- **NOT**: Writing new ADRs, runbooks, or RFCs (use `documentation-technical-writing`).
- **NOT**: Merging or deduplicating documents or code (this skill only reports duplication and recommends a strategy).
- **NOT**: Refactoring source code structure or APIs (use `code-quality-refactoring`).
- **NOT**: Generating API reference docs (use `documentation-api-documentation`).

## Prerequisites & Assumptions

- The target is readable and, preferably, inside a git repository so moves are reversible. If it is not, say so and ask before applying.
- Uncommitted changes in the target are reported before the apply stage; moves must not be mixed with unrelated edits.

### Scope & Context Resolution

- **Supported scopes**: a folder tree, a whole project, or an explicit file list. Default: the `docs/` folder if the request is about documentation, otherwise the named target; the repository root only when the user says "project".
- **Supported content (`include`)**: `docs` (Markdown and its assets; default), `all` (every file type in scope). With `all`, apply the Pinned Paths rules below.
- **Rule 1 - Explicit context in the prompt**: The user's target, naming conventions, protected paths, and desired topics are authoritative. MUST NOT add categories or expand scope beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT data-loss rules (no deletions, no content loss), which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: Without instructions, use this skill's workflow and rules at the default scope. MUST NOT import unrelated requirements.
- **Rule 3 - Explicit scope**: Move only files inside the resolved scope. Files outside it may be READ (to find inbound references) and edited ONLY to repair references that the move breaks.
- **Mutation boundary**: Analysis and proposal are strictly read-only. The apply stage may move and rename files, create directories and index files, and repair path references. Nothing else.

## Step-by-Step Workflow

1. **Resolve scope**: State target, `include`, file count, and the read-only boundary in one line. Exclude `.git`, `node_modules`, `vendor`, build output, caches, and generated files unless asked.
2. **Inventory**: List every file in scope with path, type, and size. Note existing conventions (naming case, index file name, nav config such as `mkdocs.yml`, `_sidebar.md`, `SUMMARY.md`).
3. **Read and classify**: Read each file's content and record primary topic, secondary topics, purpose, audience, outbound references, and overlap. Never classify from the filename alone.
4. **Map references**: Search for inbound references to each file in Markdown, source code, scripts, config, CI workflows, templates, and package metadata. Record assets each file uses by relative path.
5. **Group**: Cluster files by shared topic, responsibility, and audience (see Grouping Rules).
6. **Name**: Derive each group and file name from its dominant keyword (see Naming Standard).
7. **Propose**: Present the analysis outputs (below) and **STOP for approval**. No file is touched before an explicit yes.
8. **Apply**: Create directories, move/rename with `git mv`, repair references, update nav config, add topic indexes only where useful.
9. **Validate**: Run the checks below and fix any regression in the moved/edited set.
10. **Report**: Inventory, final tree, moves and renames, references updated, duplicates/outdated candidates, validation results, recommendations.

## Grouping Rules

- Group when two or more files share a topic and audience; a group is a meaningful domain, not a bucket of leftovers.
- Prefer one clear home per file; a multi-topic file gets one primary home plus a link from the other topic.
- Maximum depth: two levels under the target unless the user allows more. Avoid single-file folders unless growth is expected.
- Files that do not group cleanly stay standalone in place or at the root of the target. Do not force a category.
- Prefer a stable, recognizable split such as `getting-started`, `architecture`, `guides`, `reference`, `operations`, `development`, but derive actual groups from the content.
- Reuse existing groups and conventions before creating new ones.

## Naming Standard

Names are derived from the dominant technical keyword of the content and MUST be clear, short, technical, and professional.

- **Format**: lowercase ASCII kebab-case; letters, digits, hyphens only.
- **Length**: one to three words, at most 24 characters.
- **Meaning**: a precise domain noun or noun phrase (`authentication`, `data-model`, `deployment`, `error-handling`), not a vague one.
- **Banned words**: `misc`, `other`, `stuff`, `temp`, `tmp`, `old`, `new`, `final`, `draft`, `notes`, `general`, `common` (as a catch-all), `untitled`, `copy`, dates, and version suffixes (`v2`, `-2`).
- **No redundancy**: do not repeat the parent in the child (`api/api-overview.md` -> `api/overview.md`) or add the word `docs`/`documentation` inside a docs tree.
- **Abbreviations**: only established ones (`api`, `cli`, `ci`, `db`, `sql`, `http`); otherwise spell out.
- **Consistency**: one plural/singular convention per level; role-based file names are uniform (`overview.md`, `setup.md`, `reference.md`, `troubleshooting.md`).
- **Index files**: use the repository's existing index name; default `README.md`.
- **Keep existing names** that already comply. Rename only to fix a violation or a collision, and list every rename with its reason in the migration plan.
- **Case-only renames** need a two-step move on case-insensitive filesystems.

## Pinned Paths (`include: all`)

Never move or rename these unless the user explicitly approves each one, because tools and conventions locate them by path:

- Root manifests and config: `package.json`, `go.mod`, `pom.xml`, `Makefile`, `Dockerfile`, `.gitignore`, `.editorconfig`, lockfiles, `LICENSE`, `CHANGELOG.md`, `CONTRIBUTING.md`.
- Tooling folders: `.github/`, `.gitlab/`, `.vscode/`, `.claude/`.
- Source and test files whose location is bound by language or build rules (Go packages, Java package paths, Python packages, `src/`, `test/`). Report suggested changes instead.
- Anything referenced by an absolute path, URL, or glob that the skill cannot safely rewrite.

## Analysis Output (before any change)

- **Inventory**: all files in scope and current paths.
- **Classification table**: `| File | Topic | Purpose | Related Files |`.
- **Groups**: scope and assigned files per group; standalone files listed separately.
- **Proposed tree**: the full folder tree.
- **Migration plan**: `| Current Path | Proposed Path | Reason |`, with renames flagged.
- **Issues**: duplicates, overlaps, ambiguous classification, broken-reference risks, outdated candidates, pinned paths left in place, collisions.

## Validation Checks

- Every original file exists exactly once at its new path (count before == count after, plus new indexes).
- No file deleted; moved files differ only in repaired reference targets (`git diff -M --stat`).
- Every relative link, image, include, and import path resolves; anchors (`#heading`) still match headings.
- Frontmatter and code blocks are unchanged.
- References outside the tree (source, scripts, CI, config, nav files) point to the new paths.
- Every new name satisfies the Naming Standard.
- Build/test/doc-site commands that existed before still succeed, when available and safe to run.
- Final tree matches the approved proposal.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Read the content of every file before classifying it.
- **MUST**: Obtain explicit approval of the proposal, including renames, before moving or modifying anything.
- **MUST**: Preserve content, frontmatter, anchors, code blocks, tables, images, and metadata.
- **MUST**: Apply the Naming Standard to every new or renamed folder and file.
- **MUST**: Update every internal and external reference affected, then run the validation checks.
- **MUST**: Use `git mv` when in a git repository.
- **SHOULD**: Apply the restructure as one reviewable change, separate from content edits.
- **SHOULD**: Offer redirect notes when published URLs (docs site, wiki, external links) may break.
- **MUST NOT**: Delete, merge, split, or rewrite files; report duplication and a consolidation strategy instead.
- **MUST NOT**: Move pinned paths without per-item approval.
- **MUST NOT**: Edit source code beyond path references to moved files.
- **MUST NOT**: Introduce a new documentation framework, build tool, or dependency.
- **MUST NOT**: Create categories for one or two files, or nest deeper than needed.
- **MUST NOT**: Fabricate validation results.

## Examples (good vs. bad, with realistic code or output)

- **Good grouping (content-based)**: `setup.md`, `env-vars.md`, `docker-run.md` all describe first-run configuration -> `getting-started/`. `notes-2.md` is actually an ADR on caching -> `architecture/caching.md`.
- **Good names**: `data-model`, `error-handling`, `deployment`, `troubleshooting`.
- **Bad names**: `misc-docs`, `New Folder`, `api_stuff_v2`, `final-notes`, `General`.
- **Bad (redundant)**: `architecture/architecture-overview.md` -> `architecture/overview.md`.
- **Good link repair**: `docs/guide.md` moved to `docs/features/guide.md`; `[Setup](setup.md)` becomes `[Setup](../getting-started/setup.md)`, and the `.github/workflows/docs.yml` path filter is updated.
- **Bad**: Moving `internal/auth/token.go` into `docs/` or relocating `go.mod` because it "groups better". Pinned; report only.
- **Bad**: Merging `install.md` and `quick-start.md` automatically. Report as overlap and wait.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope, `include`, and read-only boundary stated.
- [ ] Every file in scope read and classified by content.
- [ ] Inbound references (docs, code, CI, config, nav) mapped.
- [ ] Files grouped; standalone files left alone; pinned paths identified.
- [ ] Every new/renamed name passes the Naming Standard.
- [ ] Proposal (tree, migration table, renames) presented; approval received.
- [ ] Moves done with `git mv`; no deletions.
- [ ] Links, assets, imports, nav config, and external references repaired.
- [ ] Validation checks run; results reported honestly.
- [ ] Duplicates, outdated candidates, and follow-ups reported, not acted on.

## Common Pitfalls

- Classifying by filename and mis-filing files with misleading names.
- Moving build-bound or convention-bound files and breaking the project.
- Forgetting non-Markdown references (CI path filters, `package.json` `files`, scripts, templates).
- Breaking anchors or image paths after a move.
- Case-only renames that fail on case-insensitive filesystems.
- Over-grouping into one-file folders, or creating indexes nobody needs.
- Vague catch-all names that recreate the original mess.
- Silently merging "obviously duplicate" files.
- Mixing content edits with moves, which hides the move in review.

## References (official docs, standards)

- [CommonMark Spec](https://spec.commonmark.org/)
- [Diataxis documentation framework](https://diataxis.fr/)
- [Google developer documentation style guide](https://developers.google.com/style)
- [git-mv](https://git-scm.com/docs/git-mv)
