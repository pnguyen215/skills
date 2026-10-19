---
name: refactoring
description: 'Strategies for eliminating code smells, applying SOLID, and improving cohesion. Trigger: "refactor this code", "clean up legacy", "remove code smells".'
---

# Refactoring

## Purpose

Improves internal structure without changing external behavior.

## When to Use / When NOT to Use

- **Use**: Paying tech debt, improving cohesion, preparing for new features.
- **NOT**: Adding new features (mix concerns).

## Prerequisites & Assumptions

- High test coverage. Static analysis tools configured.

## Step-by-Step Workflow

1. Identify smells (e.g., Long Method, God Class).
2. Write characterization tests if missing.
3. Apply pattern (e.g., Extract Method, Replace Conditional).
4. Verify tests pass and commit small changes.

## Enterprise Rules & Standards

- **MUST**: Have tests before refactoring.
- **MUST**: Make small, reversible commits.
- **SHOULD**: Follow the Boy Scout Rule (leave code cleaner).
- **MUST NOT**: Refactor and add features in the same PR.

## Examples

- **Bad**: Rewriting 10k lines in one massive commit.
- **Good**: Extracting a method to reduce complexity in a 5-line commit.

## Checklist

- [ ] Tests exist and pass.
- [ ] Small commits used.
- [ ] Targeted smells removed.

## Common Pitfalls

- Gold-plating (refactoring without business value).
- Breaking tests and ignoring failures.

## References

- [Refactoring Guru](https://refactoring.guru/)
