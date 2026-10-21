# Changelog

All notable changes to this skills repository will be documented in this file.

## [2.0.4] - 2026-10-21

### Added

- Five new skills, bringing the total from 48 to 53:
  - `code-quality-codebase-analyst` (category `code-quality`): map a codebase's
    structure, trace execution paths, verify how a feature actually behaves and
    surface technical risks.
  - `design-concept-explainer` (category `design`): explain complex concepts,
    system design patterns and algorithms clearly, accurately and practically.
  - `documentation-changelog-writer` (category `documentation`): draft, update
    and review `CHANGELOG.md` files from verified Git history.
  - `research-analyst` (category `research` — a new category): verify
    technical claims, evaluate sources and synthesize evidence-backed reports.
  - `system-design-reviewer` (category `design`): review an architecture
    against functional and non-functional requirements, constraints and
    operational realities.
- `metadata.tags` frontmatter field on every skill: 3-8 lowercase kebab-case
  tags stored as one comma-separated string, because the Agent Skills standard
  treats `metadata` values as strings and a YAML list would be rejected by some
  tools. Tags make skills greppable, e.g. `grep -l "owasp" skills/*/SKILL.md`.
- `scripts/skill-tags.txt`: the tag data source, one `slug: tag, tag, ...` line
  per skill.
- `scripts/add-tags.sh`: inserts or refreshes `metadata.tags` in each
  `SKILL.md` frontmatter. Idempotent, and only the frontmatter is touched;
  `--force` overwrites existing tags and `--dry-run` shows the planned changes.
- `scripts/validate-tags.sh`: quality gate used by `make validate` — requires
  `metadata.tags` on every skill, 3-8 tags each, all lowercase kebab-case and
  free of duplicates.
- `scripts/skills-table.sh`: regenerates the "Available Skills" table in
  `README.md` (Category | Skill | Tags) from the frontmatter, between the
  `<!-- skills-table:start -->` and `<!-- skills-table:end -->` markers, so the
  README can no longer drift from the real skill set.

### Changed

- `Makefile`: `make validate` now also runs `validate-tags`, so a skill without
  `metadata.tags` fails the build. New targets `make validate-tags`,
  `make tags` (bulk-apply `scripts/skill-tags.txt`) and `make skills-table`
  (regenerate the README table). `make test` additionally syntax-checks the
  three new scripts.
- `templates/SKILL.template.md`: the scaffold now emits `metadata.category` and
  `metadata.tags` alongside `name` and `description`.
- `CONTRIBUTING.md`: `metadata.tags` is now a required frontmatter field
  (3-8 lowercase kebab-case tags, reusing existing tags from
  `scripts/skill-tags.txt` where possible), and contributors are told to run
  `make skills-table` rather than edit the README table by hand.
- `README.md`: the "Available Skills" table is now generated and lists each
  skill's tags, and the new `research` category and the tag tooling are
  documented.

## [2.0.3] - 2026-10-20

### Added

- `sync_claude.sh` and `sync_opencode.sh`: one command that makes a tool's
  skills directory mirror the repository exactly. They pull the latest content,
  install skills that are new upstream, refresh the ones already installed
  (preserving the symlink/copy mode each was installed with), and remove
  skills that were deleted upstream together with dangling links into the
  tool's own clone. `--no-prune` keeps upstream-deleted skills, and `--tool` is
  fixed to the script's tool. Both work even if `install.sh` was never run.
- `skills/python-pydoc-engineer/SKILL.md`: new skill in the
  `language-specific` category covering PEP 257 docstrings, the Google, NumPy
  and Sphinx styles, doctests and API documentation.

### Changed

- **Breaking: `upgrade.sh` now installs skills that are new upstream.** Until
  2.0.2 an upgrade only re-linked the skills already recorded in the manifest;
  from 2.0.3 it also installs skills added upstream since your last install,
  into the tool/scope roots you already use. A directory this tool did not
  create is never overwritten. Pass `--no-new` to restore the previous
  refresh-only behaviour.
- **Breaking: `uninstall.sh` now removes leftover symlinks by default.** In
  addition to the manifest-tracked entries it sweeps up symlinks that point
  into this tool's own source clone but have lost their manifest row (for
  example the same skill installed into two projects). Folders this tool did
  not create are still never touched. Pass `--no-sweep` to keep the previous
  manifest-only behaviour.
