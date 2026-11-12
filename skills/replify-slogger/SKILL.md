---
name: replify-slogger
description: 'Guides the implementation of high-performance, zero-allocation structured logging using the replify/pkg/slogger package. Trigger: "setup slogger", "structured logging replify", "zero-alloc logger".'
metadata:
  category: ecosystem-replify
  tags: "replify, golang, logging, slog, zero-allocation"
---

# replify/slogger: Zero-Allocation Structured Logging

## Purpose

Standardizes production logging using `slogger` to ensure thread-safety, zero-allocation on hot paths, and proper context propagation, replacing standard `log/slog` or `logrus`. It edits logging call sites and logger setup only; it does NOT change business logic, log-aggregation infrastructure, or PII policy.

## When to Use / When NOT to Use

- **Use**: All production services, high-throughput systems, CLI tools requiring structured output.
- **NOT**: Simple throwaway scripts where `fmt.Println` is sufficient.
- **NOT**: Generic logging policy such as levels, correlation IDs, and PII masking (use `observability-logging`).
- **NOT**: String building or manipulation (use `replify-strchain` or `replify-strutil`).

## Prerequisites & Assumptions

- Go 1.21+ environment.
- `github.com/polarixa/replify/pkg/slogger` imported.

### Scope & Context Resolution

- **Supported scopes**: project/repository, package, file, function/method, logger initialization. Default when none is given: the files or snippet presented in the prompt.
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, constraints, versions, targets, and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow, and rules as the sole context at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits are limited to logger construction and log calls inside the named scope. Other packages' logging is reported as notes only.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Initialize `Logger` with `JSONFormatter` (production) or `TextFormatter` (development).
3. Bind static context fields using `logger.With(slogger.String("service", "api"))`.
4. Use typed field constructors (`slogger.String`, `slogger.Int`, `slogger.Err`) for log entries within the scope.
5. Propagate trace IDs via `slogger.WithContextFields(ctx, ...)`.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Use typed field constructors (`slogger.Int`, `slogger.Err`) rather than `slogger.Any` to prevent reflection overhead and heap allocations.
- **MUST**: Configure `JSONFormatter` for all production environments to ensure log aggregator compatibility.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST NOT**: Retain `*Entry` objects after the logging call returns; they are recycled via `sync.Pool` and will be overwritten.
- **MUST NOT**: Perform blocking I/O or network calls inside a `Hook` without dispatching to a separate goroutine.
- **MUST NOT**: Migrate logging in packages outside the named scope or alter log messages' business meaning.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `logger.Info(fmt.Sprintf("user %s failed login: %v", u.ID, err))` (Causes allocations)
- **Good**: `logger.Info("login failed", slogger.String("user_id", u.ID), slogger.Err(err))`

**Scope handling**

- **Prompt**: "Migrate logging in `internal/auth` only."
- **Good**: Converts `log/slog` calls in `internal/auth` to typed `slogger` fields; notes that `internal/billing` still uses `logrus`.
- **Bad**: Replaces the logger across every package and changes the shared logger initialization.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] JSON formatter configured for prod.
- [ ] Typed fields used exclusively (no `slogger.Any`).
- [ ] Context fields propagated correctly.
- [ ] No retained `*Entry` pointers.

## Common Pitfalls

- Using `slogger.Any` for primitive types, defeating the zero-allocation design.
- Modifying logger configuration (e.g., `SetLevel`) concurrently without relying on the internal `atomic.Int32` safety.
- Scope creep: migrating the whole service's logging when asked about one package.

## References (official docs, standards)

- `github.com/polarixa/replify/pkg/slogger` Architecture Documentation
