# 🧠 pnguyen215/skills

A curated collection of [Agent Skills](https://agentskills.io) — enterprise engineering
standards (API design, CI/CD, security, testing, observability, Go/Java/Python conventions, and
more) — packaged as installable `SKILL.md` files for [Claude Code](https://github.com/anthropics/claude-code) and [OpenCode](https://github.com/anomalyco/opencode).

```bash
curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/install.sh \
  | bash -s -- --yes
```

## ✨ Features

- **44 skills**, each a self-contained `skills/<slug>/SKILL.md` following the
  [Agent Skills](https://agentskills.io) open standard.
- **One repository, two tools.** The same content installs into Claude Code and/or OpenCode,
  for your user account (personal) and/or a single project — without duplicating files on disk
  (skills are symlinked from a single source by default).
- **Safe by construction**: no `sudo`, nothing written outside your home directory or a project
  folder you point at, automatic backup of anything it would overwrite, and a removal-safe
  manifest so `uninstall.sh` only ever touches what `install.sh` installed.
- **Idempotent and scriptable**: re-running `install.sh` is a no-op when nothing changed;
  `--dry-run`, `--yes`, and `--skills <a,b,c>` make it safe to call from other automation.
- **Cross-platform**: Linux, macOS, and Windows (via Git Bash, MSYS2, or WSL).

## 🧩 Supported Tools & Platforms

| Tool                                                     | Personal (global) scope                     | Project (local) scope                        |
| -------------------------------------------------------- | ------------------------------------------- | -------------------------------------------- |
| [Claude Code](https://github.com/anthropics/claude-code) | `~/.claude/skills/<name>/SKILL.md`          | `<project>/.claude/skills/<name>/SKILL.md`   |
| [OpenCode](https://github.com/anomalyco/opencode)        | `~/.config/opencode/skills/<name>/SKILL.md` | `<project>/.opencode/skills/<name>/SKILL.md` |

Sources, confirmed directly from each project's official docs:

- Claude Code: ["Choose where skills live"](https://code.claude.com/docs/en/skills#where-skills-live) —
  personal `~/.claude/skills/<skill-name>/SKILL.md`, project `.claude/skills/<skill-name>/SKILL.md`.
- OpenCode: ["Agent Skills"](https://opencode.ai/docs/skills) — project `.opencode/skills/<name>/SKILL.md`,
  global `~/.config/opencode/skills/<name>/SKILL.md`. (OpenCode also auto-discovers
  `.claude/skills/` and `~/.claude/skills/` as "Claude-compatible" paths, but this repo installs
  OpenCode's own native paths explicitly so skills stay discoverable regardless of that
  compatibility shim.)

Platforms: **Linux**, **macOS**, **Windows** (the installer is Bash, so on Windows it runs under
**Git Bash**, **MSYS2**, or **WSL** — not under `cmd.exe` or PowerShell directly).

## ✅ Prerequisites

- `bash` v4+ (default on Linux/macOS; bundled with Git Bash/MSYS2/WSL on Windows).
- One of: `git` (recommended — enables incremental `upgrade.sh`), or `curl`/`wget` (tarball
  fallback).
- Claude Code and/or OpenCode already installed, for whichever tool(s) you target.
- **No admin/root privileges required or used, ever.**

## 📁 Structure

The skill content is organized flat under `skills/`, one directory per skill
(`skills/<slug>/SKILL.md`), with categories carried in each skill's `metadata.category`
frontmatter field rather than in the folder path — this matches how both Claude Code and
OpenCode actually discover skills (`<skills-root>/<name>/SKILL.md`, exactly one level deep).

```text
skills/
├── api-design-error-models/SKILL.md        # api-design: REST/gRPC conventions, versioning, error models
├── ci-cd-pipelines/SKILL.md                # ci-cd: pipelines, quality gates, release management
├── code-quality-code-review/SKILL.md       # code-quality: reviews, refactoring, static analysis
├── database-schema-design/SKILL.md         # database: schema design, migrations, query optimization
├── design-pattern/SKILL.md                 # design: design patterns, design systems
├── documentation-api-documentation/SKILL.md# documentation: API docs, READMEs, technical writing (ADRs)
├── git-workflow-branching/SKILL.md         # git-workflow: branching, commits, PR templates
├── incident-response-postmortem/SKILL.md   # incident-response: postmortems and RCA
├── golang/SKILL.md                         # language-specific: Go, Java, Python best practices
├── observability-logging/SKILL.md          # observability: logging, metrics, tracing
├── performance-profiling/SKILL.md          # performance: profiling, benchmarking
├── security-secure-coding/SKILL.md         # security: secure coding, secrets, dependency scanning
├── testing-unit-testing/SKILL.md           # testing: unit, integration, coverage, strategy
└── ...                                      # see "Available Skills" for the full index
```

Other top-level files:

```text
templates/SKILL.template.md   # scaffold used by `make new-skill`
scripts/lib.sh                # shared library used by install.sh / uninstall.sh / upgrade.sh
docs/review-report.md         # structural audit of this repository and the fixes applied
docs/test-checklist.md        # manual QA matrix for the installer scripts
install.sh / uninstall.sh / upgrade.sh
Makefile                      # make validate / make new-skill / make lint / make test
CONTRIBUTING.md · CHANGELOG.md · LICENSE
```

## 🚀 Installation

### Remote one-liner (no clone needed)

```bash
curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/install.sh \
  | bash -s -- --tool all --scope personal --yes
```

On **Windows**, run the same command inside **Git Bash** or **WSL**.

### Clone and run

```bash
git clone https://github.com/pnguyen215/skills.git
cd skills
./install.sh --tool all --scope personal
```

### Common variations

```bash
# Only Claude Code, only this project (run from the project's root directory)
./install.sh --tool claude --scope project

# Only OpenCode
./install.sh --tool opencode --scope personal

# Only specific skills
./install.sh --tool all --skills golang,security-secure-coding,testing-unit-testing

# Preview everything an install would do, without changing anything
./install.sh --dry-run

# Non-interactive (CI, scripts): always pass --yes
./install.sh --yes
```

By default each skill is installed as a **symlink** back to the fetched source (zero
duplication; `upgrade.sh` updates every install instantly). Where symlinks aren't available
(typically Windows without Developer Mode), `--mode auto` falls back to a plain **copy**
automatically — see [Options Reference](#️-options-reference) for the full trade-off.

## 🤖 Using Skills in Claude Code

**1. Check what's available.** Start Claude Code in a directory covered by the scope you
installed (anywhere, for personal scope; inside the project, for project scope), then run:

```text
/skills
```

This lists every installed skill with its name and description. `/doctor` gives a broader
config health check that also covers skills.

**2. Let Claude auto-trigger a skill.** Just ask about the matching topic, e.g.:

```text
Review this Postgres migration for correctness against our conventions.
```

Claude Code matches your request against each skill's `description` and loads the best match
(here, `database-postgres-migrations`) automatically — no manual step needed.

**3. Call a skill directly.** Type `/` followed by the skill's slug (same as its folder name):

```text
/golang-audit-security
/testing-unit-testing write tests for ParseConfig
```

**4. Scope precedence.** Personal skills (`~/.claude/skills/`) apply everywhere on your machine;
project skills (`.claude/skills/` in the repo) apply only inside that project and are meant to
be committed so your team shares them. If a skill with the same name exists in both, the
personal one takes precedence.

## 🧠 Using Skills in OpenCode

**1. Check what's available.** OpenCode surfaces installed skills through its internal `skill`
tool. The simplest check is to just ask:

```text
What skills do you have available related to Go?
```

**2. Let OpenCode auto-trigger a skill.** Same mechanism as Claude Code: OpenCode matches your
message against each skill's `description` and loads the matching `SKILL.md` through the
`skill` tool automatically.

**3. Ask for a skill explicitly**, if you want to be sure which one is used:

```text
Use the "security-secure-coding" skill to review the code below.
```

**4. Scope.** `~/.config/opencode/skills/` = personal, used in every project; `.opencode/skills/`
inside a project = scoped to that project only. OpenCode also auto-discovers `.claude/skills/`
and `~/.claude/skills/` as a compatibility fallback, but this repo always installs into
OpenCode's own native paths directly (see [Supported Tools & Platforms](#-supported-tools--platforms)).

## 🗑️ Uninstall

```bash
# Remove everything this tool installed, for every tool and scope
./uninstall.sh --tool all --scope all --yes

# Remove just one skill from Claude Code's personal skills
./uninstall.sh --tool claude --scope personal --skills golang-audit-security

# Also wipe this tool's own bookkeeping (manifest, backups, cached clone)
./uninstall.sh --tool all --scope all --purge --yes
```

Remote one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/uninstall.sh \
  | bash -s -- --tool all --scope all --yes
```

`uninstall.sh` only ever removes entries recorded in its own manifest — a skill folder you
created yourself with a matching name is never touched.

## 🔄 Upgrade

```bash
# Pull the latest content and re-link everything this tool manages
./upgrade.sh --yes

# Upgrade only what's installed for OpenCode's project scope
./upgrade.sh --tool opencode --scope project --yes

# Move to a specific branch or tag
./upgrade.sh --ref v2.1.0 --yes
```

Remote one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/upgrade.sh \
  | bash -s -- --yes
```

`upgrade.sh` prints what changed (commit range + changed files via `git`, or an added/removed
skill list when falling back to a tarball) before re-linking. It only re-links skills you
already installed — run `install.sh` again (optionally with `--skills`) to pick up brand-new
skills added upstream.

## ⚙️ Options Reference

All three scripts (`install.sh`, `uninstall.sh`, `upgrade.sh`) accept the same core flags:

| Flag                   | Values                           | Default           | Meaning                                                |
| ---------------------- | -------------------------------- | ----------------- | ------------------------------------------------------ |
| `--tool`               | `claude` \| `opencode` \| `all`  | `all`             | Which tool(s) to target.                               |
| `--scope`              | `personal` \| `project` \| `all` | `personal`        | Install scope.                                         |
| `--project-dir <path>` | any path                         | current directory | Project root for `--scope project`/`all`.              |
| `--mode`               | `auto` \| `symlink` \| `copy`    | `auto`            | How skill content is placed — see trade-off below.     |
| `--skills <a,b,c>`     | comma-separated slugs            | (all skills)      | Only act on this subset.                               |
| `--ref <git-ref>`      | branch/tag/commit                | `master`          | Which ref to fetch/upgrade to.                         |
| `--dry-run`            | flag                             | off               | Print planned actions; change nothing.                 |
| `-y`, `--yes`          | flag                             | off               | Assume "yes"; **required** for non-interactive/CI use. |
| `-v`, `--verbose`      | flag                             | off               | Print debug-level log lines.                           |
| `-h`, `--help`         | flag                             | —                 | Print usage and exit.                                  |

`uninstall.sh` additionally accepts `--purge` to also delete the tool's own state directory
(manifest, backups, cached clone) after removing the skills themselves.

**`--mode` trade-off:** `symlink` means zero duplication — `upgrade.sh` instantly reflects new
content because the link always points at the freshly pulled source. It needs filesystem
symlink support, which on native Windows needs Developer Mode or an elevated shell; this tool
**never requests elevation**, so `--mode auto` silently falls back to `copy` there. `copy`
always works, but `upgrade.sh` must physically re-copy changed files, and a local edit inside an
installed copy won't propagate back (and will be overwritten on the next upgrade).

### Exit codes

| Code | Meaning                                               |
| ---- | ----------------------------------------------------- |
| `0`  | Success                                               |
| `1`  | Generic failure                                       |
| `2`  | Invalid usage / arguments                             |
| `3`  | Missing prerequisite (`git`, or `curl`/`wget`)        |
| `4`  | Filesystem error (directory, symlink, or copy failed) |
| `5`  | Network error (clone or download failed)              |

## 🔒 Safety Guarantees

- **No `sudo`, ever.** Every path written to lives under `$HOME` (or an explicit
  `--project-dir` you chose). Nothing requests elevated privileges, on any platform.
- **Only touches what it manages.** Every install is recorded in a manifest
  (`~/.local/state/pnguyen215-skills/manifest.tsv` by default). `uninstall.sh`/`upgrade.sh` only
  act on rows found there.
- **The manifest never lives inside a skills directory.** Claude Code releases before v2.1.280
  watched for a file literally named `manifest.json` inside `~/.claude/skills/` and used its
  presence to decide which skill folders to move to `.trash/`. To stay safe on every Claude Code
  version, this tool's bookkeeping lives in a separate state directory, never inside
  `~/.claude/skills/`, `.claude/skills/`, `~/.config/opencode/skills/`, or `.opencode/skills/`.
- **Backs up, never silently overwrites.** Anything already at a target path that isn't already
  tracked by the manifest is moved to
  `~/.local/state/pnguyen215-skills/backups/<timestamp>/<tool>-<scope>/<skill>/` first.
- **Idempotent.** Running `install.sh`/`upgrade.sh` twice with the same options is a harmless
  no-op the second time.
- **`set -euo pipefail`, quoted variables, validated inputs** throughout.
- **Prerequisite-checked.** Missing `git`/`curl`/`wget` fails fast with exit code `3`.

## 🔍 Verify an Installation

- **Claude Code**: run `/skills` or `/doctor` in a covered directory and confirm the installed
  skills are listed; invoke one directly with `/<skill-slug>`.
- **OpenCode**: ask something that matches a skill's description, or check the `skill` tool's
  listing directly if you have shell access.

## 📚 Available Skills

Grouped by `metadata.category` (recorded in frontmatter, not by folder nesting — see
`docs/review-report.md` for why the on-disk layout is flat).

| Category            | Skills                                                                                                            |
| ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `api-design`        | `api-design-error-models`, `api-design-rest-grpc-conventions`, `api-design-versioning`                            |
| `ci-cd`             | `ci-cd-pipelines`, `ci-cd-quality-gates`, `ci-cd-release-management`                                              |
| `code-quality`      | `code-quality-code-review`, `code-quality-refactoring`, `code-quality-static-analysis`                            |
| `database`          | `database-migrations`, `database-postgres-migrations`, `database-query-optimization`, `database-schema-design`    |
| `design`            | `design-pattern`, `design-system`                                                                                 |
| `documentation`     | `documentation-api-documentation`, `documentation-readme-generator`, `documentation-technical-writing`            |
| `ecosystem-replify` | `replify-go-api-design`, `replify-go-encapsulation`, `replify-slogger`, `replify-strchain`, `replify-strutil`     |
| `git-workflow`      | `git-workflow-branching`, `git-workflow-commit-conventions`, `git-workflow-pr-templates`                          |
| `incident-response` | `incident-response-postmortem`                                                                                    |
| `language-specific` | `golang`, `golang-audit-cross-platform`, `golang-audit-godoc-coverage`, `golang-audit-security`, `java`, `python` |
| `observability`     | `observability-logging`, `observability-metrics`, `observability-tracing`                                         |
| `performance`       | `performance-benchmarking`, `performance-profiling`                                                               |
| `security`          | `security-dependency-scanning`, `security-secrets-management`, `security-secure-coding`                           |
| `testing`           | `testing-test-coverage`, `testing-test-strategy`, `testing-unit-testing`                                          |

## 🛠️ Tooling

A `Makefile` keeps the repository healthy:

- `make lint` — lints markdown files.
- `make validate` — ensures every `skills/*/SKILL.md` is non-empty, has valid frontmatter, a
  `description`, and a `name` matching its folder.
- `make new-skill NAME=<slug>` — scaffolds a new skill from `templates/SKILL.template.md`.
- `make test` — syntax-checks `install.sh`/`uninstall.sh`/`upgrade.sh`/`scripts/lib.sh` and runs
  a dry-run smoke test.

## ❓ Troubleshooting & FAQ

**"Permission denied" creating a symlink on Windows.**
Developer Mode / an elevated shell isn't enabled, and this tool never requests elevation.
Re-run with `--mode copy`, or enable Developer Mode in Windows Settings for live-updating
symlinks.

**`./install.sh: command not found` or `bad interpreter`.**
You're running it from `cmd.exe`/PowerShell. Use Git Bash, MSYS2, or WSL — it's a Bash script.

**I ran the one-liner and nothing shows up in Claude Code / OpenCode.**
Confirm `--tool`/`--scope` were correct, then check the files exist (`ls ~/.claude/skills`,
`ls ~/.config/opencode/skills`, or the `.claude/skills` / `.opencode/skills` equivalents inside
your project). Some sessions need a restart to pick up a brand-new skills folder.

**How do I update just one skill?** `./upgrade.sh --skills <slug> --yes`

**How do I start over completely?**
`./uninstall.sh --tool all --scope all --purge --yes`, then re-run `install.sh`.

**Can I point this at my own fork?**
Set `AGENT_SKILLS_REPO=yourname/skills` before running any of the three scripts.

**Does this touch my `CLAUDE.md` or OpenCode config files?**
No — only the four skills directories above, plus this tool's own state directory.

## 🤝 Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for how to add or update a skill, naming conventions,
and the quality bar for a pull request. All skills follow the strict template format and use
`kebab-case` slugs, one level deep under `skills/`. Short version:

```bash
make new-skill NAME=your-new-skill-slug
# edit skills/your-new-skill-slug/SKILL.md
make validate
./install.sh --dry-run --skills your-new-skill-slug
```

## 📄 License

[MIT](LICENSE).
