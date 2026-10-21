---
name: testing-test-strategy
description: 'Test Pyramids, integration testing, test environment management. Trigger: "design test strategy", "test pyramid rules", "integration tests".'
metadata:
  category: testing
  tags: "testing, test-pyramid, integration-testing, test-environments, strategy"
---

# Testing: Strategy

## Purpose

Defines the mix of tests to ensure fast, reliable feedback.

## When to Use / When NOT to Use

- **Use**: New projects, scaling test suites, CI/CD design.
- **NOT**: Fixing a single failing test.

## Prerequisites & Assumptions

- CI/CD pipeline available.

## Step-by-Step Workflow

1. Define Test Pyramid ratios (Many Unit, Few Integration, Minimal E2E).
2. Setup integration test env (Testcontainers, LocalStack).
3. Define E2E scope (critical user journeys only).
4. Automate execution and cleanup.

## Enterprise Rules & Standards

- **MUST**: Follow Test Pyramid (avoid Ice Cream Cone).
- **MUST**: Use Testcontainers for DB/Queue dependencies.
- **SHOULD**: Keep E2E tests fast (< 5 mins total).
- **MUST NOT**: Rely on shared staging DBs for unit/integration tests.

## Examples

- **Bad**: 1000 Selenium tests, 0 unit tests.
- **Good**: Fast unit tests, targeted integration with Testcontainers.

## Checklist

- [ ] Pyramid followed.
- [ ] Testcontainers used.
- [ ] E2E fast and reliable.

## Common Pitfalls

- Ice cream cone anti-pattern (too many E2E).
- Flaky E2E tests blocking CI.

## References

- [Google Testing Blog: Test Pyramid](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html)
