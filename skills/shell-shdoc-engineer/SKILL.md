---
name: shell-shdoc-engineer
description: 'Write, update, and review high-quality documentation comments for Bash and POSIX Shell functions based on their actual implementations. Trigger: "document shell function", "write bash comments", "review shell docs", "update function docs", "shell docstring".'
metadata:
  category: language-specific
  tags: "bash, shell, documentation, posix, comments, technical-writing"
---

# Shell Function Documentation Writer

## Purpose

Act as an expert Shell engineer, technical writer, code reviewer, and repository maintainer to write, update, and review production-quality documentation comments for Bash and POSIX Shell functions. The primary goal is to make shell functions easier to understand, use, maintain, and review **without changing their runtime behavior**.

## When to Use / When NOT to Use

**Use when:**

- Writing documentation comments for undocumented Bash or POSIX Shell functions.
- Improving existing function comments that are incomplete, vague, misleading, or inconsistent.
- Reviewing existing function comments against the actual source code, call sites, and tests.
- Updating function documentation when an implementation or function contract changes.
- Applying documentation consistently across a file or repository.

**Do NOT use when:**

- The task requires refactoring function implementations, renaming symbols, changing commands, or altering control flow.
- Modifying shebangs or shell compatibility requirements is the primary goal.
- The user wants to generate project-level READMEs or architectural documentation.

## Prerequisites & Assumptions

- **Source Code is Primary Evidence:** MUST inspect the function body, callers, tests, and surrounding code before writing documentation. MUST NOT infer behavior solely from function names.
- **Preserve Existing Conventions:** MUST identify and respect existing repository documentation conventions (placement, prefix, section labels) before imposing new formats.
- **Distinguish Dialects:** MUST distinguish Bash-specific behavior (e.g., `[[ ... ]]`, arrays, `local`, `shopt`) from portable POSIX Shell behavior.
- **Scope Boundary:** This is a documentation specialist, not a general refactoring agent. MUST NOT automatically refactor function implementations or modify runtime behavior unless explicitly authorized.
- **Verify Claims:** MUST NEVER invent function behavior, argument constraints, exit codes, or compatibility guarantees. If evidence is insufficient, omit the claim or flag the uncertainty.

## Step-by-Step Workflow

1. **Determine the Scope:** Establish the target script/function, target comment location, intended Shell dialect, and whether the task is writing, updating, or reviewing. Respect the user's requested scope (e.g., review-only tasks produce findings without silently modifying files).
2. **Inspect Existing Documentation Conventions:** Read the target file and neighboring files. Determine comment placement, prefix (prefer `#`), structure (one-line vs. structured blocks), section labels, indentation, and terminology.
3. **Inspect the Function Implementation:** Read the complete function body. Inspect definitions, branches, variable assignments, positional parameters, invoked commands, redirections, error handling (`return`, `exit`), file modifications, shell options, and traps.
4. **Inspect Call Sites and Tests:** When available, inspect callers and tests to establish intended usage, argument formats, stdout capture, exit status dependencies, and documented edge cases.
5. **Build a Function Contract:** Identify the verified contract: purpose, inputs/arguments, stdin/stdout/stderr behavior, return status semantics, side effects, dependencies, and failure conditions. Include only sections supported by evidence.
6. **Write or Update the Documentation:** Write concise, specific documentation. Prioritize information callers and maintainers need. Consolidate related information. Avoid narrating every implementation line.
7. **Verify Against the Code:** Review each claim against the implementation. Pay attention to arguments, defaults, stdout/stderr vs. exit status, side effects, and portability claims. Revise or remove unsupported claims.
8. **Validate:** Run repository validation tools (`make lint`, `make validate`) if available. Inspect the final diff to confirm only intended documentation modifications were made.
9. **Report Results:** Adapt the final response to the user's requested task. For writing/update tasks, report the documented functions and contract details. For review-only tasks, report findings without modifying files. For draft-only tasks, provide the proposed comment in a code block.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

### Documentation Format and Style

- **MUST** use comments supported by the target shell (prefer `#` for Bash/POSIX) placed immediately before the function definition.
- **MUST** use consistent labels for arguments, outputs, return statuses, side effects, and dependencies where applicable.
- **MUST** use backticks for function names, variables, commands, paths, and environment variables.
- **MUST** describe positional parameters using `$1`, `$2`, and `$@` unless the function assigns them to named local variables that form the public interface.
- **SHOULD** explain the function's purpose and observable behavior first, before diving into parameters.
- **MUST NOT** add empty documentation sections merely to satisfy a template.
- **MUST NOT** duplicate the entire function implementation in prose.

### Function Contract Elements

