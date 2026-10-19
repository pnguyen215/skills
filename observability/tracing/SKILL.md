---
name: tracing
description: 'Distributed tracing with OpenTelemetry, span context propagation. Trigger: "setup OpenTelemetry", "trace HTTP requests", "distributed tracing".'
---

# Observability: Tracing

## Purpose

Visualizes request flows across distributed microservices.

## When to Use / When NOT to Use

- **Use**: Debugging latency, cross-service errors, dependency mapping.
- **NOT**: Single-process scripts or monoliths without boundaries.

## Prerequisites & Assumptions

- OpenTelemetry SDK configured.

## Step-by-Step Workflow

1. Instrument entry points (HTTP/gRPC handlers).
2. Propagate context via W3C Trace Context headers.
3. Create spans for DB/HTTP/external calls.
4. Export to Jaeger, Tempo, or Datadog.

## Enterprise Rules & Standards

- **MUST**: Propagate W3C Trace Context headers.
- **MUST**: Add span attributes (key-value), not logs.
- **SHOULD**: Sample traces in prod (e.g., 10% or error-only).
- **MUST NOT**: Put PII in span names or attributes.

## Examples

- **Bad**: `SpanName = 'GET /user/123'`
- **Good**: `SpanName = 'HTTP GET', Attrs = {'user_id': '123'}`

## Checklist

- [ ] Context propagated.
- [ ] Spans created for external calls.
- [ ] Exported to backend.

## Common Pitfalls

- Missing context propagation breaking the trace.
- High overhead from 100% sampling.

## References

- [OpenTelemetry](https://opentelemetry.io/docs/)
