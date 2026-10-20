# Makefile for maintaining this skills repository (linting, validation, scaffolding).
.PHONY: tree tree-dirs clean help lint validate new-skill test

LOG_DIR := logs

# Generate a full project file tree into logs/codebase.txt (requires `tree`).
tree:
	@mkdir -p $(LOG_DIR)
	@command -v tree >/dev/null 2>&1 || { echo "Install 'tree' to use this target."; exit 1; }
	tree -I ".git|logs|node_modules" > ./$(LOG_DIR)/codebase.txt
	cat ./$(LOG_DIR)/codebase.txt

# Directories only, for a quick overview.
tree-dirs:
	@mkdir -p $(LOG_DIR)
	@command -v tree >/dev/null 2>&1 || { echo "Install 'tree' to use this target."; exit 1; }
	tree -d -I ".git|logs|node_modules" > ./$(LOG_DIR)/codebase_dirs.txt
	cat ./$(LOG_DIR)/codebase_dirs.txt

# Remove generated/temporary files. Never touches skills/, install.sh, etc.
clean:
	@rm -rf $(LOG_DIR) node_modules .markdownlint-cli2*
	@echo "Cleaned up temporary files."

help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

lint: ## Lint markdown files
	@echo "Linting markdown files..."
	@npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#templates" || true

validate: ## Ensure every skills/<name>/ folder has a non-empty SKILL.md with name + description
	@echo "Validating skills/*/SKILL.md ..."
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
	@echo "All skill folders contain a valid SKILL.md."

new-skill: ## Scaffold a new skill (Usage: make new-skill NAME=skill-slug)
	@if [ -z "$(NAME)" ]; then echo "Usage: make new-skill NAME=skill-slug"; exit 1; fi
	@if [ -d "skills/$(NAME)" ]; then echo "skills/$(NAME) already exists."; exit 1; fi
	@mkdir -p "skills/$(NAME)"
	@cp templates/SKILL.template.md "skills/$(NAME)/SKILL.md"
	@sed -i.bak "s/<kebab-case-name>/$(NAME)/" "skills/$(NAME)/SKILL.md" && rm -f "skills/$(NAME)/SKILL.md.bak"
	@echo "Created skills/$(NAME)/SKILL.md - please fill in the details."

test: ## Run the installer test checklist's scripted checks (syntax + dry-run smoke test)
	@bash -n install.sh && bash -n uninstall.sh && bash -n upgrade.sh && bash -n scripts/lib.sh && bash -n sync_claude.sh && bash -n sync_opencode.sh
	@echo "Shell syntax OK."
	@HOME=$$(mktemp -d) ./install.sh --dry-run --yes --tool all --scope personal
	@echo "Dry-run smoke test OK."