- `uninstall.sh --purge` now also deletes the managed cache clone
  (`~/.local/share/pnguyen215-skills/repo`) in addition to the state directory
  that holds the manifest and the backups.
- `upgrade.sh` re-links each skill using the mode it was originally installed
  with, so a copy-mode install stays a copy-mode install instead of being
  silently converted to a symlink.
- The source-refresh logic (`is_shallow_clone`, `sync_git_clone`,
  `refresh_source`, `refresh_by_download`) moved from `upgrade.sh` into
  `scripts/lib.sh` so that all five scripts share it, and gained
  `refresh_managed_clone`: the managed cache clone is now refreshed on every
  `resolve_source_dir()` call, so a reinstall after an uninstall never reuses
  stale cached content. The managed clone is also `git clean`ed, so a skill
  deleted upstream really disappears from it.
- `README.md` restructured into collapsible `<details>` sections so the
  install, usage and API reference are scannable, with the skill index still
  grouped by `metadata.category`.

### Fixed

- A download-based refresh failed because the destination directory already
  existed, while `fetch_source_into` requires it not to. The directory is now
  removed first.
- The added/removed skill report produced during a refresh was filtered by
  `--skills`, so skills outside the filter were not reported. The filter is
  now cleared for that comparison.

## [2.0.2] - 2026-10-20

### Added

- Three new skills, bringing the total from 44 to 47:
  - `documentation-collapsible-readme` (category `documentation`): refactor a
    long or messy `README.md` into a scannable `<details>`/`<summary>`
    structure for experienced engineers.
  - `golang-godoc-engineer` (category `language-specific`): generate, audit and
    validate idiomatic GoDoc, including executable examples and `pkg.go.dev`
    readiness.
  - `java-javadoc-engineer` (category `language-specific`): generate, audit and
    validate production-grade JavaDoc for Java projects.

### Changed

- The tool-managed cache clone is now treated as a disposable cache rather than
  a git working copy. Because that clone is shallow (`--depth 1`), it is
  synced with a forced checkout instead of a merge, and if the in-place update
  fails for any reason a fresh copy is downloaded and swapped in at the same
  path, so existing symlinks stay valid.
- A clone you manage yourself (a full, non-shallow clone) is still never
  rewritten: it only receives a plain fast-forward and is never deleted. When
  it cannot be fast-forwarded, `upgrade.sh` now stops and tells you to resolve
  it manually instead of failing mid-way.
- When the source is re-downloaded, `upgrade.sh` now reports which skill slugs
  were added and which were removed compared with the previous copy.

### Fixed

- `upgrade.sh` failed with `refusing to merge unrelated histories` after the
  upstream branch had been force-pushed, because it merged the fetched ref into
  the shallow managed clone. The managed clone is now updated with a forced
  checkout, which cannot hit that error.

## [2.0.1] - 2026-10-20

### Added

- Remote (piped) execution is now supported by `install.sh`, `uninstall.sh` and
  `upgrade.sh`: `curl -fsSL <url>/install.sh | bash -s -- [options]`. When the
  script is read from STDIN there is no `BASH_SOURCE[0]` and no local
  `scripts/lib.sh`, so only `lib.sh` is downloaded into a throw-away temp
  directory; the skill content itself still comes from the persistent cache
  clone, so nothing installed ever points at the temp directory. The repo, ref
  and lib URL can be overridden with `AGENT_SKILLS_REPO`, `AGENT_SKILLS_REF`
  and `AGENT_SKILLS_LIB_URL`.
- `docs/maintainer-release-commands.sh` is now a runnable script
  (`docs/maintainer-release-commands.sh [branch] ["commit message"]`) that
  creates a branch, commits and pushes from the repository root, instead of a
  snippet to copy and edit by hand.

### Changed

- `upgrade.sh` fetches with an explicit refspec
  (`+refs/heads/<ref>:refs/remotes/origin/<ref>`) so that `origin/<ref>`
  exists in the shallow single-branch clone it manages, and falls back to
  fetching `refs/tags/<ref>` when the requested ref is a tag.
- `scripts/lib.sh` downloads release tarballs into a temporary directory
  instead of using a `mktemp` filename suffix, which BSD/macOS `mktemp`
  rejects.

### Fixed

- The remote one-liner documented in the README (`curl ... | bash -s -- --yes`)
  failed on every script with `BASH_SOURCE[0]: unbound variable`, so the
  advertised one-command install did not work. Piped execution now works for
  `install.sh`, `uninstall.sh` and `upgrade.sh`.
