---
name: logging
description: 'Structured logging, log levels, correlation IDs, PII masking. Trigger: "setup structured logging", "mask PII in logs", "JSON logs".'
---

# Observability: Logging

## Purpose

Provides searchable, secure, and actionable log data.

## When to Use / When NOT to Use

- **Use**: Debugging prod issues, auditing, compliance.
- **NOT**: Local dev `print()` statements.

## Prerequisites & Assumptions

- JSON log shipper (Fluentd, Vector, Promtail).

## Step-by-Step Workflow

1. Configure JSON formatter.
2. Inject correlation IDs from headers/context.
3. Mask PII/secrets before logging.
4. Set appropriate log levels (INFO, WARN, ERROR).

## Enterprise Rules & Standards

- **MUST**: Output JSON format for machine parsing.
- **MUST**: Include `trace_id` and `span_id` in every log.
- **SHOULD**: Mask PII (emails, IPs) automatically.
- **MUST NOT**: Log passwords, tokens, or full credit cards.

## Examples

- **Bad**: `print('User password:', pwd)`
- **Good**: `logger.info('login_success', extra={'user_id': 123, 'trace_id': 'abc'})`

## Checklist

- [ ] JSON format.
- [ ] Trace IDs propagated.
- [ ] PII masked.

## Common Pitfalls

- Log spam causing disk fill.
- Leaking secrets in error stack traces.

## References

- [12-Factor App: Logs](https://12factor.net/logs)
