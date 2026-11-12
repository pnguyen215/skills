---
name: ci-cd-quality-gates
description: 'Enforce automated quality gates (SonarQube, coverage, linting). Trigger: "setup quality gate", "block PR on lint failure", "enforce coverage".'
metadata:
  category: ci-cd
  tags: "ci-cd, quality-gate, sonarqube, coverage, linting"
---

# Quality Gates

## Purpose

Prevents merging code that violates security, reliability, or maintainability thresholds. This skill defines and configures gate thresholds and merge blockers only; it does NOT author whole CI pipelines or write tests and lint fixes.

## When to Use / When NOT to Use

- **Use**: Configuring PR blockers, enforcing test coverage, integrating SonarQube.
- **NOT**: Local development feedback loops (use IDE plugins instead).
- **NOT**: Designing the full build/deploy pipeline (use `ci-cd-pipelines`).
- **NOT**: Configuring linter rulesets (use `code-quality-static-analysis`) or raising coverage by writing tests (use `testing-test-coverage`).

## Prerequisites & Assumptions

- CI pipeline configured. Static analysis tools installed.

### Scope & Context Resolution

- **Supported scopes**: repository (default), pipeline file/job, single gate (coverage, lint, SAST), branch protection rule.
- **Rule 1 - Explicit context in the prompt**: Stated thresholds, tools, versions, targets and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at repository scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to quality-gate configuration (gate definitions, CI gate steps, protection rules) inside the resolved scope. MUST NOT edit application code or tests.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Define metrics (coverage > 80%, 0 critical CVEs) for the resolved scope.
3. Integrate tools (SonarQube, Codecov, golangci-lint) only for the gates in scope.
4. Configure PR branch protection rules.
5. Setup failure notifications.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Block PR merge if quality gate fails.
- **MUST**: Enforce minimum test coverage thresholds.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Fail builds on new security vulnerabilities.
- **MUST NOT**: Allow manual overrides of failed gates without VP approval.
- **MUST NOT**: Rewrite an entire pipeline or change unrelated jobs when asked about one gate.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Allowing merge with 40% test coverage.
- **Good**: PR blocked by Codecov due to patch coverage < 90%.
- **Good (scoped)**: Prompt "only the coverage gate in `ci.yml`" -> add a patch-coverage threshold step to that job; note that lint is ungated without changing it.
- **Bad (scope-expanding)**: Same prompt -> also restructure the workflow matrix, add SonarQube and edit branch protection.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Coverage thresholds enforced.
- [ ] SAST blocks critical CVEs.
- [ ] Branch protection rules active.

## Common Pitfalls

- Setting thresholds too high initially, causing blocker fatigue.
- Flaky tests blocking legitimate merges.
- Rewriting the whole pipeline when asked to add one gate.

## References (official docs, standards)

- [SonarQube Quality Gates](https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/quality-gates/)