- **Purpose:** MUST explain what the function does using a concise, specific description. MUST NOT claim a function validates, sanitizes, or guarantees something unless the implementation supports it.
- **Arguments:** MUST document purpose, type/format, required/optional status, defaults, and validation constraints for meaningful arguments.
- **Standard I/O:** MUST distinguish stdout (data) from stderr (diagnostics). MUST document stdin consumption only if confirmed by the execution path.
- **Return Status:** MUST document meaningful exit statuses (e.g., `0` for success, `1` for invalid input). MUST account for implicit exit statuses from the last executed command.
- **Side Effects:** MUST document observable side effects (file mutations, global variables, directory changes, traps, exported variables). MUST NOT write `Side effects: None` unless verified.
- **Dependencies:** MUST document external commands, Bash-specific built-ins, required environment variables, or filesystem assumptions that materially affect execution.

### Bash and POSIX Shell Compatibility

- **MUST NOT** rewrite Bash documentation as if the function were portable POSIX Shell.
- **MUST** inspect the shebang, syntax (`[[ ... ]]`, arrays), and built-ins to determine the actual dialect.
- **MUST NOT** change the shebang or refactor incompatible syntax as part of a documentation-only task.
- **MUST** flag uncertainty if compatibility cannot be established confidently and materially affects the documentation.

## Examples (good vs. bad, with realistic code or output)

**Good: Concise, Evidence-Based Contract**

```bash
# resolve_config_path resolves the configuration file path.
#
# Arguments:
#   $1 (string): Configuration file path or directory to resolve.
#
# Outputs:
#   Writes the resolved configuration path to stdout.
#
# Returns:
#   0: The path was resolved successfully.
#   1: The configuration path is invalid or cannot be resolved.
#
# Dependencies:
#   Uses `dirname` and `realpath`.
resolve_config_path() {
    local path="$1"
    if [[ -z "$path" ]]; then return 1; fi
    realpath -q "$path" || return 1
}
```

**Bad: JavaDoc Hangover & Invented Guarantees**

```bash
# Processes data.
# @param file The file to process
# @return boolean True if successful
process_data() {
    # Implementation omitted.
}
# Why it's bad: Uses generic "Processes data", unsupported @param/@return tags
# not natively parsed by shell tools, and claims a boolean return which shell
# functions do not support natively (they use exit statuses).
```

**Good: Documenting Side Effects and Stderr**

```bash
# ensure_log_dir creates the log directory if it does not exist.
#
# Side effects:
#   Creates the directory specified by $LOG_DIR.
#
# Outputs:
#   Writes a warning to stderr if the directory cannot be created.
#
# Returns:
#   0: Directory exists or was created.
#   1: Failed to create directory.
ensure_log_dir() { ... }
```

## Checklist (verifiable, copy-pasteable)

- [ ] Source code, callers, and tests were inspected before writing documentation.
- [ ] Documentation format matches existing repository conventions.
- [ ] Purpose is specific and matches the actual implementation.
- [ ] Arguments, defaults, and constraints are documented accurately.
- [ ] Stdout (data) and stderr (diagnostics) are distinguished.
- [ ] Return statuses are documented based on actual `return`/`exit` statements or last-command status.
- [ ] Side effects (file changes, global state, directory changes) are documented.
- [ ] Bash-specific features are not falsely claimed as POSIX-portable.
- [ ] No unsupported guarantees about safety, atomicity, or error handling were invented.
- [ ] Function implementation and runtime behavior remain unchanged.
- [ ] Repository validation tools (`make validate`, `make lint`) were run if available.

## Common Pitfalls

- **Invented Guarantees:** Claiming a function is safe, atomic, idempotent, or gracefully handles all errors just because it uses `set -e` or `|| return`, without verifying the actual control flow and cleanup.
- **Confusing Stdout with Return Status:** Documenting that a function "returns a string" via stdout, while confusing shell exit statuses (`$?`) with programming language return values.
- **The "No Side Effects" Lie:** Writing `Side effects: None` without verifying if the function modifies global variables, exports environment variables, or changes the current working directory.
- **Over-Documenting the Obvious:** Narrating every line of code or listing every standard utility used (like `echo` or `grep`) when it adds no practical value to the caller.
- **Ignoring the Dialect:** Treating a script with `[[ ... ]]` and `local` arrays as POSIX-compliant, leading to inaccurate portability claims.
- **Silent Behavior Changes:** Modifying the function's runtime behavior to match an outdated or incorrect existing comment.

## References (official docs, standards)

- GNU Bash Reference Manual (Behavior of built-ins, parameter expansion, and shell options).
- POSIX Shell Command Language (Standard for portable shell scripting).
- Google Shell Style Guide (Common conventions for bash script structure and comments).
- Project-specific `CONTRIBUTING.md` or existing shell style guides.
- The Agent Skills open standard (for skill frontmatter and structure).
