---
name: code-quality-refactoring
description: 'Strategies for eliminating code smells, applying SOLID, and improving cohesion. Trigger: "refactor this code", "clean up legacy", "remove code smells".'
metadata:
  category: code-quality
  tags: "refactoring, code-smells, solid, cohesion, clean-code"
---

# Refactoring

## Purpose

Improves internal structure without changing external behavior. This skill may edit code inside the requested scope; it does NOT add features, fix unrelated bugs, or change public contracts.

## When to Use / When NOT to Use

- **Use**: Paying tech debt, improving cohesion, preparing for new features.
- **NOT**: Adding new features (mix concerns).
- **NOT**: Review-only feedback on a PR (use `code-quality-code-review`).
- **NOT**: Linter/SAST configuration (use `code-quality-static-analysis`).
- **NOT**: Choosing or applying a specific GoF pattern as the goal (use `design-pattern`).

## Prerequisites & Assumptions

- High test coverage. Static analysis tools configured.

### Scope & Context Resolution

- **Supported scopes**: repository, directory/module/package, file, class/type, function/method. Default: the file(s) or symbol the user points at; if none is given, the files in the current change.
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, constraints, language versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Behavior-preserving edits to code (and its characterization tests) inside the resolved scope only. Callers outside the scope MUST NOT be edited; if a signature change would break them, report it instead.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply Scope & Context Resolution; state the resolved scope and mutation boundary in one line at the start of the output.
2. Identify smells in scope (e.g., Long Method, God Class).
3. Write characterization tests if missing.
4. Apply pattern (e.g., Extract Method, Replace Conditional) only to the in-scope smells.
5. Verify tests pass and commit small changes.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Have tests before refactoring.
- **MUST**: Make small, reversible commits.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Follow the Boy Scout Rule (leave code cleaner) inside the resolved scope.
- **MUST NOT**: Refactor and add features in the same PR.
- **MUST NOT**: Refactor neighbouring files or rename public APIs outside the scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Rewriting 10k lines in one massive commit.
- **Good**: Extracting a method to reduce complexity in a 5-line commit.
- **Good (scoped)**: Prompt "refactor only `calculateTotal()`" -> extract helpers inside that function, keep its signature, run its tests; note that `OrderService` has a God Class smell.
- **Bad (scope-expanding)**: Same prompt -> split `OrderService` into three classes and update all callers.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Tests exist and pass.
- [ ] Small commits used.
- [ ] Targeted smells removed.

## Common Pitfalls

- Gold-plating (refactoring without business value).
- Breaking tests and ignoring failures.
- Scope creep: refactoring neighbouring files while "in the area".

## References (official docs, standards)

- [Refactoring Guru](https://refactoring.guru/)
