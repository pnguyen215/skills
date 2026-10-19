# Makefile for managing Go project tasks such as running, building, testing, and maintaining dependencies.
.PHONY: clean tree tree-dirs

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

# ==============================================================================
# Clean
# Removes the build directory and log directory.
clean:
	rm -rf $(BIN_DIR)
	rm -rf $(LOG_DIR)
