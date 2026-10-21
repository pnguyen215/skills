---
name: testing-test-coverage
description: 'Meaningful coverage metrics, branch vs line coverage, mutation testing. Trigger: "increase test coverage", "setup mutation testing", "codecov".'
metadata:
  category: testing
  tags: "testing, coverage, branch-coverage, mutation-testing, metrics"
---

# Testing: Coverage

## Purpose

Measures the degree to which source code is executed by tests.

## When to Use / When NOT to Use

- **Use**: Identifying untested paths, CI quality gates.
- **NOT**: Guaranteeing quality (100% coverage != 0 bugs).

## Prerequisites & Assumptions

- Coverage tool (`gcov`, `coverage.py`, `jacoco`).

## Step-by-Step Workflow

1. Run tests with coverage flag.
2. Generate HTML/LCOV report.
3. Identify uncovered branches and edge cases.
4. Write targeted tests for missing logic.

## Enterprise Rules & Standards

- **MUST**: Track branch coverage, not just line coverage.
- **MUST**: Set minimum threshold (e.g., 80%) in CI.
- **SHOULD**: Use mutation testing (Stryker, `go-mutesting`) for critical logic.
- **MUST NOT**: Write useless tests (e.g., `assert(true)`) just for %.

## Examples

- **Bad**: `assert(true)` to boost coverage numbers.
- **Good**: Testing error paths, boundaries, and edge cases.

## Checklist

- [ ] Branch coverage > 80%.
- [ ] Mutation score checked (if applicable).
- [ ] Report generated in CI.

## Common Pitfalls

- 100% coverage fallacy (testing getters/setters).
- Ignoring branch coverage.

## References

- [Martin Fowler: Test Coverage](https://martinfowler.com/bliki/TestCoverage.html)