- `install.sh` used `mapfile`, which needs bash 4 and therefore failed on the
  bash 3.2 that ships with macOS. It now uses a portable `read` loop.
- The confirmation prompt refused to run when stdin was a pipe even though a
  terminal was available. It now reads from `/dev/tty` in that case, so
  `curl | bash` can still ask before overwriting anything.
- Arguments placed after `--` were silently dropped by the shared argument
  parser. They are now passed through to the script.

## [2.0.0] - 2026-10-20

### Added

- `install.sh`, `uninstall.sh`, `upgrade.sh`, and shared `scripts/lib.sh`: a safe,
  no-sudo, cross-platform (Linux/macOS/Windows via Git Bash/MSYS2/WSL) installer for
  Claude Code and OpenCode, supporting personal and project scopes, symlink-or-copy
  placement, dry-run, a removal-safe manifest, and automatic backups of pre-existing
  conflicting skills. See `README.md` for usage.
- `LICENSE` (MIT).
- `docs/review-report.md`: full audit of the pre-2.0 structure and the fixes applied.
- `docs/test-checklist.md`: manual test matrix for the three scripts across OS/tool
  combinations.
- `metadata.category` frontmatter field on every skill, replacing folder nesting as the
  way skills are grouped for humans (README, docs) while keeping the on-disk layout flat.
- Restored content for the `golang-audit-security` skill, which previously shipped as an
  empty `SKILL.md` (0 bytes) and therefore failed to load in any tool.

### Changed

- **Breaking: flattened the skill directory layout.** Every skill now lives at
  `skills/<slug>/SKILL.md`, exactly one level deep, instead of nested under a category
  folder (`api-design/error-models/SKILL.md`) or, in two cases, three levels deep
  (`ecosystem/replify/go-api-design/SKILL.md`,
  `language-specific/golang/audits/cross-platform/SKILL.md`). This matches how Claude
  Code and OpenCode actually discover skills (`<skills-root>/<name>/SKILL.md`) and how
  the reference repositories (`microsoft/skills`, `samber/cc-skills-golang`,
  `neondatabase/postgres-skills`) lay out their own `skills/` directories.
  Old path → new slug:
  - `api-design/*` → `api-design-*`
  - `ci-cd/*` → `ci-cd-*`
  - `code-quality/*` → `code-quality-*`
  - `database/*` → `database-*`
  - `design/design-pattern` → `design-pattern`, `design/design-system` → `design-system`
  - `documentation/*` → `documentation-*`
  - `ecosystem/replify/*` → `replify-*`
  - `git-workflow/*` → `git-workflow-*`
  - `incident-response/postmortem` → `incident-response-postmortem`
  - `language-specific/golang` → `golang`, `language-specific/java` → `java`,
    `language-specific/python` → `python`
  - `language-specific/golang/audits/*` → `golang-audit-*`
  - `observability/*` → `observability-*`
  - `performance/*` → `performance-*`
  - `security/*` → `security-*`
  - `testing/*` → `testing-*`
- `Makefile`'s `validate` target now checks the flat `skills/` layout, checks that
  `name:` in frontmatter matches the folder name, and checks for a non-empty
  `description:` field (none of which the previous version checked).
- `README.md` rewritten: accurate install/uninstall/upgrade instructions, a full skill
  index grouped by `metadata.category`, platform support matrix, and troubleshooting.

### Removed

- `cli/.git-cmd.sh`: this was the maintainer's own personal git-commit snippet, not a
  skill, and had no `SKILL.md`. It added a non-skill, undocumented folder to the
  installable tree. Its content is preserved for reference at
  `docs/maintainer-release-commands.sh` (not installed by `install.sh`).

### Fixed

- `language-specific/golang/audits/security/SKILL.md` was a 0-byte file (it had no
  frontmatter and no content), so it silently failed to load in Claude Code and
  OpenCode alike. Replaced with full content at `skills/golang-audit-security/SKILL.md`.
- Repository had no `LICENSE`, despite `CONTRIBUTING.md` inviting external contributions
  and the repo being public. Added `LICENSE` (MIT).

## [1.0.0] - 2026-10-19

### Added

- Initial standardized release of enterprise skills.
- Consolidated legacy Go-specific skills into cross-language categories.
- Added 21 new skills covering Security, CI/CD, Observability, API Design, Database, and
  Incident Response.
- Added repository tooling (`Makefile`, validation scripts, templates).
