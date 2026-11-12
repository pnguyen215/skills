---
name: observability-logging
description: 'Structured logging, log levels, correlation IDs, PII masking. Trigger: "setup structured logging", "mask PII in logs", "JSON logs".'
metadata:
  category: observability
  tags: "observability, logging, structured-logging, correlation-id, pii"
---

# Observability: Logging

## Purpose

Provides searchable, secure, and actionable log data. This skill covers log format, levels, correlation IDs and masking only; it does NOT define metrics, traces or business logic changes.

## When to Use / When NOT to Use

- **Use**: Debugging prod issues, auditing, compliance.
- **NOT**: Local dev `print()` statements.
- **NOT**: Metrics and SLOs (use `observability-metrics`) or distributed tracing setup (use `observability-tracing`).
- **NOT**: Logging through the replify slogger package (use `replify-slogger`).

## Prerequisites & Assumptions

- JSON log shipper (Fluentd, Vector, Promtail).

### Scope & Context Resolution

- **Supported scopes**: service/repository (default), directory/module/package, file, function/method, logger configuration.
- **Rule 1 - Explicit context in the prompt**: Stated logging library, fields, levels, versions and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules (e.g., PII and secret logging), which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at service scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to logger configuration, log statements and masking helpers inside the resolved scope. MUST NOT change control flow or business logic.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Configure JSON formatter.
3. Inject correlation IDs from headers/context.
4. Mask PII/secrets before logging.
5. Set appropriate log levels (INFO, WARN, ERROR).

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Output JSON format for machine parsing.
- **MUST**: Include `trace_id` and `span_id` in every log.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Mask PII (emails, IPs) automatically.
- **MUST NOT**: Log passwords, tokens, or full credit cards.
- **MUST NOT**: Rewrite log statements in modules outside the resolved scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `print('User password:', pwd)`
- **Good**: `logger.info('login_success', extra={'user_id': 123, 'trace_id': 'abc'})`
- **Good (scoped)**: Prompt "only `auth/login.py`" -> replace prints with structured calls in that file; note unmasked logs in `billing/`.
- **Bad (scope-expanding)**: Same prompt -> swap the logging library project-wide and edit every module.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] JSON format.
- [ ] Trace IDs propagated.
- [ ] PII masked.

## Common Pitfalls

- Log spam causing disk fill.
- Leaking secrets in error stack traces.
- Migrating the whole codebase's logging when asked about one module.

## References (official docs, standards)

- [12-Factor App: Logs](https://12factor.net/logs)
