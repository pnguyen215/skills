---
name: replify-go-api-design
description: 'Designs ergonomic, chainable Go APIs using functional options and fluent setters. Trigger: "functional options pattern", "fluent setters Go", "With* options", "refactor options and setters".'
metadata:
  category: ecosystem-replify
  tags: "replify, golang, api-design, functional-options, fluent-api"
---

# Go: Ergonomic API Design (Options & Setters)

## Purpose

Creates human-readable, type-safe, and extensible configuration APIs for structs and builders using functional options and fluent setters. Responsibility boundary: edits option and setter code of the named types; does NOT change struct encapsulation/defensive copying (see `replify-go-encapsulation`) or unrelated behavior.

## When to Use / When NOT to Use

- **Use**: Configuring complex structs, builders, client initializations, and library APIs.
- **NOT**: Simple structs with < 3 fields or high-frequency hot-path objects where allocation overhead of functional options matters.
- **NOT**: Nil-safe getters and defensive copying (use `replify-go-encapsulation`).
- **NOT**: Logging, string building or string utilities (use `replify-slogger`, `replify-strchain`, `replify-strutil`).

## Prerequisites & Assumptions

- Go standard library.
- Strict file organization (`options.go`, `utilities.go`).

### Scope & Context Resolution

- **Supported scopes**: package/directory (default), file, struct/type, single option or setter (function/method).
- **Rule 1 - Explicit context**: The user's stated requirements, constraints, versions, targets and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line. Security/data-loss rules stay mandatory; flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at package scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to `options.go`, `utilities.go`, and setter methods of the types in scope. MUST NOT change exported signatures outside the scope.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Define typed constants for finite options (e.g., `LogLevel`, `Protocol`).
3. Create `With*` functional options in `options.go`.
4. Create fluent `Set*` methods on the struct that return `*T`.
5. Delegate parsing of human-readable strings to unexported helpers in `utilities.go`.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: `With*` functions MUST live exclusively in `options.go`.
- **MUST**: `Set*` methods MUST return the pointer receiver (`*T`) to enable method chaining.
- **MUST**: Accept human-readable inputs (e.g., `"5s"`, `"debug"`) and parse internally using unexported utilities.
- **MUST NOT**: Use `void` setters or expose raw integer flags for enums.
- **MUST NOT**: Convert setters or options on types outside the requested scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `cfg := &Config{Timeout: 5000, Level: 2}` (Magic numbers, void setters)
- **Good**: `cfg := NewConfig(WithTimeout("5s"), WithLevel(LevelDebug))` (Human-readable, chainable)
- **Scope - Good**: Prompt "only `Client` in package `httpx`" -> add `WithTimeout` to `options.go` and make `Client.SetRetries` return `*Client`; note that `Server` has void setters.
- **Scope - Bad**: Same prompt -> converting `Server` and every other struct in the module.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] `With*` options created in `options.go`.
- [ ] Fluent setters return `*T`.
- [ ] Typed constants used for enums.
- [ ] Parsing logic delegated to `utilities.go`.

## Common Pitfalls

- Mixing functional options with direct struct field assignment in the constructor.
- Creating too many `With*` options for simple boolean flags (consider a single `WithFeatures(...)` option).
- Refactoring every struct in the package when one type was named.

## References (official docs, standards)

- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments)
- [Rob Pike: Self-referential functions and the design of options](https://commandcenter.blogspot.com/2014/01/self-referential-functions-and-design.html)
