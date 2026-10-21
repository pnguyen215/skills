---
name: observability-metrics
description: 'RED/USE metrics, Prometheus exposition, SLO/SLI tracking. Trigger: "define SLOs", "setup Prometheus metrics", "dashboard design".'
metadata:
  category: observability
  tags: "observability, metrics, prometheus, slo, sli"
---

# Observability: Metrics

## Purpose

Quantifies system health and business value.

## When to Use / When NOT to Use

- **Use**: Alerting, dashboards, SLO tracking, capacity planning.
- **NOT**: Detailed event tracing (use logs).

## Prerequisites & Assumptions

- Prometheus/OTLP endpoint available.

## Step-by-Step Workflow

1. Define SLIs (e.g., success rate, latency p99).
2. Set SLOs (e.g., 99.9% success over 30 days).
3. Implement RED (Rate, Errors, Duration) for services.
4. Expose `/metrics` endpoint.

## Enterprise Rules & Standards

- **MUST**: Use standard labels (e.g., `method`, `status`).
- **MUST**: Avoid high cardinality labels (e.g., `user_id`).
- **SHOULD**: Use Histograms for duration, Counters for totals.
- **MUST NOT**: Use metrics for discrete, one-off events.

## Examples

- **Bad**: `metric_user_login{email='a@b.com'}` (Cardinality explosion)
- **Good**: `http_requests_total{method='POST', status='200'}`

## Checklist

- [ ] RED metrics implemented.
- [ ] SLOs defined.
- [ ] Low cardinality verified.

## Common Pitfalls

- Cardinality explosion crashing Prometheus.
- Missing labels making metrics useless.

## References

- [Google SRE Book: Monitoring](https://sre.google/sre-book/monitoring-distributed-systems/)
