---
name: performance-benchmarking
description: 'Micro-benchmarking rules, statistical significance, preventing compiler optimizations. Trigger: "write micro-benchmark", "prevent compiler optimization", "benchstat".'
metadata:
  category: performance
---

# Performance: Benchmarking

## Purpose

Measures code execution time and throughput accurately.

## When to Use / When NOT to Use

- **Use**: Comparing algorithms, optimizing hot paths, library authors.
- **NOT**: Measuring full app latency (use APM/tracing).

## Prerequisites & Assumptions

- Benchmark framework (`testing.B`, JMH, `pytest-benchmark`).

## Step-by-Step Workflow

1. Isolate code under test.
2. Prevent compiler optimizations (use result).
3. Run sufficient iterations (warm up).
4. Analyze variance with statistical tools.

## Enterprise Rules & Standards

- **MUST**: Prevent dead-code elimination (assign to global sink).
- **MUST**: Warm up the JVM/Runtime before measuring.
- **SHOULD**: Use statistical tools (`benchstat`, JMH profilers).
- **MUST NOT**: Benchmark with background noise (close other apps).

## Examples

- **Bad**: `func Benchmark(b) { _ = fastFunc() }` (Optimized away)
- **Good**: `func Benchmark(b) { for i:=0; i<b.N; i++ { sink = fastFunc() } }`

## Checklist

- [ ] Optimizations prevented.
- [ ] Warmed up.
- [ ] Stats analyzed (p-value).

## Common Pitfalls

- Measuring the wrong thing (cache effects).
- Ignoring variance and standard deviation.

## References

- [Go Benchmarking](https://dave.cheney.net/2013/06/30/how-to-write-benchmarks-in-go)
