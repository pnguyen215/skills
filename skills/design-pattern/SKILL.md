---
name: design-pattern
description: 'Application of Gang of Four and enterprise integration patterns. Trigger: "apply design pattern", "refactor to strategy", "decouple components".'
metadata:
  category: design
  tags: "design-patterns, gof, enterprise-integration, architecture, refactoring"
---

# Design Patterns

## Purpose

Provides proven solutions to common software design problems. This skill selects and applies a pattern to a named design problem; it does NOT redesign whole systems or refactor code unrelated to that problem.

## When to Use / When NOT to Use

- **Use**: Solving complex object interactions, decoupling, extensibility.
- **NOT**: Simple CRUD logic or over-engineering simple scripts.
- **NOT**: Whole-architecture evaluation (use `system-design-reviewer`).
- **NOT**: General smell cleanup or SOLID refactoring without a pattern (use `code-quality-refactoring`).

## Prerequisites & Assumptions

- OOP/SOLID understanding.

### Scope & Context Resolution

- **Supported scopes**: class/type (default), function/method, file, package/module, repository.
- **Rule 1 - Explicit context in the prompt**: Stated language, pattern, constraints and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at class/type scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to the types and call sites required to introduce the pattern inside the resolved scope.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Identify problem (e.g., tight coupling, varying algorithms).
3. Select pattern (e.g., Strategy, Observer, Factory).
4. Implement interface/abstraction within the resolved scope.
5. Verify flexibility and testability.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Favor composition over inheritance.
- **MUST**: Program to interfaces, not implementations.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Keep patterns simple (KISS).
- **MUST NOT**: Force patterns where not needed (Pattern Obsession).
- **MUST NOT**: Introduce additional patterns or restructure neighbouring modules beyond the named problem.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Using Factory for a single static class.
- **Good**: Strategy pattern for pluggable payment providers.
- **Good (scoped)**: Prompt "only `PaymentService`" -> extract a `PaymentProvider` interface and inject it into that class; note similar switch statements elsewhere.
- **Bad (scope-expanding)**: Same prompt -> also add Factory, Observer and rewrite `OrderService` and `InvoiceService`.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Pattern justified.
- [ ] Interfaces defined.
- [ ] Coupling reduced.

## Common Pitfalls

- Over-engineering.
- Inheritance hierarchies too deep.
- Applying a pattern to every neighbouring class when asked about one.

## References (official docs, standards)

- [Design Patterns: Elements of Reusable Object-Oriented Software](https://en.wikipedia.org/wiki/Design_Patterns)
