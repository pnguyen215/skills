---
name: replify-go-api-design
description: 'Designs ergonomic, chainable Go APIs using functional options and fluent setters. Trigger: "functional options pattern", "fluent setters Go", "With* options", "refactor options and setters".'
metadata:
  category: ecosystem-replify
---

# Go: Ergonomic API Design (Options & Setters)

## Purpose

Creates human-readable, type-safe, and extensible configuration APIs for structs and builders using functional options and fluent setters.

## When to Use / When NOT to Use

- **Use**: Configuring complex structs, builders, client initializations, and library APIs.
- **NOT**: Simple structs with < 3 fields or high-frequency hot-path objects where allocation overhead of functional options matters.

## Prerequisites & Assumptions

- Go standard library.
- Strict file organization (`options.go`, `utilities.go`).

## Step-by-Step Workflow

1. Define typed constants for finite options (e.g., `LogLevel`, `Protocol`).
2. Create `With*` functional options in `options.go`.
3. Create fluent `Set*` methods on the struct that return `*T`.
4. Delegate parsing of human-readable strings to unexported helpers in `utilities.go`.

## Enterprise Rules & Standards

- **MUST**: `With*` functions MUST live exclusively in `options.go`.
- **MUST**: `Set*` methods MUST return the pointer receiver (`*T`) to enable method chaining.
- **MUST**: Accept human-readable inputs (e.g., `"5s"`, `"debug"`) and parse internally using unexported utilities.
- **MUST NOT**: Use `void` setters or expose raw integer flags for enums.

## Examples

- **Bad**: `cfg := &Config{Timeout: 5000, Level: 2}` (Magic numbers, void setters)
- **Good**: `cfg := NewConfig(WithTimeout("5s"), WithLevel(LevelDebug))` (Human-readable, chainable)

## Checklist

- [ ] `With*` options created in `options.go`.
- [ ] Fluent setters return `*T`.
- [ ] Typed constants used for enums.
- [ ] Parsing logic delegated to `utilities.go`.

## Common Pitfalls

- Mixing functional options with direct struct field assignment in the constructor.
- Creating too many `With*` options for simple boolean flags (consider a single `WithFeatures(...)` option).
