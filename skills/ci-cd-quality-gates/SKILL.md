---
name: ci-cd-quality-gates
description: 'Enforce automated quality gates (SonarQube, coverage, linting). Trigger: "setup quality gate", "block PR on lint failure", "enforce coverage".'
metadata:
  category: ci-cd
---

# Quality Gates

## Purpose

Prevents merging code that violates security, reliability, or maintainability thresholds.

## When to Use / When NOT to Use

- **Use**: Configuring PR blockers, enforcing test coverage, integrating SonarQube.
- **NOT**: Local development feedback loops (use IDE plugins instead).

## Prerequisites & Assumptions

- CI pipeline configured. Static analysis tools installed.

## Step-by-Step Workflow

1. Define metrics (coverage > 80%, 0 critical CVEs).
2. Integrate tools (SonarQube, Codecov, golangci-lint).
3. Configure PR branch protection rules.
4. Setup failure notifications.

## Enterprise Rules & Standards

- **MUST**: Block PR merge if quality gate fails.
- **MUST**: Enforce minimum test coverage thresholds.
- **SHOULD**: Fail builds on new security vulnerabilities.
- **MUST NOT**: Allow manual overrides of failed gates without VP approval.

## Examples

- **Bad**: Allowing merge with 40% test coverage.
- **Good**: PR blocked by Codecov due to patch coverage < 90%.

## Checklist

- [ ] Coverage thresholds enforced.
- [ ] SAST blocks critical CVEs.
- [ ] Branch protection rules active.

## Common Pitfalls

- Setting thresholds too high initially, causing blocker fatigue.
- Flaky tests blocking legitimate merges.

## References

- [SonarQube Quality Gates](https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/quality-gates/)
