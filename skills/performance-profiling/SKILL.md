---
name: performance-profiling
description: 'CPU, memory, and goroutine profiling using pprof/async-profiler. Trigger: "profile CPU usage", "find memory leaks", "flamegraph".'
metadata:
  category: performance
  tags: "performance, profiling, pprof, cpu, memory, goroutines"
---

# Performance: Profiling

## Purpose

Identifies bottlenecks and resource leaks in running applications. Responsibility boundary: captures and analyzes profiles and recommends or applies fixes to the profiled hot spot; does NOT write micro-benchmarks or optimize code that was not shown to be hot.

## When to Use / When NOT to Use

- **Use**: High CPU, OOM errors, latency spikes, GC pressure.
- **NOT**: Premature optimization before measuring.
- **NOT**: Micro-benchmarking and statistical comparison (use `performance-benchmarking`).
- **NOT**: Metrics/SLO dashboards (use `observability-metrics`).

## Prerequisites & Assumptions

- Profiler attached (`pprof`, `async-profiler`, `py-spy`).

### Scope & Context Resolution

- **Supported scopes**: service/process, package/module, single function/hot path, or a profile artifact (pprof file, flamegraph). Default: the process or profile the user names; if none, the single hot path under discussion.
- **Rule 1 - Explicit context**: user-stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: analysis-first; code edits only to the hot spot inside the resolved scope after the profile identifies it. MUST NOT enable profiling on production without approval.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Enable profiling endpoint/agent safely for the resolved target.
3. Capture profile under realistic load.
4. Analyze flamegraphs and call trees.
5. Optimize hot spots inside the scope and re-measure.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Profile under realistic production load.
- **MUST**: Use flamegraphs for visualization.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Profile memory allocations (alloc_space vs inuse).
- **MUST NOT**: Profile in prod without sampling or rate-limiting.
- **MUST NOT**: Optimize code that the profile does not show as hot, or hot spots outside the named scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Guessing the bottleneck.
- **Good**: `pprof` shows 80% time in JSON marshal; switch to faster lib.
- **Good (scope)**: Prompt "only the `/search` handler is slow" -> profile that path, fix its hot spot; list other hot frames as notes.
- **Bad (scope)**: Same prompt -> rewriting unrelated handlers because they look inefficient.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Load applied.
- [ ] Flamegraph analyzed.
- [ ] Hotspot fixed and verified.

## Common Pitfalls

- Observer effect (profiler slows down app).
- Misinterpreting cumulative vs flat time.
- Scope creep: optimizing the whole service when one endpoint was named.

## References (official docs, standards)

- [pprof Documentation](https://github.com/google/pprof)
- [Profiling Go Programs](https://go.dev/blog/pprof)
- [async-profiler](https://github.com/async-profiler/async-profiler)
