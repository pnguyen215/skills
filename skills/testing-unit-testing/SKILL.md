---
name: testing-unit-testing
description: 'FIRST principles, mocking vs stubbing, TDD workflows. Trigger: "write unit tests", "mock database", "TDD", "test isolation".'
metadata:
  category: testing
  tags: "testing, unit-testing, tdd, mocking, first-principles"
---

# Testing: Unit Testing

## Purpose

Verifies individual components in isolation.

## When to Use / When NOT to Use

- **Use**: Business logic, utilities, parsers, algorithms.
- **NOT**: Testing full HTTP flows or DB connections (use integration).

## Prerequisites & Assumptions

- Test framework (`Jest`, `pytest`, `testing`, `JUnit`).

## Step-by-Step Workflow

1. Arrange (setup state and mocks).
2. Act (call function under test).
3. Assert (verify output and mock interactions).
4. Use table-driven tests for multiple cases.

## Enterprise Rules & Standards

- **MUST**: Follow FIRST (Fast, Isolated, Repeatable, Self-validating, Timely).
- **MUST**: Mock external systems (DB, HTTP, Filesystem).
- **SHOULD**: Use table-driven / parameterized tests.
- **MUST NOT**: Test third-party library internals.

## Examples

- **Bad**: Unit test hitting real production DB.
- **Good**: Mocking DB repository interface to return fake data.

## Checklist

- [ ] FIRST principles followed.
- [ ] External deps mocked.
- [ ] Table-driven tests used.

## Common Pitfalls

- Testing implementation details instead of behavior.
- Slow unit tests due to real I/O.

## References

- [xUnit Test Patterns](http://xunitpatterns.com/)
