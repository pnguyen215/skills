---
name: testing-unit-testing
description: 'FIRST principles, mocking vs stubbing, TDD workflows. Trigger: "write unit tests", "mock database", "TDD", "test isolation".'
metadata:
  category: testing
  tags: "testing, unit-testing, tdd, mocking, first-principles"
---

# Testing: Unit Testing

## Purpose

Verifies individual components in isolation. Responsibility boundary: writes and edits unit tests (and test doubles) in the named scope; does NOT change production code unless the user explicitly asks.

## When to Use / When NOT to Use

- **Use**: Business logic, utilities, parsers, algorithms.
- **NOT**: Testing full HTTP flows or DB connections (use integration).
- **NOT**: Overall test pyramid or environment planning (use `testing-test-strategy`).
- **NOT**: Coverage metrics or mutation testing setup (use `testing-test-coverage`).

## Prerequisites & Assumptions

- Test framework (`Jest`, `pytest`, `testing`, `JUnit`).

### Scope & Context Resolution

- **Supported scopes**: project/repository, directory/module/package, file, class/type, function/method, test file. Default when none is given: the code under test that the user names; if none is named, the files changed in the current working tree.
- **Rule 1 - Explicit context in the prompt**: the user's stated requirements, constraints, versions, frameworks, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules (no real production data or credentials in tests), which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to test files, fixtures and mocks for the resolved scope; MUST NOT modify production code to make tests pass.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Arrange (setup state and mocks).
3. Act (call function under test).
4. Assert (verify output and mock interactions).
5. Use table-driven tests for multiple cases.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Follow FIRST (Fast, Isolated, Repeatable, Self-validating, Timely).
- **MUST**: Mock external systems (DB, HTTP, Filesystem).
- **SHOULD**: Use table-driven / parameterized tests.
- **MUST NOT**: Test third-party library internals.
- **MUST NOT**: Change production code or add tests for units outside the named scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Unit test hitting real production DB.
- **Good**: Mocking DB repository interface to return fake data.

**Scope handling**

- **Prompt**: "Write unit tests only for `ParseAmount`."
- **Good**: Adds a table-driven test for `ParseAmount` (valid, empty, overflow); notes untested neighbours.
- **Bad**: Tests the whole package and refactors `ParseAmount` for testability.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] FIRST principles followed.
- [ ] External deps mocked.
- [ ] Table-driven tests used.

## Common Pitfalls

- Testing implementation details instead of behavior.
- Slow unit tests due to real I/O.
- Editing production code or other packages' tests while writing tests for one unit.

## References (official docs, standards)

- [xUnit Test Patterns](http://xunitpatterns.com/)
