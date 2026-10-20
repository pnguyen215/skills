# Contributing to pnguyen215/skills

Thank you for improving this skill collection!

## Repository layout (read this first)

Every skill lives at the **same depth**, directly under `skills/`:

```text
skills/<kebab-case-slug>/SKILL.md
```

There is no category subfolder on disk. Categories (`api-design`, `security`, `testing`, ...)
are recorded as `metadata.category` inside each `SKILL.md`'s frontmatter and are used only to
group skills in the README and in tooling — never as part of the install path. This keeps the
repository compatible with how Claude Code and OpenCode actually discover skills: both tools
expect `(<skills-root>)/<skill-name>/SKILL.md`, exactly one level deep.

## Adding a new skill

1. Pick a unique, kebab-case slug for the skill. If the skill is specific to a broader topic
   already represented in `skills/`, prefix it to avoid collisions and to group it visually in a
   sorted listing, for example `database-query-optimization` or `golang-audit-security`. Do not
   repeat a word that is already implied, e.g. prefer `design-pattern` over `design-design-pattern`.
2. Run `make new-skill NAME=<your-slug>` to scaffold `skills/<your-slug>/SKILL.md` from
   `templates/SKILL.template.md`.
3. Fill out every section of the template: Purpose, When to Use / When NOT to Use,
   Prerequisites & Assumptions, Step-by-Step Workflow, Enterprise Rules & Standards,
   Examples, Checklist, Common Pitfalls, References.
4. Set the frontmatter:
   ```yaml
   ---
   name: <your-slug> # MUST match the folder name
   description: "<what it does and when to trigger it, with concrete trigger phrases>"
   metadata:
     category: <existing-or-new-category>
   ---
   ```
   Only use frontmatter fields from this short list unless you have a specific reason to target
   Claude Code only: `name`, `description`, `metadata`, `license`, `compatibility`,
   `allowed-tools`. These are the fields the
   [Agent Skills open standard](https://agentskills.io) defines, so a skill written this way
   stays portable to any tool that implements the standard, not just Claude Code and OpenCode.
5. If the skill ships supporting files (scripts, templates), put them inside the same
   `skills/<your-slug>/` folder and reference them from `SKILL.md` with a relative link, e.g.
   `skills/database-postgres-migrations/templates/V000__standard_table.sql`.
6. Run `make validate` to check the frontmatter and folder-name agreement.
7. Add a row for your skill to the table in `README.md` under the matching category heading.
8. Run `./install.sh --dry-run --yes --skills <your-slug>` to confirm the installer can see and
   place your new skill correctly.
9. Submit a Pull Request.

## Updating an existing skill

1. Edit the relevant `skills/<slug>/SKILL.md`.
2. Keep the `name:` field equal to the folder name — the installer and `make validate` both
   enforce this and will fail CI otherwise.
3. Avoid vague guidance; prefer concrete, testable rules and runnable examples.
4. If you rename a skill's slug, update the folder name, the frontmatter `name:`, and the README
   table row together in the same PR, and mention the rename in `CHANGELOG.md` — anyone with the
   old slug already installed will need to re-run `install.sh` for the new one and
   `uninstall.sh --skills <old-slug>` for the old one.
5. Submit a Pull Request.

## Naming conventions

- **Folders**: `kebab-case`, one level under `skills/`, matching `^[a-z0-9]+(-[a-z0-9]+)*$`.
  This is required by both Claude Code and OpenCode's skill discovery rules.
- **Skill name**: the frontmatter `name:` must equal the folder name.
- **Reserved names**: never name a skill `synced` or anything starting with `anthropic-skills`
  — Claude Code reserves both for skills it syncs from a claude.ai account and will refuse to
  load a folder with either name.
- **Trigger phrases**: include concrete phrases in `description` (e.g. `'Trigger: "setup Vault",
"rotate credentials"'`) so both Claude Code and OpenCode's description-matching can find the
  skill.

## Quality bar

Before submitting, verify:

- [ ] `make validate` passes.
- [ ] Every section of the template is filled in with concrete, testable rules — no placeholder
      text left over.
- [ ] Examples are correct, idiomatic, and (for code) compile or run as shown.
- [ ] `description` states both _what_ the skill does and _when_ to trigger it.
- [ ] No duplicate skill slug exists elsewhere in `skills/`.

## Working on the installer scripts

`install.sh`, `uninstall.sh`, and `upgrade.sh` share logic in `scripts/lib.sh`. If you change
behavior there:

- Keep `set -euo pipefail` and quote every variable expansion.
- Never add a code path that calls `sudo` or writes outside `$HOME` / an explicit
  `--project-dir`.
- Never write a manifest or state file inside a tool's own skills directory (`~/.claude/skills`,
  `.claude/skills`, `~/.config/opencode/skills`, `.opencode/skills`) — see the comment at the top
  of `scripts/lib.sh` explaining why.
- Add or update a case in `docs/test-checklist.md` for the platform/tool combination your change
  affects, and run it locally (Linux/macOS/Git Bash, whichever you have) before opening a PR.
- Run `make test` for a quick syntax + dry-run smoke check.
