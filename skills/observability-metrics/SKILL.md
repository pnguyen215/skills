---
name: observability-metrics
description: 'RED/USE metrics, Prometheus exposition, SLO/SLI tracking. Trigger: "define SLOs", "setup Prometheus metrics", "dashboard design".'
metadata:
  category: observability
  tags: "observability, metrics, prometheus, slo, sli"
---

# Observability: Metrics

## Purpose

Quantifies system health and business value. Responsibility boundary: defines and instruments metrics, SLIs/SLOs and dashboards; does NOT add logging or tracing, and does NOT change business logic.

## When to Use / When NOT to Use

- **Use**: Alerting, dashboards, SLO tracking, capacity planning.
- **NOT**: Detailed event tracing (use logs).
- **NOT**: Structured logging setup (use `observability-logging`).
- **NOT**: Distributed tracing and span propagation (use `observability-tracing`).

## Prerequisites & Assumptions

- Prometheus/OTLP endpoint available.

### Scope & Context Resolution

- **Supported scopes**: repository/service (default), package/module, single endpoint or handler, single metric, SLO definition, dashboard.
- **Rule 1 - Explicit context**: The user's stated requirements, constraints, versions, targets and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line. Security/data-loss rules stay mandatory; flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at service scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to metric definitions, instrumentation calls, SLO/alert rules and dashboards in scope.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Define SLIs (e.g., success rate, latency p99).
3. Set SLOs (e.g., 99.9% success over 30 days).
4. Implement RED (Rate, Errors, Duration) for services in scope.
5. Expose `/metrics` endpoint.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Use standard labels (e.g., `method`, `status`).
- **MUST**: Avoid high cardinality labels (e.g., `user_id`).
- **SHOULD**: Use Histograms for duration, Counters for totals.
- **MUST NOT**: Use metrics for discrete, one-off events.
- **MUST NOT**: Instrument or rename metrics of services outside the requested scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `metric_user_login{email='a@b.com'}` (Cardinality explosion)
- **Good**: `http_requests_total{method='POST', status='200'}`
- **Scope - Good**: Prompt "only the `/checkout` handler" -> add request counter and duration histogram to that handler; note that `/cart` has no metrics.
- **Scope - Bad**: Same prompt -> instrumenting every handler and redefining the service's SLOs.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] RED metrics implemented.
- [ ] SLOs defined.
- [ ] Low cardinality verified.

## Common Pitfalls

- Cardinality explosion crashing Prometheus.
- Missing labels making metrics useless.
- Rewriting all dashboards when one panel was requested.

## References (official docs, standards)

- [Google SRE Book: Monitoring](https://sre.google/sre-book/monitoring-distributed-systems/)
- [Prometheus: Metric and label naming](https://prometheus.io/docs/practices/naming/)
- [Prometheus: Instrumentation](https://prometheus.io/docs/practices/instrumentation/)
