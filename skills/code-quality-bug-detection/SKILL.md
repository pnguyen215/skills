---
name: code-quality-bug-detection
description: 'Detect, verify, and report correctness bugs in a library or project without modifying code. Trigger: "find bugs in this library", "audit this project for bugs", "detect defects", "hunt for edge-case bugs".'
metadata:
  category: code-quality
  tags: "bug-detection, defects, audit, correctness, edge-cases, race-conditions"
---

# Bug Detection

## Purpose

Finds and verifies correctness defects in existing code and reports them with evidence, severity, and a suggested fix. This skill is READ-ONLY: it does NOT modify source code, fix bugs, refactor, or change public contracts. It MAY add a reproduction test only when the user explicitly asks.

## When to Use / When NOT to Use

- **Use**: Auditing a library or project for latent defects, validating a release candidate, investigating suspicious modules, due-diligence on third-party code.
- **NOT**: Reviewing a PR diff against a checklist (use `code-quality-code-review`).
- **NOT**: Tracing how a feature works without hunting defects (use `code-quality-codebase-analyst`).
- **NOT**: Logic-flow diagrams as the main deliverable (use `code-quality-logic-review-diagram`).
- **NOT**: Security-only audits (use `golang-audit-security` or `security-secure-coding`).
- **NOT**: Fixing the bugs (use `code-quality-refactoring` for structure, or a normal implementation task for fixes).
- **NOT**: Linter/SAST configuration (use `code-quality-static-analysis`).

## Prerequisites & Assumptions

- Source code is readable. Tests, linters, and a build are run when available to gather evidence.

### Scope & Context Resolution

- **Supported scopes**: repository, directory/module/package, file, class/type, function/method. Default: the whole repository for a "library/project" request; the named symbol or file otherwise.
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, language versions, expected behavior, focus areas, and scope are authoritative. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow, and rules as the sole context, at the default scope. MUST NOT import unrelated requirements.
- **Rule 3 - Explicit scope**: Report bugs ONLY inside the named scope. Out-of-scope code may be READ as evidence; defects found there are listed as notes.
- **Mutation boundary**: None for source code. Any scratch reproduction goes to a temporary location, never into the project, unless the user asks.

## Step-by-Step Workflow

1. **Resolve scope and context**: State the resolved scope, the language/runtime, and the read-only boundary in one line.
2. **Establish intent**: Read docs, README, public API, comments, and tests to learn what the code is SUPPOSED to do. A bug is a deviation from intended behavior.
3. **Gather signals**: Run build, tests, race detector, and available linters/type checkers; record failures and warnings.
4. **Hunt by category** (see below) across the scope, prioritizing public entry points, parsing, concurrency, resource handling, and boundary conditions.
5. **Verify each candidate**: Trace the real execution path, find a triggering input or state, and confirm no guard elsewhere prevents it. Where safe, confirm with a minimal reproduction.
6. **Classify and rank**: Assign severity and confidence; discard unverified speculation or label it clearly.
7. **Report**: Findings with location, evidence, trigger, impact, and suggested fix. No code changes.

## Bug Categories to Hunt

- **Boundary and arithmetic**: off-by-one, integer overflow/underflow, truncation, division by zero, rounding, empty/min/max inputs.
- **Null/nil/undefined handling**: unchecked nil dereference, optional misuse, zero-value traps.
- **Error handling**: ignored or swallowed errors, wrong error wrapping, lost context, success returned on failure, panics on bad input.
- **Concurrency**: data races, deadlocks, missed synchronization, goroutine/thread leaks, check-then-act races, unsafe shared state.
- **Resource management**: leaked files, connections, timers, locks; missing close/defer/finally; unbounded growth.
- **State and lifecycle**: use-after-close, double close, init-order issues, stale caches, mutation of shared or input data.
- **Logic**: inverted conditions, wrong operators, short-circuit mistakes, unreachable branches, incorrect default values, copy-paste errors.
- **Data and parsing**: encoding, time zones, locale, float equality, unvalidated input, injection of malformed data, unbounded reads.
- **API contract**: behavior contradicting docs, inconsistent return values, broken invariants, backward-compat breaks.
- **Platform and environment**: path separators, line endings, endianness, OS-specific behavior (defer to cross-platform skills for deep audits).

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Remain read-only with respect to project source.
- **MUST**: Verify every reported bug by tracing the execution path to a concrete trigger. Cite file and line.
- **MUST**: Report severity and confidence separately; label unverified items as "suspected".
- **MUST**: Compare against intended behavior (docs, tests, contracts), not personal style preference.
- **MUST**: Stay within the resolved scope and report out-of-scope findings as notes.
- **SHOULD**: Provide a minimal reproduction (input, test, or command) for each High/Critical finding.
- **SHOULD**: Suggest a minimal fix without applying it.
- **MUST NOT**: Report style issues, naming, or refactoring ideas as bugs.
- **MUST NOT**: Fabricate findings, line numbers, tool output, or reproduction results.
- **MUST NOT**: Modify code, delete tests, or run destructive commands (deleting data, hitting production services) to gain evidence.

## Severity Model

- **Critical**: Data loss/corruption, crash or hang in a common path, security-impacting defect.
- **High**: Wrong results or failure in a realistic scenario, resource leak that degrades service.
- **Medium**: Wrong behavior in edge cases or uncommon configurations.
- **Low**: Minor inconsistency with limited impact or an easy workaround.

## Examples (good vs. bad, with realistic code or output)

- **Good finding**: `parse.go:88` - `strings.Split(line, ":")[1]` panics when the line has no colon. Trigger: input `"key"`. Impact: panic on malformed config. Severity: High. Confidence: Confirmed (repro: `Parse("key")`). Suggested fix: check `len(parts) == 2`.
- **Bad finding**: "Function is too long and should be split." (a refactoring opinion, not a bug).
- **Bad finding**: "Possible race condition somewhere in the cache." (no location, trigger, or evidence).
- **Good (scoped)**: Prompt "audit only `pkg/cache`" -> report defects in that package; note a suspected leak in `pkg/worker` as out of scope.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope, language, and read-only boundary stated.
- [ ] Intended behavior established from docs/tests/contracts.
- [ ] Build, tests, and available analyzers run; results recorded.
- [ ] Each finding has location, trigger, impact, severity, and confidence.
- [ ] Each finding verified by tracing the execution path.
- [ ] No source files modified.
- [ ] Out-of-scope observations reported separately.
- [ ] Coverage gaps and unreviewed areas disclosed.

## Common Pitfalls

- Reporting speculation as fact without verifying a guard does not exist upstream.
- Mistaking intentional behavior for a bug without reading docs and tests.
- Flooding the report with low-value style nits.
- Fixing bugs while auditing (changes scope and destroys evidence).
- Claiming the project is "bug-free" - state only what was reviewed and how.

## References (official docs, standards)

- [CWE Top 25](https://cwe.mitre.org/top25/)
- [Go Race Detector](https://go.dev/doc/articles/race_detector)
- [Testing Fuzzing (Go)](https://go.dev/doc/security/fuzz/)
