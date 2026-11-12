---
name: testing-test-strategy
description: 'Test Pyramids, integration testing, test environment management. Trigger: "design test strategy", "test pyramid rules", "integration tests".'
metadata:
  category: testing
  tags: "testing, test-pyramid, integration-testing, test-environments, strategy"
---

# Testing: Strategy

## Purpose

Defines the mix of tests to ensure fast, reliable feedback. Responsibility boundary: designs test strategy and test environments; does NOT write individual unit tests or measure coverage.

## When to Use / When NOT to Use

- **Use**: New projects, scaling test suites, CI/CD design.
- **NOT**: Fixing a single failing test.
- **NOT**: Writing unit tests, mocks or TDD loops (use `testing-unit-testing`).
- **NOT**: Coverage metrics and mutation testing (use `testing-test-coverage`).

## Prerequisites & Assumptions

- CI/CD pipeline available.

### Scope & Context Resolution

- **Supported scopes**: repository (default), module/service, single test layer (integration or E2E), test environment config, CI test stage.
- **Rule 1 - Explicit context**: The user's stated requirements, constraints, versions, targets and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line. Security/data-loss rules stay mandatory; flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at repository scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to strategy docs, test environment/CI config and test layout in scope. MUST NOT rewrite existing test bodies unless asked.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Define Test Pyramid ratios (Many Unit, Few Integration, Minimal E2E).
3. Setup integration test env (Testcontainers, LocalStack).
4. Define E2E scope (critical user journeys only).
5. Automate execution and cleanup.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Follow Test Pyramid (avoid Ice Cream Cone).
- **MUST**: Use Testcontainers for DB/Queue dependencies.
- **SHOULD**: Keep E2E tests fast (< 5 mins total).
- **MUST NOT**: Rely on shared staging DBs for unit/integration tests.
- **MUST NOT**: Restructure the whole test suite when asked about one layer or service.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: 1000 Selenium tests, 0 unit tests.
- **Good**: Fast unit tests, targeted integration with Testcontainers.
- **Scope - Good**: Prompt "only integration tests for `orders-service`" -> Testcontainers setup for its Postgres; note E2E gaps without changing them.
- **Scope - Bad**: Same prompt -> redefining pyramid ratios and rewriting E2E suites for all services.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Pyramid followed.
- [ ] Testcontainers used.
- [ ] E2E fast and reliable.

## Common Pitfalls

- Ice cream cone anti-pattern (too many E2E).
- Flaky E2E tests blocking CI.
- Reorganizing every test directory when one layer was requested.

## References (official docs, standards)

- [Google Testing Blog: Test Pyramid](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html)
- [Testcontainers](https://testcontainers.com/)
- [Martin Fowler: Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html)
