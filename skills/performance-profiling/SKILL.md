---
name: performance-profiling
description: 'CPU, memory, and goroutine profiling using pprof/async-profiler. Trigger: "profile CPU usage", "find memory leaks", "flamegraph".'
metadata:
  category: performance
  tags: "performance, profiling, pprof, cpu, memory, goroutines"
---

# Performance: Profiling

## Purpose

Identifies bottlenecks and resource leaks in running applications.

## When to Use / When NOT to Use

- **Use**: High CPU, OOM errors, latency spikes, GC pressure.
- **NOT**: Premature optimization before measuring.

## Prerequisites & Assumptions

- Profiler attached (`pprof`, `async-profiler`, `py-spy`).

## Step-by-Step Workflow

1. Enable profiling endpoint/agent safely.
2. Capture profile under realistic load.
3. Analyze flamegraphs and call trees.
4. Optimize hot spots and re-measure.

## Enterprise Rules & Standards

- **MUST**: Profile under realistic production load.
- **MUST**: Use flamegraphs for visualization.
- **SHOULD**: Profile memory allocations (alloc_space vs inuse).
- **MUST NOT**: Profile in prod without sampling or rate-limiting.

## Examples

- **Bad**: Guessing the bottleneck.
- **Good**: `pprof` shows 80% time in JSON marshal; switch to faster lib.

## Checklist

- [ ] Load applied.
- [ ] Flamegraph analyzed.
- [ ] Hotspot fixed and verified.

## Common Pitfalls

- Observer effect (profiler slows down app).
- Misinterpreting cumulative vs flat time.

## References

- [pprof Documentation](https://github.com/google/pprof)
