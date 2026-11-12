---
name: testing-test-coverage
description: 'Meaningful coverage metrics, branch vs line coverage, mutation testing. Trigger: "increase test coverage", "setup mutation testing", "codecov".'
metadata:
  category: testing
  tags: "testing, coverage, branch-coverage, mutation-testing, metrics"
---

# Testing: Coverage

## Purpose

Measures the degree to which source code is executed by tests. This skill measures coverage and adds targeted tests for uncovered logic; it does NOT change production code or enforce merge gates.

## When to Use / When NOT to Use

- **Use**: Identifying untested paths, CI quality gates.
- **NOT**: Guaranteeing quality (100% coverage != 0 bugs).
- **NOT**: Blocking merges on thresholds (use `ci-cd-quality-gates`).
- **NOT**: Designing the overall test strategy (use `testing-test-strategy`) or writing unit tests from scratch with TDD (use `testing-unit-testing`).

## Prerequisites & Assumptions

- Coverage tool (`gcov`, `coverage.py`, `jacoco`).

### Scope & Context Resolution

- **Supported scopes**: repository (default), directory/module/package, file, function/method, coverage report.
- **Rule 1 - Explicit context in the prompt**: Stated tools, thresholds, versions and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at repository scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to test files and coverage configuration for the resolved scope. MUST NOT edit production code.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Run tests with coverage flag.
3. Generate HTML/LCOV report.
4. Identify uncovered branches and edge cases in the resolved scope.
5. Write targeted tests for missing logic.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Track branch coverage, not just line coverage.
- **MUST**: Set minimum threshold (e.g., 80%) in CI.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use mutation testing (Stryker, `go-mutesting`) for critical logic.
- **MUST NOT**: Write useless tests (e.g., `assert(true)`) just for %.
- **MUST NOT**: Alter production code or tests for other packages to move the number.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `assert(true)` to boost coverage numbers.
- **Good**: Testing error paths, boundaries, and edge cases.
- **Good (scoped)**: Prompt "only `pkg/parser`" -> report and cover uncovered branches in that package; note low coverage in `pkg/cache`.
- **Bad (scope-expanding)**: Same prompt -> add tests across all packages and refactor code to make it testable.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Branch coverage > 80%.
- [ ] Mutation score checked (if applicable).
- [ ] Report generated in CI.

## Common Pitfalls

- 100% coverage fallacy (testing getters/setters).
- Ignoring branch coverage.
- Chasing the repository-wide percentage when asked about one package.

## References (official docs, standards)

- [Martin Fowler: Test Coverage](https://martinfowler.com/bliki/TestCoverage.html)
