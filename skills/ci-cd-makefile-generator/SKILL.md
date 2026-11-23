---
name: ci-cd-makefile-generator
description: 'Create a self-documenting Makefile when none exists, or update the existing one, so that every project command is covered by a target and every recipe line is commented. Follows the repository''s current Makefile as the template, or a standard GNU make layout when there is none. Trigger: "generate a Makefile", "create Makefile if missing", "update the Makefile", "cover all commands in the Makefile", "add comments to each Makefile command", "standard Makefile for this project".'
metadata:
  category: ci-cd
  tags: "makefile, build-automation, task-runner, developer-experience, self-documenting, conventions"
---

# Makefile Generator

## Purpose

Produces a single, readable `Makefile` that is the one entry point for every command a developer or CI job runs in the project (build, test, lint, format, run, clean, install, scaffolding, scripts). If a `Makefile` exists it is UPDATED in its own style; if it does not exist it is CREATED from the standard below. Every recipe command gets an explanatory comment.

## When to Use / When NOT to Use

- **Use**: No Makefile yet; commands scattered across README, scripts, CI files; adding new targets; documenting a Makefile line by line; standardizing targets across repos.
- **NOT**: Designing CI pipelines or workflows (use `ci-cd-pipelines`).
- **NOT**: Release/versioning automation (use `ci-cd-release-management`).
- **NOT**: Linter/SAST configuration itself (use `code-quality-static-analysis`).
- **NOT**: Documenting shell function bodies (use `shell-shdoc-engineer`).

## Prerequisites & Assumptions

- GNU make 3.81+ (the version on macOS) is the target. Avoid features newer than 3.81 unless the project already requires them.
- Read access to the repository to discover commands. Nothing is run that could change data or touch production.

### Mode Resolution

- **Rule 1 - Makefile exists**: UPDATE it. Preserve existing targets, names, variables, order and style; change only what the request needs. This existing file is the template: copy its conventions for new targets.
- **Rule 2 - No Makefile**: CREATE it. If another Makefile in the workspace or the sibling `templates/` folder is given as a reference, follow it; otherwise use the Standard Layout below.
- **Rule 3 - Explicit user instructions** (target names, tools, shell) are authoritative and override defaults; security rules stay mandatory.

## Step-by-Step Workflow

1. **Detect mode**: check for `Makefile`, `makefile`, `GNUmakefile`. State "update" or "create" in one line.
2. **Inventory commands** (read-only): `package.json` scripts, `go.mod`, `pyproject.toml`, `pom.xml`/`build.gradle`, `Cargo.toml`, `scripts/`, `.github/workflows`, `.gitlab-ci.yml`, `Dockerfile`, README/CONTRIBUTING, existing shell scripts and their `--help`.
3. **Map each command to a target**; every discovered command MUST be reachable via `make <target>`. Record any command intentionally excluded and why.
4. **Learn the template** (update mode): section banners, target naming, help format, variable names, how arguments are forwarded, aggregate targets.
5. **Write or edit** the Makefile following the rules and layout below, with a comment above every recipe command.
6. **Validate**: `make -n <target>` for every target (dry run), `make help`, and run only safe targets (help, lint, test, list). Fix tab/quoting errors.
7. **Report**: targets added/changed, commands covered, commands excluded, anything not verified.

## Standard Layout

```makefile
# <One-line purpose of this Makefile>.
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.PHONY: help build test lint fmt clean check

# Variables first; ?= lets callers override (make ARGS="...").
ARGS ?=

help: ## Show this help message
# Print "target: ## description" pairs, sorted.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'

test: ## Run the test suite
# Run all tests.
	@<project test command> $(ARGS)

check: lint test ## Run every validation and test
# Reached only when all prerequisites passed.
	@echo "All checks passed."
```

(Recipe lines in the code blocks above and below begin with a literal tab character: recipes MUST be tab-indented.)

