---
name: code-quality-static-analysis
description: 'Configuration and enforcement of linters, SAST, and complexity metrics. Trigger: "setup linters", "configure golangci-lint", "fix lint errors".'
metadata:
  category: code-quality
  tags: "static-analysis, linting, sast, complexity, code-quality"
---

# Static Analysis

## Purpose

Automates detection of bugs, smells, and security flaws.

## When to Use / When NOT to Use

- **Use**: Setting up CI checks, enforcing code style, pre-commit hooks.
- **NOT**: Runtime debugging or dynamic analysis.

## Prerequisites & Assumptions

- Source code access. Tool binaries (golangci-lint, eslint, pylint).

## Step-by-Step Workflow

1. Select tools (golangci-lint, SonarQube, Semgrep).
2. Configure rulesets (start with strict presets).
3. Integrate into pre-commit hooks & CI.
4. Fix baseline issues before enforcing blocks.

## Enterprise Rules & Standards

- **MUST**: Run linters in CI and fail on errors.
- **MUST**: Use pre-commit hooks for local feedback.
- **SHOULD**: Use strict presets (e.g., `airbnb`, `golangci-lint` strict).
- **MUST NOT**: Disable rules globally without documented justification.

## Examples

- **Bad**: `//nolint:all` at the top of the file.
- **Good**: Fixing the root cause of the lint error.

## Checklist

- [ ] Linters in CI pipeline.
- [ ] Pre-commit hooks active.
- [ ] Zero baseline errors.

## Common Pitfalls

- Alert fatigue from too many warnings.
- Ignoring security-focused SAST rules.

## References

- [golangci-lint](https://golangci-lint.run/)
