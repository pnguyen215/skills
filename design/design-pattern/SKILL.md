---
name: design-pattern
description: 'Application of Gang of Four and enterprise integration patterns. Trigger: "apply design pattern", "refactor to strategy", "decouple components".'
---

# Design Patterns

## Purpose

Provides proven solutions to common software design problems.

## When to Use / When NOT to Use

- **Use**: Solving complex object interactions, decoupling, extensibility.
- **NOT**: Simple CRUD logic or over-engineering simple scripts.

## Prerequisites & Assumptions

- OOP/SOLID understanding.

## Step-by-Step Workflow

1. Identify problem (e.g., tight coupling, varying algorithms).
2. Select pattern (e.g., Strategy, Observer, Factory).
3. Implement interface/abstraction.
4. Verify flexibility and testability.

## Enterprise Rules & Standards

- **MUST**: Favor composition over inheritance.
- **MUST**: Program to interfaces, not implementations.
- **SHOULD**: Keep patterns simple (KISS).
- **MUST NOT**: Force patterns where not needed (Pattern Obsession).

## Examples

- **Bad**: Using Factory for a single static class.
- **Good**: Strategy pattern for pluggable payment providers.

## Checklist

- [ ] Pattern justified.
- [ ] Interfaces defined.
- [ ] Coupling reduced.

## Common Pitfalls

- Over-engineering.
- Inheritance hierarchies too deep.

## References

- [Design Patterns: Elements of Reusable Object-Oriented Software](https://en.wikipedia.org/wiki/Design_Patterns)