Typical targets, include only those the project really has: `help`, `build`, `run`, `test`, `lint`, `fmt`, `check`, `clean`, `install`, `uninstall`, `new-<thing>` scaffolds, `docs`, `docker-build`, `release`, `tree`.

## Comment Convention (MUST follow)

- Put the comment on its OWN line at column 0, immediately above the command it explains. It is a make comment, so make never echoes it.
- NEVER put a `#` comment inside a backslash-continued shell block or after a command on the same line: the shell treats it as the rest of the joined line and silently breaks the command.
- For a multi-line shell loop, place one comment block above it that numbers what each step checks.
- Every recipe command line is commented, including `@echo` confirmations and guard clauses.
- Target descriptions use `## text` on the target line; this feeds `make help`.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Declare `.PHONY` for every non-file target and set `.DEFAULT_GOAL := help`.
- **MUST**: Cover ALL project commands; no command should require copying from the README.
- **MUST**: Guard required variables (`NAME=`) with a usage message and non-zero exit.
- **MUST**: Escape shell `$` as `$$` and quote paths and variables.
- **MUST**: Keep portable between macOS (BSD) and Linux (GNU): use `sed -i.bak` then remove the `.bak`; avoid `readlink -f`, `sed -r`, `date -d`.
- **MUST**: Use tab indentation for recipes.
- **SHOULD**: Forward extra options with `ARGS ?=` to wrapper targets; group targets under banner comments.
- **SHOULD**: Use `@` to silence plain output, and leave it off when echoing the command helps (e.g. `tree`).
- **SHOULD**: Make `clean` delete only generated files, never sources.
- **MUST NOT**: Rename or remove existing targets in update mode without being asked.
- **MUST NOT**: Hard-code secrets, absolute home paths or machine-specific values.
- **MUST NOT**: Make destructive targets (`rm -rf` outside build dirs, `git reset --hard`, deploy) run as a prerequisite of anything else.
- **MUST NOT**: Invent commands; each recipe must come from a real tool, script or file in the repo.

## Examples (good vs. bad, with realistic code or output)

- **Bad** (inline comment breaks the continued block):

```makefile
check:
	@for f in *.md; do \
	  echo $$f; # print name \
	done
```

- **Good** (comment above, safe):

```makefile
check: ## Print every markdown file
# Loop over markdown files and print each name.
	@for f in *.md; do echo "$$f"; done
```

- **Good** (scaffold with guard):

```makefile
new-skill: ## Scaffold a skill (Usage: make new-skill NAME=slug)
# Require NAME.
	@if [ -z "$(NAME)" ]; then echo "Usage: make new-skill NAME=slug"; exit 1; fi
# Create the folder from the template.
	@mkdir -p "skills/$(NAME)" && cp templates/SKILL.template.md "skills/$(NAME)/SKILL.md"
```

## Checklist (verifiable, copy-pasteable)

- [ ] Mode (create/update) stated; existing targets preserved
- [ ] `.PHONY` lists every command target; `.DEFAULT_GOAL := help`
- [ ] `make help` lists every target with a description
- [ ] Every recipe command has a column-0 comment above it
- [ ] No `#` inside backslash-continued blocks
- [ ] Every discovered project command maps to a target (exclusions listed)
- [ ] Required variables are guarded
- [ ] `make -n <target>` succeeds for every target
- [ ] Portable between macOS and Linux

## Common Pitfalls

- Spaces instead of tabs ("missing separator").
- Forgetting `$$` for shell variables or `$(...)`.
- Each recipe line runs in its own shell: `cd` or variables do not carry to the next line; join with `;`/`&&` and `\`.
- Missing `.PHONY`, so a file named `test` or `clean` silently disables the target.
- `make` echoing comments because they were tab-indented inside the recipe.
- Rewriting an existing Makefile wholesale instead of extending it.

## References

- GNU Make manual: https://www.gnu.org/software/make/manual/
- Makefile style guide: https://style-guides.readthedocs.io/en/latest/makefile.html
