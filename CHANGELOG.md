# Changelog

All notable changes to this skills repository will be documented in this file.

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
