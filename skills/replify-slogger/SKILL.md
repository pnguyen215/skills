---
name: replify-slogger
description: 'Guides the implementation of high-performance, zero-allocation structured logging using the replify/pkg/slogger package. Trigger: "setup slogger", "structured logging replify", "zero-alloc logger".'
metadata:
  category: ecosystem-replify
  tags: "replify, golang, logging, slog, zero-allocation"
---

# replify/slogger: Zero-Allocation Structured Logging

## Purpose

Standardizes production logging using `slogger` to ensure thread-safety, zero-allocation on hot paths, and proper context propagation, replacing standard `log/slog` or `logrus`.

## When to Use / When NOT to Use

- **Use**: All production services, high-throughput systems, CLI tools requiring structured output.
- **NOT**: Simple throwaway scripts where `fmt.Println` is sufficient.

## Prerequisites & Assumptions

- Go 1.21+ environment.
- `github.com/polarixa/replify/pkg/slogger` imported.

## Step-by-Step Workflow

1. Initialize `Logger` with `JSONFormatter` (production) or `TextFormatter` (development).
2. Bind static context fields using `logger.With(slogger.String("service", "api"))`.
3. Use typed field constructors (`slogger.String`, `slogger.Int`, `slogger.Err`) for log entries.
4. Propagate trace IDs via `slogger.WithContextFields(ctx, ...)`.

## Enterprise Rules & Standards

- **MUST**: Use typed field constructors (`slogger.Int`, `slogger.Err`) rather than `slogger.Any` to prevent reflection overhead and heap allocations.
- **MUST**: Configure `JSONFormatter` for all production environments to ensure log aggregator compatibility.
- **MUST NOT**: Retain `*Entry` objects after the logging call returns; they are recycled via `sync.Pool` and will be overwritten.
- **MUST NOT**: Perform blocking I/O or network calls inside a `Hook` without dispatching to a separate goroutine.

## Examples

- **Bad**: `logger.Info(fmt.Sprintf("user %s failed login: %v", u.ID, err))` (Causes allocations)
- **Good**: `logger.Info("login failed", slogger.String("user_id", u.ID), slogger.Err(err))`

## Checklist

- [ ] JSON formatter configured for prod.
- [ ] Typed fields used exclusively (no `slogger.Any`).
- [ ] Context fields propagated correctly.
- [ ] No retained `*Entry` pointers.

## Common Pitfalls

- Using `slogger.Any` for primitive types, defeating the zero-allocation design.
- Modifying logger configuration (e.g., `SetLevel`) concurrently without relying on the internal `atomic.Int32` safety.

## References

- `github.com/polarixa/replify/pkg/slogger` Architecture Documentation
