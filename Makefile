# Makefile for managing Go project tasks such as running, building, testing, and maintaining dependencies.
.PHONY: clean tree tree-dirs help lint validate new-skill

LOG_DIR  := logs
BIN_DIR  := bin

# Generating project file tree
# Creates a text file representing the project's directory structure, excluding certain directories
tree:
	@mkdir -p $(LOG_DIR)
	if ! command -v tree &> /dev/null; then \
		echo "The 'tree' command is not installed. Please install it to use this feature."; \
		exit 1; \
	fi
	tree -I ".gradle|.idea|build|logs|.vscode|.git|.github|vendor" > ./$(LOG_DIR)/codebase.txt
	cat ./$(LOG_DIR)/codebase.txt

# Prints the directory structure only (no files), useful for a quick codebase overview
tree-dirs:
	@mkdir -p $(LOG_DIR)
	if ! command -v tree &> /dev/null; then \
		echo "The 'tree' command is not installed. Please install it to use this feature."; \
		exit 1; \
	fi
	tree -d -I ".gradle|.idea|build|logs|.vscode|.git|.github|vendor" > ./$(LOG_DIR)/codebase_dirs.txt
	cat ./$(LOG_DIR)/codebase_dirs.txt

# Removes the temporary files (node_modules, markdownlint cache), build directory and log directory.
clean:
	rm -rf $(BIN_DIR)
	rm -rf $(LOG_DIR)
	@rm -rf node_modules .markdownlint-cli2*
	@echo "Cleaned up temporary files."

# Show this help message
help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# Lint markdown files and YAML frontmatter
lint:
	@echo "Linting markdown files..."
	@npx --yes markdownlint-cli2 "**/*.md" "#node_modules" "#templates" || true

# Ensure every folder has a valid SKILL.md with name/description
validate:
	@echo "Validating SKILL.md files..."
	@find . -type d -not -path '*/\.*' -not -path './node_modules*' -not -path './templates*' | while read dir; do \
		if [ -d "$$dir" ] && [ "$$dir" != "." ] && [ ! -f "$$dir/SKILL.md" ] && [ "$$(ls -A $$dir | grep -v '^\.' | wc -l)" -gt 0 ]; then \
			echo "ERROR: Missing SKILL.md in $$dir"; exit 1; \
		fi; \
	done
	@echo "All skill folders contain a valid SKILL.md."

# Scaffold a new skill (Usage: make new-skill NAME=category/skill-name)
new-skill:
	@if [ -z "$(NAME)" ]; then echo "Usage: make new-skill NAME=category/skill-name"; exit 1; fi
	@mkdir -p $(NAME)
	@cp templates/SKILL.template.md $(NAME)/SKILL.md
	@echo "Created $(NAME)/SKILL.md - Please fill in the details."
