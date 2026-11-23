# Makefile for maintaining this skills repository (linting, validation, scaffolding, install).
# NOTE: comments sit on their own column-0 lines above each command so they are never
# echoed by make and never break backslash-continued shell blocks.

# Show help when `make` is run without a target.
.DEFAULT_GOAL := help
# Every target is a command, not a file.
.PHONY: help tree tree-dirs clean lint validate validate-tags validate-prompts tags skills-table \
	new-skill new-prompt list-skills list-prompts test check install uninstall upgrade \
	sync-claude sync-opencode

# Directory for generated logs.
LOG_DIR := logs
# Extra arguments forwarded to install/uninstall/upgrade/sync scripts (e.g. ARGS="--dry-run --yes").
ARGS ?=

# ----------------------------------------------------------------------------
# Help / housekeeping
# ----------------------------------------------------------------------------

help: ## Show this help message
# Print the heading.
	@echo "Available targets:"
# Extract "target: ## description" lines, sort them and print them in colour.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

tree: ## Generate a full project file tree into logs/codebase.txt (requires `tree`).
# Ensure the log directory exists.
	@mkdir -p $(LOG_DIR)
# Abort with a hint when the `tree` binary is missing.
	@command -v tree >/dev/null 2>&1 || { echo "Install 'tree' to use this target."; exit 1; }
# Write the tree (ignoring VCS, logs, node_modules) to the log file.
	tree -I ".git|logs|node_modules" > ./$(LOG_DIR)/codebase.txt
# Display the generated tree.
	cat ./$(LOG_DIR)/codebase.txt

tree-dirs: ## Directories only, for a quick overview.
# Ensure the log directory exists.
	@mkdir -p $(LOG_DIR)
# Abort with a hint when the `tree` binary is missing.
	@command -v tree >/dev/null 2>&1 || { echo "Install 'tree' to use this target."; exit 1; }
# Write the directory-only tree to the log file.
	tree -d -I ".git|logs|node_modules" > ./$(LOG_DIR)/codebase_dirs.txt
# Display the generated tree.
	cat ./$(LOG_DIR)/codebase_dirs.txt

clean: ## Remove generated/temporary files. Never touches skills/, prompts/, install.sh, etc.
# Delete logs, node_modules and markdownlint caches only.
	@rm -rf $(LOG_DIR) node_modules .markdownlint-cli2*
# Confirm completion.
	@echo "Cleaned up temporary files."

# ----------------------------------------------------------------------------
# Lint / validate
# ----------------------------------------------------------------------------

lint: ## Lint markdown files
# Announce the step.
	@echo "Linting markdown files..."
# Run markdownlint on all markdown (skip node_modules and templates); never fail the build.
	@npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#templates" || true

validate: validate-tags ## Ensure every skills/<name>/ has a valid SKILL.md (name, description) and metadata.tags
# Announce the step.
	@echo "Validating skills/*/SKILL.md ..."
# The block below, for every skills/<name>/ folder, checks in order:
#   1. SKILL.md exists and is non-empty;
#   2. the first line is the YAML frontmatter fence (---);
#   3. a `description:` field is present;
#   4. frontmatter `name:` (if set) equals the folder name.
# `status` records any failure so ALL problems are listed before exiting non-zero.
	@status=0; \
	for dir in skills/*/; do \
		f="$$dir/SKILL.md"; \
		name=$$(basename "$$dir"); \
		if [ ! -s "$$f" ]; then \
			echo "ERROR: missing or empty $$f"; status=1; continue; \
		fi; \
		if ! head -1 "$$f" | grep -q '^---$$'; then \
			echo "ERROR: $$f does not start with YAML frontmatter (---)"; status=1; continue; \
		fi; \
		if ! grep -q '^description:' "$$f"; then \
			echo "ERROR: $$f is missing a 'description:' field"; status=1; \
		fi; \
		fm_name=$$(sed -n '2,/^---$$/p' "$$f" | grep '^name:' | head -1 | sed 's/^name: *//'); \
		if [ -n "$$fm_name" ] && [ "$$fm_name" != "$$name" ]; then \
			echo "ERROR: $$f frontmatter name '$$fm_name' does not match folder name '$$name'"; status=1; \
		fi; \
	done; \
	exit $$status
# Reached only when the block above exited 0.
	@echo "All skill folders contain a valid SKILL.md."

validate-tags: ## Ensure every SKILL.md declares metadata.tags (3-8 lowercase kebab-case tags)
# Delegate to the tag validation script.
	@bash scripts/validate-tags.sh

