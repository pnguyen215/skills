---
name: golang
description: 'Enterprise Go standards: modules, generics, slog, context propagation, concurrency. Trigger: "Go best practices", "write idiomatic Go", "golang review".'
---

# Enterprise Go Standards

## Purpose

Ensures Go code is idiomatic, performant, and secure.

## When to Use / When NOT to Use

- **Use**: Writing new Go services, reviewing Go PRs, modernizing legacy Go.
- **NOT**: Quick bash/python scripts.

## Prerequisites & Assumptions

- Go 1.21+ (Modules, Generics, `slog`).

## Step-by-Step Workflow

1. Use Go modules and strict versioning.
2. Apply structured logging (`log/slog`).
3. Propagate `context.Context` everywhere.
4. Handle errors explicitly and wrap with `%w`.

## Enterprise Rules & Standards

- **MUST**: Propagate `context.Context` as the first argument.
- **MUST**: Wrap errors with `%w` for chainability.
- **SHOULD**: Use `slog` for structured, JSON-friendly logs.
- **MUST NOT**: Use `init()` for complex logic or side effects.

## Examples

- **Bad**: `func Get() { log.Println("error") }`
- **Good**: `func Get(ctx context.Context) error { return fmt.Errorf("failed: %w", err) }`

## Checklist

- [ ] Context passed.
- [ ] Errors wrapped.
- [ ] Slog used.

## Common Pitfalls

- Goroutine leaks (missing `context` cancellation).
- Ignoring errors or using `panic` for control flow.

## References

- [Effective Go](https://go.dev/doc/effective_go)
