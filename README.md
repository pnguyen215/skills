# 🧠 pnguyen215/skills

A curated collection of [Agent Skills](https://agentskills.io) — enterprise engineering standards (API design, CI/CD, security, testing, observability, Go/Java/Python conventions, and more) — packaged as installable `SKILL.md` files for [Claude Code](https://github.com/anthropics/claude-code) and [OpenCode](https://github.com/anomalyco/opencode).

```bash
curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/install.sh \
  | bash -s -- --yes
```

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
- [API / Configuration Reference](#api--configuration-reference)
- [Contributing](#contributing)
- [License](#license)

<a id="overview"></a>

<details>
<summary><strong>Overview</strong></summary>

### Problem solved

This repository solves the problem of sharing and installing consistent, enterprise-grade agent skill definitions across Claude Code and OpenCode without duplication or manual copying. It packages 47 self-contained skills following the [Agent Skills](https://agentskills.io) open standard, with safe installation/uninstallation/upgrade/sync tooling.

### Design rationale

- **Single source of truth**: Skill content lives once under `skills/` and is symlinked (by default) to tool-specific locations, avoiding duplication.
- **Tool-agnostic packaging**: Works for both Claude Code and OpenCode, installing to their native paths.
- **Safe by construction**: No `sudo`, operates only in home/project directories, backs up existing files, tracks installs via a manifest outside skill directories, and only touches managed files.
- **Scriptable and idempotent**: Supports dry runs, non-interactive execution, and safe re-runs.

### Key features

- **52 skills**, each tagged: Each is a self-contained `skills/<slug>/SKILL.md` following the Agent Skills open standard.
- **One repo, two tools**: Installs into Claude Code and/or OpenCode for personal (global) and/or project (local) scope without duplicating files (symlinked by default).
- **Safe by construction**: No `sudo`, nothing written outside your home directory or a project folder you point at, automatic backup of anything it would overwrite, and a removal-safe manifest so `uninstall.sh` only ever touches what this tool installed.
- **Idempotent and scriptable**: Re-running `install.sh` is a no-op when nothing changed; `--dry-run`, `--yes`, and `--skills <a,b,c>` make it safe to call from other automation.
- **Always able to catch up**: `upgrade.sh` refreshes what you installed _and_ adds new skills; `sync_claude.sh` / `sync_opencode.sh` make one tool mirror the repository exactly.
- **Cross-platform**: Linux, macOS, and Windows (via Git Bash, MSYS2, or WSL).

### When to use vs. not

- **Use when**: You want standardized engineering guidance (API design, CI/CD, security, testing, observability, language conventions, etc.) available to Claude Code or OpenCode across projects or teams.
- **Not for**: Creating API reference docs, CHANGELOGs, or ADRs as the primary deliverable (those have their own conventions). This repo is for installing Agent Skills, not generating arbitrary project documentation outside the skill format.

**Status:** Actively maintained; skills follow the Agent Skills open standard.

</details>

<a id="installation"></a>

<details>
<summary><strong>Installation</strong></summary>

### Prerequisites

- `bash` v4+ (default on Linux/macOS; bundled with Git Bash/MSYS2/WSL on Windows).
- One of: `git` (recommended — enables incremental `upgrade.sh`), or `curl`/`wget` (tarball fallback).
- Claude Code and/or OpenCode already installed, for whichever tool(s) you target.
- **No admin/root privileges required or used, ever.**

### Supported Tools & Platforms

| Tool                                                     | Personal (global) scope                     | Project (local) scope                        |
| -------------------------------------------------------- | ------------------------------------------- | -------------------------------------------- |
| [Claude Code](https://github.com/anthropics/claude-code) | `~/.claude/skills/<name>/SKILL.md`          | `<project>/.claude/skills/<name>/SKILL.md`   |
| [OpenCode](https://github.com/anomalyco/opencode)        | `~/.config/opencode/skills/<name>/SKILL.md` | `<project>/.opencode/skills/<name>/SKILL.md` |

Sources (confirmed from official docs):

- Claude Code: ["Choose where skills live"](https://code.claude.com/docs/en/skills#where-skills-live) — personal `~/.claude/skills/<skill-name>/SKILL.md`, project `.claude/skills/<skill-name>/SKILL.md`.
- OpenCode: ["Agent Skills"](https://opencode.ai/docs/skills) — project `.opencode/skills/<name>/SKILL.md`, global `~/.config/opencode/skills/<name>/SKILL.md`. (OpenCode also auto-discovers `.claude/skills/` and `~/.claude/skills/` as "Claude-compatible" paths, but this repo installs OpenCode's own native paths explicitly.)
- Platforms: **Linux**, **macOS**, **Windows** (Bash required — run under **Git Bash**, **MSYS2**, or **WSL**).

### Install methods

#### Remote one-liner (no clone needed)

```bash
curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/install.sh \
  | bash -s -- --tool all --scope personal --yes
```

On **Windows**, run the same command inside **Git Bash** or **WSL**.

#### Clone and run

```bash
git clone https://github.com/pnguyen215/skills.git
cd skills
./install.sh --tool all --scope personal
```

#### Common variations

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

By default each skill is installed as a **symlink** back to the fetched source (zero duplication; `upgrade.sh` updates every install instantly). Where symlinks aren't available (typically Windows without Developer Mode), `--mode auto` falls back to a plain **copy** automatically.

</details>

<a id="quick-start"></a>

<details>
<summary><strong>Quick Start</strong></summary>

1. **Install skills** (personal scope for both tools):
   ```bash
   curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/install.sh \
     | bash -s -- --tool all --scope personal --yes
   ```
2. **Restart your session** in Claude Code or OpenCode so they reload the skills directory.
3. **Use a skill**:
   - In Claude Code: type `/<skill-slug>` (e.g., `/golang`) or just ask about a matching topic and Claude will auto-trigger.
   - In OpenCode: ask about a matching topic and OpenCode will auto-trigger via its `skill` tool, or explicitly request a skill by name.

**Verify quickly:**

- Claude Code: run `/skills` or `/doctor`.
- OpenCode: ask "What skills do you have available related to Go?" or invoke via the skill tool.

</details>

<a id="usage-examples"></a>

<details>
<summary><strong>Usage Examples</strong></summary>

<details>
<summary><strong>Example 1: Install only specific skills for a project</strong></summary>

```bash
cd /path/to/your/project
curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/install.sh \
  | bash -s -- --tool claude --scope project --skills golang,database-postgres-migrations --yes
```

This installs just those two skills into `.claude/skills/` for this project only.

</details>

<details>
<summary><strong>Example 2: Upgrade installed skills to latest</strong></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/upgrade.sh \
  | bash -s -- --yes
```

Refreshes all installed skills, keeps install modes (symlink/copy), and adds new upstream skills into existing tool/scope directories.

</details>

<details>
<summary><strong>Example 3: Mirror a tool's skills directory exactly</strong></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/sync_claude.sh \
  | bash -s -- --yes
```

Pulls latest content, installs any missing skills, refreshes existing ones, and prunes skills deleted upstream (unless `--no-prune`). Works even if you never ran `install.sh`.

</details>

<details>
<summary><strong>Example 4: Uninstall everything cleanly</strong></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/pnguyen215/skills/master/uninstall.sh \
  | bash -s -- --tool all --scope all --yes
```

Removes all skills tracked by the manifest and sweeps leftover symlinks pointing into the managed clone. Add `--purge` to also delete state/manifest/backups and the cached clone.

</details>

<details>
<summary><strong>Example 5: Use a skill in Claude Code</strong></summary>

```text
/skills
/golang-audit-security
/golang write tests for ParseConfig
```

Check available skills, invoke directly by slug, or pass additional context to the skill.

</details>

</details>

<a id="api--configuration-reference"></a>

<details>
<summary><strong>API / Configuration Reference</strong></summary>

### Options Reference (all scripts)

All scripts (`install.sh`, `uninstall.sh`, `upgrade.sh`, `sync_claude.sh`, `sync_opencode.sh`) accept the same core flags:

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

### Script-specific flags

| Script                                | Flag         | Meaning                                                                      |
| ------------------------------------- | ------------ | ---------------------------------------------------------------------------- |
| `uninstall.sh`                        | `--purge`    | Also delete the manifest, backups and the cached clone after uninstalling.   |
| `uninstall.sh`                        | `--no-sweep` | Only remove manifest-tracked entries; skip the leftover-symlink sweep.       |
| `upgrade.sh`                          | `--no-new`   | Do not install skills that were added upstream; only refresh installed ones. |
| `sync_claude.sh` / `sync_opencode.sh` | `--no-prune` | Do not remove skills that were deleted upstream.                             |

`--tool` is fixed to `claude` / `opencode` for the `sync_*` scripts.

### `--mode` trade-off

`symlink` means zero duplication — `upgrade.sh` instantly reflects new content because the link always points at the freshly pulled source. It needs filesystem symlink support, which on native Windows needs Developer Mode or an elevated shell; this tool **never requests elevation**, so `--mode auto` silently falls back to `copy` there. `copy` always works, but `upgrade.sh` must physically re-copy changed files, and a local edit inside an installed copy won't propagate back (and will be overwritten on the next upgrade).

### Exit codes

| Code | Meaning                                               |
| ---- | ----------------------------------------------------- |
| `0`  | Success                                               |
| `1`  | Generic failure                                       |
| `2`  | Invalid usage / arguments                             |
| `3`  | Missing prerequisite (`git`, or `curl`/`wget`)        |
| `4`  | Filesystem error (directory, symlink, or copy failed) |
| `5`  | Network error (clone or download failed)              |

### Available Skills (by category)

Grouped by `metadata.category` and labelled with `metadata.tags` (both recorded in each skill's frontmatter — layout is flat, one folder per skill). Tags make skills easy to search, e.g. `grep -l "owasp" skills/*/SKILL.md`. This table is generated by `make skills-table`; do not edit it by hand.

<!-- skills-table:start -->
| Category            | Skill                               | Tags                                                                                               |
| ------------------- | ----------------------------------- | -------------------------------------------------------------------------------------------------- |
| `api-design`        | `api-design-error-models`           | `api`, `error-handling`, `rfc-7807`, `http-status`, `grpc`                                         |
| `api-design`        | `api-design-rest-grpc-conventions`  | `api`, `rest`, `grpc`, `naming`, `pagination`                                                      |
| `api-design`        | `api-design-versioning`             | `api`, `versioning`, `deprecation`, `backward-compatibility`, `rest`                               |
| `ci-cd`             | `ci-cd-pipelines`                   | `ci-cd`, `github-actions`, `gitlab-ci`, `matrix-builds`, `caching`                                 |
| `ci-cd`             | `ci-cd-quality-gates`               | `ci-cd`, `quality-gate`, `sonarqube`, `coverage`, `linting`                                        |
| `ci-cd`             | `ci-cd-release-management`          | `ci-cd`, `release`, `semver`, `changelog`, `publishing`                                            |
| `code-quality`      | `code-quality-code-review`          | `code-review`, `pull-request`, `architecture`, `security`, `maintainability`                       |
| `code-quality`      | `code-quality-codebase-analyst`     | `codebase-analysis`, `architecture`, `execution-tracing`, `onboarding`, `reverse-engineering`      |
| `code-quality`      | `code-quality-logic-review-diagram` | `code-review`, `logic-analysis`, `sequence-diagram`, `activity-diagram`, `mermaid`, `architecture` |
| `code-quality`      | `code-quality-refactoring`          | `refactoring`, `code-smells`, `solid`, `cohesion`, `clean-code`                                    |
| `code-quality`      | `code-quality-static-analysis`      | `static-analysis`, `linting`, `sast`, `complexity`, `code-quality`                                 |
| `database`          | `database-migrations`               | `database`, `migrations`, `zero-downtime`, `rollback`, `schema`                                    |
| `database`          | `database-postgres-migrations`      | `postgresql`, `migrations`, `flyway`, `liquibase`, `partitioning`                                  |
| `database`          | `database-query-optimization`       | `database`, `sql`, `indexing`, `explain-plan`, `n-plus-one`, `performance`                         |
| `database`          | `database-schema-design`            | `database`, `schema`, `normalization`, `constraints`, `data-modeling`                              |
| `design`            | `design-concept-explainer`          | `explanation`, `system-design`, `algorithms`, `teaching`, `technical-communication`                |
| `design`            | `design-pattern`                    | `design-patterns`, `gof`, `enterprise-integration`, `architecture`, `refactoring`                  |
| `design`            | `design-system`                     | `design-system`, `ui`, `ux`, `design-tokens`, `component-library`                                  |
| `design`            | `system-design-reviewer`            | `system-design`, `architecture`, `review`, `non-functional-requirements`, `trade-offs`             |
| `documentation`     | `documentation-api-documentation`   | `documentation`, `openapi`, `swagger`, `grpc`, `proto`                                             |
| `documentation`     | `documentation-changelog-writer`    | `documentation`, `changelog`, `release-notes`, `technical-writing`, `release-management`           |
| `documentation`     | `documentation-collapsible-readme`  | `documentation`, `readme`, `markdown`, `collapsible`, `refactoring`                                |
| `documentation`     | `documentation-readme-generator`    | `documentation`, `readme`, `markdown`, `onboarding`, `repository`                                  |
| `documentation`     | `documentation-technical-writing`   | `documentation`, `adr`, `runbook`, `rfc`, `technical-writing`                                      |
| `ecosystem-replify` | `replify-go-api-design`             | `replify`, `golang`, `api-design`, `functional-options`, `fluent-api`                              |
| `ecosystem-replify` | `replify-go-encapsulation`          | `replify`, `golang`, `encapsulation`, `nil-safety`, `defensive-copy`                               |
| `ecosystem-replify` | `replify-slogger`                   | `replify`, `golang`, `logging`, `slog`, `zero-allocation`                                          |
| `ecosystem-replify` | `replify-strchain`                  | `replify`, `golang`, `strings`, `fluent-api`, `string-builder`                                     |
| `ecosystem-replify` | `replify-strutil`                   | `replify`, `golang`, `strings`, `validation`, `transformation`                                     |
| `git-workflow`      | `git-workflow-branching`            | `git`, `branching`, `trunk-based`, `gitflow`, `branch-protection`                                  |
| `git-workflow`      | `git-workflow-commit-conventions`   | `git`, `conventional-commits`, `commitlint`, `changelog`, `automation`                             |
| `git-workflow`      | `git-workflow-pr-templates`         | `git`, `pull-request`, `templates`, `code-review`, `collaboration`                                 |
| `incident-response` | `incident-response-postmortem`      | `incident-response`, `postmortem`, `rca`, `five-whys`, `blameless`                                 |
| `language-specific` | `golang`                            | `golang`, `go-modules`, `generics`, `slog`, `concurrency`, `context`                               |
| `language-specific` | `golang-audit-cross-platform`       | `golang`, `audit`, `cross-platform`, `concurrency`, `resource-safety`                              |
| `language-specific` | `golang-audit-godoc-coverage`       | `golang`, `godoc`, `documentation`, `audit`, `pkg-go-dev`                                          |
| `language-specific` | `golang-audit-security`             | `golang`, `security`, `audit`, `injection`, `cryptography`, `secrets`                              |
| `language-specific` | `golang-godoc-engineer`             | `golang`, `godoc`, `documentation`, `examples`, `pkg-go-dev`                                       |
| `language-specific` | `java`                              | `java`, `spring-boot`, `records`, `virtual-threads`, `graalvm`                                     |
| `language-specific` | `java-javadoc-engineer`             | `java`, `javadoc`, `documentation`, `api-contract`, `audit`                                        |
| `language-specific` | `python`                            | `python`, `type-hints`, `pydantic`, `asyncio`, `packaging`                                         |
| `language-specific` | `python-pydoc-engineer`             | `python`, `docstrings`, `pep-257`, `sphinx`, `documentation`                                       |
| `language-specific` | `shell-shdoc-engineer`              | `bash`, `shell`, `documentation`, `posix`, `comments`, `technical-writing`                         |
| `observability`     | `observability-logging`             | `observability`, `logging`, `structured-logging`, `correlation-id`, `pii`                          |
| `observability`     | `observability-metrics`             | `observability`, `metrics`, `prometheus`, `slo`, `sli`                                             |
| `observability`     | `observability-tracing`             | `observability`, `tracing`, `opentelemetry`, `distributed-tracing`, `context-propagation`          |
| `performance`       | `performance-benchmarking`          | `performance`, `benchmarking`, `micro-benchmark`, `statistics`, `compiler-optimization`            |
| `performance`       | `performance-profiling`             | `performance`, `profiling`, `pprof`, `cpu`, `memory`, `goroutines`                                 |
| `research`          | `research-analyst`                  | `research`, `fact-checking`, `source-evaluation`, `evidence`, `reporting`                          |
| `security`          | `security-dependency-scanning`      | `security`, `sbom`, `cve`, `trivy`, `dependabot`, `license-compliance`                             |
| `security`          | `security-secrets-management`       | `security`, `secrets`, `vault`, `aws-secrets-manager`, `hardcoded-secrets`                         |
| `security`          | `security-secure-coding`            | `security`, `owasp`, `input-validation`, `secure-by-default`, `injection`                          |
| `testing`           | `testing-test-coverage`             | `testing`, `coverage`, `branch-coverage`, `mutation-testing`, `metrics`                            |
| `testing`           | `testing-test-strategy`             | `testing`, `test-pyramid`, `integration-testing`, `test-environments`, `strategy`                  |
| `testing`           | `testing-unit-testing`              | `testing`, `unit-testing`, `tdd`, `mocking`, `first-principles`                                    |
<!-- skills-table:end -->

### Structure

```text
skills/
├── api-design-error-models/SKILL.md
├── ci-cd-pipelines/SKILL.md
├── ...                                      # see "Available Skills" above
└── testing-unit-testing/SKILL.md
```

Categories are carried in each skill's `metadata.category` frontmatter field (not in folder paths). Other top-level files: `templates/SKILL.template.md`, `scripts/lib.sh`, `scripts/skill-tags.txt`, `scripts/add-tags.sh`, `scripts/validate-tags.sh`, `scripts/skills-table.sh`, `install.sh`, `upgrade.sh`, `uninstall.sh`, `sync_claude.sh`, `sync_opencode.sh`, `docs/maintainer-release-commands.sh`, `Makefile`, `CONTRIBUTING.md`, `CHANGELOG.md`, `LICENSE`.

### Safety Guarantees

- **No `sudo`, ever.** Every path written to lives under `$HOME` (or an explicit `--project-dir` you chose).
- **Only touches what it manages.** Every install is recorded in a manifest (`~/.local/state/pnguyen215-skills/manifest.tsv` by default). Only manifest-tracked entries and symlinks pointing into this tool's own cached clone are removed.
- **Manifest never inside skills dirs.** Bookkeeping lives in a separate state directory (never inside `~/.claude/skills/`, `.claude/skills/`, `~/.config/opencode/skills/`, or `.opencode/skills/`).
- **Backs up, never silently overwrites.** Pre-existing non-managed paths are backed up to `~/.local/state/pnguyen215-skills/backups/<timestamp>/...` first.
- **Cached clone is disposable.** Lives in `~/.local/share/pnguyen215-skills/repo`, reset on refresh; full clones you manage are only fast-forwarded.
- **Idempotent.** Re-runs are harmless no-ops.
- **Safe shell practices.** `set -euo pipefail`, quoted variables, validated inputs.
- **Prerequisite-checked.** Missing `git`/`curl`/`wget` fails fast with exit code `3`.

### Troubleshooting & FAQ

- **Permission denied creating symlink on Windows:** Enable Developer Mode or use `--mode copy` (tool never requests elevation).
- **`./install.sh: command not found` or bad interpreter:** Run with Git Bash, MSYS2, or WSL (not cmd.exe/PowerShell).
- **Nothing shows up after install:** Restart Claude Code/OpenCode session. Verify paths exist.
- **Skills out of date after upgrade:** Restart session; if needed run `./sync_claude.sh --yes` or `./sync_opencode.sh --yes`.
- **Skill deleted upstream but still installed:** Use `./uninstall.sh --skills <slug> --yes` or `sync_*.sh` (they prune).
- **New skill upstream not installed:** Run `./upgrade.sh --yes` or `./install.sh`/`./sync_*.sh`.
- **Update only one skill:** `./upgrade.sh --skills <slug> --yes`
- **Start over completely:** `./uninstall.sh --tool all --scope all --purge --yes` then re-run `install.sh`.
- **Point to your own fork:** Set `AGENT_SKILLS_REPO=yourname/skills`.
- **Touches CLAUDE.md/OpenCode config?** No — only skills directories and this tool's own state directory.

</details>

<a id="contributing"></a>

<details>
<summary><strong>Contributing</strong></summary>

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for how to add or update a skill, naming conventions, and the quality bar for a pull request. All skills follow the strict template format and use `kebab-case` slugs, one level deep under `skills/`.

Short version:

```bash
make new-skill NAME=your-new-skill-slug
# edit skills/your-new-skill-slug/SKILL.md
# set metadata.category and metadata.tags (required)
make validate
make skills-table
./install.sh --dry-run --yes --skills your-new-skill-slug
```

Tooling:

- `make lint` — lints markdown files.
- `make validate` — ensures every `skills/*/SKILL.md` is non-empty, has valid frontmatter, a `description`, a `name` matching its folder, and `metadata.tags` (3-8 lowercase kebab-case tags; also runnable alone as `make validate-tags`).
- `make new-skill NAME=<slug>` — scaffolds a new skill from `templates/SKILL.template.md`.
- `make tags` — inserts `metadata.tags` into every `SKILL.md` from `scripts/skill-tags.txt` (`make tags FORCE=1` overwrites existing tags; idempotent).
- `make skills-table` — regenerates the Available Skills table (category, skill, tags) from the frontmatter.
- `make test` — syntax-checks the installer scripts and runs a dry-run smoke test.

No formal process yet — issues and pull requests are welcome.

</details>

<a id="license"></a>

<details>
<summary><strong>License</strong></summary>

[MIT](LICENSE)

```
MIT License

Copyright (c) 2026 pnguyen215

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

</details>
