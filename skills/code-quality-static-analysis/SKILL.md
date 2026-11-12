---
name: code-quality-static-analysis
description: 'Configuration and enforcement of linters, SAST, and complexity metrics. Trigger: "setup linters", "configure golangci-lint", "fix lint errors".'
metadata:
  category: code-quality
  tags: "static-analysis, linting, sast, complexity, code-quality"
---

# Static Analysis

## Purpose

Automates detection of bugs, smells, and security flaws. This skill configures and runs analyzers and fixes findings they report; it does NOT perform runtime debugging, design refactors, or gate merges.

## When to Use / When NOT to Use

- **Use**: Setting up CI checks, enforcing code style, pre-commit hooks.
- **NOT**: Runtime debugging or dynamic analysis.
- **NOT**: Merge-blocking thresholds and branch protection (use `ci-cd-quality-gates`).
- **NOT**: Structural refactoring beyond the lint fix (use `code-quality-refactoring`).

## Prerequisites & Assumptions

- Source code access. Tool binaries (golangci-lint, eslint, pylint).

### Scope & Context Resolution

- **Supported scopes**: repository (default), directory/module/package, file, linter config file, single rule.
- **Rule 1 - Explicit context in the prompt**: Stated tools, versions, rulesets and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at repository scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to analyzer configuration, hook/CI check steps, and lint fixes in files inside the resolved scope. MUST NOT change behavior beyond what a finding requires.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Select tools (golangci-lint, SonarQube, Semgrep).
3. Configure rulesets (start with strict presets).
4. Integrate into pre-commit hooks & CI, only for the resolved scope.
5. Fix baseline issues in scope before enforcing blocks.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Run linters in CI and fail on errors.
- **MUST**: Use pre-commit hooks for local feedback.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use strict presets (e.g., `airbnb`, `golangci-lint` strict).
- **MUST NOT**: Disable rules globally without documented justification.
- **MUST NOT**: Fix findings in files outside the resolved scope or reformat unrelated code.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `//nolint:all` at the top of the file.
- **Good**: Fixing the root cause of the lint error.
- **Good (scoped)**: Prompt "fix lint errors only in `internal/auth`" -> fix findings in that package; list findings in `internal/db` as notes.
- **Bad (scope-expanding)**: Same prompt -> run `--fix` repo-wide and tighten the global `.golangci.yml`.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Linters in CI pipeline.
- [ ] Pre-commit hooks active.
- [ ] Zero baseline errors.

## Common Pitfalls

- Alert fatigue from too many warnings.
- Ignoring security-focused SAST rules.
- Running auto-fix across the whole repository when asked about one package.

## References (official docs, standards)

- [golangci-lint](https://golangci-lint.run/)