validate-prompts: ## Ensure every prompts/*.md has YAML frontmatter with title, description and tags
# The block below checks, for every prompt file: starts with `---`, and has title/description/tags.
# `status` records any failure so ALL problems are listed before exiting non-zero.
	@status=0; \
	for f in prompts/*.md; do \
		if ! head -1 "$$f" | grep -q '^---$$'; then \
			echo "ERROR: $$f does not start with YAML frontmatter (---)"; status=1; continue; \
		fi; \
		for key in title description tags; do \
			if ! sed -n '2,/^---$$/p' "$$f" | grep -q "^$$key:"; then \
				echo "ERROR: $$f is missing a '$$key:' field"; status=1; \
			fi; \
		done; \
	done; \
	exit $$status
# Reached only when the block above exited 0.
	@echo "All prompts contain valid frontmatter."

tags: ## Insert metadata.tags into every SKILL.md from scripts/skill-tags.txt (FORCE=1 overwrites existing tags)
# Run the tag script, adding --force only when FORCE is set.
	@bash scripts/add-tags.sh $(if $(FORCE),--force,)

skills-table: ## Regenerate the Available Skills table in README.md from SKILL.md frontmatter
# Rewrite the README table from SKILL.md frontmatter.
	@bash scripts/skills-table.sh --write

# ----------------------------------------------------------------------------
# Scaffolding / listing
# ----------------------------------------------------------------------------

new-skill: ## Scaffold a new skill (Usage: make new-skill NAME=skill-slug)
# Require NAME.
	@if [ -z "$(NAME)" ]; then echo "Usage: make new-skill NAME=skill-slug"; exit 1; fi
# Refuse to overwrite an existing skill.
	@if [ -d "skills/$(NAME)" ]; then echo "skills/$(NAME) already exists."; exit 1; fi
# Create the skill folder.
	@mkdir -p "skills/$(NAME)"
# Copy the template into it.
	@cp templates/SKILL.template.md "skills/$(NAME)/SKILL.md"
# Replace the name placeholder (.bak keeps BSD/GNU sed compatible, then removed).
	@sed -i.bak "s/<kebab-case-name>/$(NAME)/" "skills/$(NAME)/SKILL.md" && rm -f "skills/$(NAME)/SKILL.md.bak"
# Tell the user what to fill in next.
	@echo "Created skills/$(NAME)/SKILL.md - fill in the details, incl. metadata.category and metadata.tags (make validate enforces tags)."

new-prompt: ## Scaffold a new prompt (Usage: make new-prompt NAME=prompt-slug)
# Require NAME.
	@if [ -z "$(NAME)" ]; then echo "Usage: make new-prompt NAME=prompt-slug"; exit 1; fi
# Refuse to overwrite an existing prompt.
	@if [ -f "prompts/$(NAME).md" ]; then echo "prompts/$(NAME).md already exists."; exit 1; fi
# Make sure the prompts folder exists.
	@mkdir -p prompts
# Write the frontmatter (title, description, tags, UTC timestamps) and section skeleton.
	@ts=$$(date -u +%Y-%m-%dT%H:%M:%SZ); \
	printf -- '---\ntitle: %s\ndescription: <one sentence: what this prompt does and when to use it>\ntags: <tag-one>,<tag-two>,<tag-three>\ncreated: %s\nupdated: %s\n---\n\n# ROLE\n\n# INPUT (from the end user)\n\n# WORKFLOW\n\n# OUTPUT FORMAT\n\n# RULES\n' "$(NAME)" "$$ts" "$$ts" > "prompts/$(NAME).md"
# Tell the user what to fill in next.
	@echo "Created prompts/$(NAME).md - fill in the title, description, tags and sections (make validate-prompts enforces them)."

list-skills: ## List all skill folder names
# One skill name per line.
	@ls -1 skills

list-prompts: ## List all prompt files
# One prompt file per line.
	@ls -1 prompts

# ----------------------------------------------------------------------------
# Test / aggregate checks
# ----------------------------------------------------------------------------

test: ## Run the installer test checklist's scripted checks (syntax + dry-run smoke test)
# Syntax-check (bash -n) every shell script in the repo.
	@bash -n install.sh && bash -n uninstall.sh && bash -n upgrade.sh && bash -n scripts/lib.sh && bash -n sync_claude.sh && bash -n sync_opencode.sh && bash -n scripts/add-tags.sh && bash -n scripts/validate-tags.sh && bash -n scripts/skills-table.sh
# Confirm syntax checks passed.
	@echo "Shell syntax OK."
# Dry-run the installer against a throwaway HOME so nothing real is touched.
	@HOME=$$(mktemp -d) ./install.sh --dry-run --yes --tool all --scope personal
# Confirm the smoke test passed.
	@echo "Dry-run smoke test OK."

check: validate validate-prompts test ## Run every validation and test (skills, prompts, shell scripts)
# Reached only when all prerequisites passed.
	@echo "All checks passed."

# ----------------------------------------------------------------------------
# Install / maintenance scripts (forward extra options with ARGS="...")
# ----------------------------------------------------------------------------

install: ## Install skills (Usage: make install ARGS="--tool claude --dry-run --yes")
# Run the installer with the forwarded options.
	@./install.sh $(ARGS)

uninstall: ## Uninstall skills (Usage: make uninstall ARGS="--yes")
# Run the uninstaller with the forwarded options.
	@./uninstall.sh $(ARGS)

upgrade: ## Upgrade installed skills (Usage: make upgrade ARGS="--yes")
# Run the upgrader with the forwarded options.
	@./upgrade.sh $(ARGS)

sync-claude: ## Sync skills to Claude Code (Usage: make sync-claude ARGS="...")
# Run the Claude sync script with the forwarded options.
	@./sync_claude.sh $(ARGS)

sync-opencode: ## Sync skills to OpenCode (Usage: make sync-opencode ARGS="...")
# Run the OpenCode sync script with the forwarded options.
	@./sync_opencode.sh $(ARGS)
