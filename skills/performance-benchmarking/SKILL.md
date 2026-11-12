---
name: performance-benchmarking
description: 'Micro-benchmarking rules, statistical significance, preventing compiler optimizations. Trigger: "write micro-benchmark", "prevent compiler optimization", "benchstat".'
metadata:
  category: performance
  tags: "performance, benchmarking, micro-benchmark, statistics, compiler-optimization"
---

# Performance: Benchmarking

## Purpose

Measures code execution time and throughput accurately. It writes and reviews micro-benchmarks and interprets their statistics; it does NOT profile whole applications or change the production code under test.

## When to Use / When NOT to Use

- **Use**: Comparing algorithms, optimizing hot paths, library authors.
- **NOT**: Measuring full app latency (use APM/tracing).
- **NOT**: Finding hotspots or memory leaks (use `performance-profiling`).
- **NOT**: Measuring test coverage (use `testing-test-coverage`).

## Prerequisites & Assumptions

- Benchmark framework (`testing.B`, JMH, `pytest-benchmark`).

### Scope & Context Resolution

- **Supported scopes**: function/method, benchmark file, package/module, project/repository. Default when none is given: the function or code snippet in the prompt.
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, constraints, versions, targets (language, framework, hardware), and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow, and rules as the sole context at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits are limited to benchmark files. MUST NOT modify the code under test.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Isolate code under test.
3. Prevent compiler optimizations (use result).
4. Run sufficient iterations (warm up).
5. Analyze variance with statistical tools.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Prevent dead-code elimination (assign to global sink).
- **MUST**: Warm up the JVM/Runtime before measuring.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use statistical tools (`benchstat`, JMH profilers).
- **MUST NOT**: Benchmark with background noise (close other apps).
- **MUST NOT**: Optimize or alter the code under test while only asked to benchmark it.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `func Benchmark(b) { _ = fastFunc() }` (Optimized away)
- **Good**: `func Benchmark(b) { for i:=0; i<b.N; i++ { sink = fastFunc() } }`

**Scope handling**

- **Prompt**: "Benchmark only `ParseHeader`."
- **Good**: Adds `BenchmarkParseHeader` with a global sink and reports `benchstat` output for that function.
- **Bad**: Benchmarks the whole package and rewrites `ParseHeader` for speed.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Optimizations prevented.
- [ ] Warmed up.
- [ ] Stats analyzed (p-value).

## Common Pitfalls

- Measuring the wrong thing (cache effects).
- Ignoring variance and standard deviation.
- Scope creep: benchmarking and rewriting neighbouring functions when asked about one.

## References (official docs, standards)

- [Go Benchmarking](https://dave.cheney.net/2013/06/30/how-to-write-benchmarks-in-go)
