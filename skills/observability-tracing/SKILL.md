---
name: observability-tracing
description: 'Distributed tracing with OpenTelemetry, span context propagation. Trigger: "setup OpenTelemetry", "trace HTTP requests", "distributed tracing".'
metadata:
  category: observability
  tags: "observability, tracing, opentelemetry, distributed-tracing, context-propagation"
---

# Observability: Tracing

## Purpose

Visualizes request flows across distributed microservices. Responsibility boundary: adds and fixes tracing instrumentation, propagation and exporter config in the named scope; does NOT change business logic, logging or metrics.

## When to Use / When NOT to Use

- **Use**: Debugging latency, cross-service errors, dependency mapping.
- **NOT**: Single-process scripts or monoliths without boundaries.
- **NOT**: Structured logging or PII masking (use `observability-logging`).
- **NOT**: Metrics, SLOs or dashboards (use `observability-metrics`).

## Prerequisites & Assumptions

- OpenTelemetry SDK configured.

### Scope & Context Resolution

- **Supported scopes**: project/repository, service, package/module, handler or endpoint, function/method, exporter/collector config. Default when none is given: the entry points (HTTP/gRPC handlers) and outbound calls of the named service; if none is named, the project.
- **Rule 1 - Explicit context in the prompt**: the user's stated requirements, constraints, versions, targets (backend, sampling rate) and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules (no PII in spans), which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to tracing instrumentation, context propagation and exporter/sampler config inside the resolved scope.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Instrument entry points (HTTP/gRPC handlers) within the resolved scope.
3. Propagate context via W3C Trace Context headers.
4. Create spans for DB/HTTP/external calls.
5. Export to Jaeger, Tempo, or Datadog.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Propagate W3C Trace Context headers.
- **MUST**: Add span attributes (key-value), not logs.
- **SHOULD**: Sample traces in prod (e.g., 10% or error-only).
- **MUST NOT**: Put PII in span names or attributes.
- **MUST NOT**: Instrument services or packages outside the named scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `SpanName = 'GET /user/123'`
- **Good**: `SpanName = 'HTTP GET', Attrs = {'user_id': '123'}`

**Scope handling**

- **Prompt**: "Trace only the `checkout` service's HTTP handler and its DB calls."
- **Good**: Instruments that handler and its DB spans; notes that `inventory` calls lack propagation.
- **Bad**: Adds OpenTelemetry to every service and swaps the logging library.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Context propagated.
- [ ] Spans created for external calls.
- [ ] Exported to backend.

## Common Pitfalls

- Missing context propagation breaking the trace.
- High overhead from 100% sampling.
- Instrumenting every service when one was requested.

## References (official docs, standards)

- [OpenTelemetry](https://opentelemetry.io/docs/)
- [W3C Trace Context](https://www.w3.org/TR/trace-context/)
