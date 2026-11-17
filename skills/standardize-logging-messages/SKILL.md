---
name: standardize-logging-messages
description: 'Audit and standardize logging messages in an existing codebase so they are professional, technically accurate, consistent, and useful for operations, without changing logging behavior, severity, structured fields, or control flow. Supports file, function, module, or whole-codebase scope. Trigger: "standardize logging messages", "clean up log messages", "audit log wording", "make log messages consistent", "fix unclear error logs", "review log severity and sensitive data in logs".'
metadata:
  category: observability
  tags: "logging, observability, log-messages, standardization, severity-levels, behavior-preserving"
---

# Standardize Logging Messages

## Purpose

Act as a Senior Software Engineer specializing in observability, logging architecture, and developer experience. Audit the logging messages of an existing codebase and rewrite them so each one states accurately what happened, which operation or resource was involved, and enough context to diagnose it, using consistent terminology, structure, capitalization, and punctuation.

The skill is **wording-focused and behavior-preserving**: it changes message text only. Logging calls, severity levels, conditions, structured fields, destinations, and control flow stay intact unless a change is separately justified and approved. Principle: every log message should communicate what actually happened and why it matters, without misleading the reader or changing application behavior.

## When to Use / When NOT to Use

**Use when:**

- Log messages are vague ("Something went wrong"), informal, inconsistent, or inaccurate.
- Similar events use different terminology, sentence structure, or punctuation.
- Messages claim success before it happens, or describe expected conditions as errors.
- A review is needed for log severity appropriateness or secrets/PII exposure in log output.

**Do NOT use when:**

- Designing or introducing structured logging, log levels policy, correlation IDs, or PII masking infrastructure (use `observability-logging`).
- Adding metrics or tracing (use `observability-metrics`, `observability-tracing`).
- Adding inline code comments (use `documentation-code-deep-dive`).
- Refactoring, fixing bugs, or changing logging configuration, handlers, or transports (use `code-quality-refactoring`).
- Reviewing a PR or diff in general (use `code-quality-code-review`).

## Prerequisites & Assumptions

- **Source is ground truth.** A message is rewritten only after reading the code at its emission point and understanding what actually happens there.
- **Reuse the project's logging stack.** MUST NOT introduce a new logging framework, wrapper, or abstraction.
- **Consumers may depend on text.** Tests, log parsers, alert rules, dashboards, and automation may match message strings; check for them before editing.
- **Version control** is preferred for the final diff check; if unavailable, state that limitation.

### Inputs

| Input          | Values                                    | Default    | Meaning                                                                                                                                                                   |
| -------------- | ----------------------------------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `scope`        | `file` \| `function` \| `module` \| `all` | `all`      | How much code to audit and update.                                                                                                                                        |
| `target`       | path, function name(s), module name(s)    | empty      | What to process; empty only when `scope=all`.                                                                                                                             |
| `language`     | any natural language                      | `English`  | Language of the log messages.                                                                                                                                             |
| `detail_level` | `concise` \| `detailed`                   | `detailed` | `concise`: audit table limited to messages that change or need review, short summaries. `detailed`: every audited message listed, with rationale and full quality review. |

### Scope & Context Resolution

- **Rule 1 - Explicit context in the prompt**: The user's stated scope, target, language, detail level, and constraints are authoritative. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT the safety rules (never expose secrets; never silently change severity, structured fields, or machine-readable formats), which stay mandatory; flag the conflict instead.
- **Rule 2 - No extra context**: With no explicit input, use the defaults above (`scope=all`, `English`, `detailed`) and this skill as the sole context.
- **Rule 3 - Explicit scope**:
  - `file` -> only logging messages in the named file.
  - `function` -> only those in the named function(s).
  - `module` -> across the named module.
  - `all` -> throughout the entire codebase.
  - MUST NOT silently expand scope. Out-of-scope code MAY be read for context but MUST NOT be modified; report inconsistent out-of-scope messages as notes.
- **Mutation boundary**: Only the text of log messages inside the resolved scope may change.

## Step-by-Step Workflow

1. **Resolve scope and context.** State `scope`, `target`, `language`, `detail_level`, and the mutation boundary in one line.
2. **Discover the logging stack.** Identify language, framework, logging libraries, wrappers, custom utilities, severity levels, structured-field conventions, prefixes, and error codes. Summarize them.
3. **Locate every logging statement** in scope (including wrappers and formatted/templated calls). Track files done and remaining.
4. **Read each emission point.** Determine the triggering event, the condition, the available variables/errors, and whether it is informational, success, warning, error, or diagnostic.
5. **Check consumers.** Search tests, parsers, alert/monitor configs, and scripts for string matches on existing messages; messages with consumers are not reworded without approval.
6. **Phase 1 - Audit (before editing).** Produce the audit table and classify each message (see Rules). Do not modify class D (Review) messages.
7. **Phase 2 - Standardize** wording per the standards below, adapting to existing project conventions.
8. **Phase 3 - Severity review.** Propose severity changes separately with justification; apply none without approval.
9. **Phase 4 - Safety review.** Check for secrets/PII, whole-payload dumps, duplicate logging of one error across layers, and loss of correlation context.
10. **Phase 5 - Consistency review.** Compare similar events across the scope; verify terminology, structure, capitalization, punctuation, language, and placeholders.
11. **Phase 6 - Integrity verification.** Run syntax checks, tests, and linters; inspect `git diff` to confirm only message text changed (plus any approved items).
12. **Report** using the output format; list unresolved messages.

For large codebases: process files incrementally, keep terminology consistent across modules, never silently skip logging statements, and continue until the whole scope is audited.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

### Audit Classification

Produce this table before editing:

| File | Function | Current Message | Issue | Proposed Message | Severity |
| ---- | -------- | --------------- | ----- | ---------------- | -------- |

(`Severity` = the existing log level, plus any proposed change flagged separately.)

Classify each message:

- **A. Keep** - already professional, accurate, and clear.
- **B. Improve** - wording or formatting only.
- **C. Correct** - technically inaccurate or misleading.
- **D. Review** - insufficient context; MUST NOT be modified until behavior is verified.

Issues to look for: unprofessional tone; unclear or context-free messages; technical inaccuracy (wrong success/failure claim, wrong operation); inconsistent terminology/structure/capitalization/punctuation; low-value or redundant messages; operational gaps (missing context, wrong level, missing error details, sensitive data).

### Message Standards

- **MUST** use professional, neutral, objective language; no slang, jokes, emotional wording, or needless exclamation marks.
- **MUST** describe only what the code actually does, and distinguish attempted, completed, skipped, and failed. Do not report success before it occurs, call an expected condition an error, or claim a resource was created/deleted/updated/processed unless the code confirms it.
- **MUST** answer, where known: what happened, which operation/resource, why, the outcome, and useful troubleshooting context. Replace generic messages ("Failed.", "Done.", "Invalid input.") with specific ones, but only when the implementation supports the specifics.
- **SHOULD** follow consistent structures, adapted to project conventions:
  - Informational: `[Operation or resource] [relevant status].`
  - Success: `[Operation] completed successfully.`
  - Warning: `[Operation or resource] [unexpected but recoverable condition].`
  - Error: `Failed to [operation]: [specific reason or context].`
  - Debug: `[Technical operation or state transition]: [diagnostic context].`
- **MUST** preserve dynamic values: existing interpolation, placeholders, format specifiers, and argument order. MUST NOT invent values or runtime context. Include contextual values only when they improve diagnostics; avoid dumping whole objects or payloads.
- **MUST** use the requested language consistently, keep product names, API names, commands, and identifiers unchanged, and use one term per concept across the codebase.

### Severity

- DEBUG: detailed diagnostics. INFO: normal events and milestones. WARN: abnormal but non-blocking conditions. ERROR: failed operations needing attention.
- **MUST** preserve existing severity unless there is a clearly verified misclassification.
- **MUST NOT** downgrade genuine errors, upgrade normal events, or change levels to make logs look cleaner.
- **MUST** treat any severity change as potentially behavior-affecting (it can alter alerting and filtering): list it separately with justification and obtain approval before applying.

### Safety and Observability

- **MUST NOT** expose passwords, tokens, API keys, private keys, session identifiers, secrets, sensitive personal data, or confidential payloads. If an existing message does, report it and propose a minimal safe correction.
- **MUST NOT** log whole request/response bodies unnecessarily.
- **MUST** preserve correlation/request IDs, resource identifiers, and other diagnostic metadata, plus structured fields and their data types. MUST NOT convert structured logs to plain strings.
- **MUST NOT** modify destinations, handlers, transports, or output streams.
- **SHOULD** report (not silently remove) duplicate logging of the same error at multiple layers unless each entry adds distinct value.

### Code Integrity (non-negotiable)

- **MUST** preserve logging function names and signatures, logging conditions, control flow, execution order, variable names, exception handling, return values, exit codes, and machine-readable formats.
- **MUST NOT** refactor unrelated code, add new logging statements without need, remove existing ones without justification, change business logic, add dependencies, or modify logging configuration.
- **MUST** keep the diff minimal. If a message cannot be improved without changing behavior, keep it and report the limitation.
- **MUST** report behavior-affecting proposals (severity, format, removed or added statements) separately from approved wording changes.

### Output Format

1. **Logging Convention Summary** - libraries, wrappers, levels, field/prefix/error-code conventions.
2. **Logging Audit (Before)** - the audit table.
3. **Standardization Results (After)** - `| File | Function | Original Message | Updated Message | Change Type |`.
4. **Updated Source Code / Unified Diff** - grouped by file, wording changes highlighted, severity changes (if any) clearly identified, nothing relevant omitted.
5. **Quality Review** - tone, accuracy, clarity, terminology, formatting, safety, structured-logging compatibility; use the summary table `| Category | Before | After | Status |` (Professional tone, Technical accuracy, Message clarity, Terminology, Formatting, Logging safety).
6. **Verification Results** - files inspected; statements audited; kept / improved / corrected / needing manual review counts; test and lint results; integrity check outcome.
7. **Remaining Issues** - file path, function, reason, recommended follow-up for each unresolved message.

## Examples (good vs. bad, with realistic code or output)

**Good: wording-only change, behavior intact (Go, `slog`)**

```go
// Before
slog.Error("Something went wrong!!", "err", err, "path", cfgPath)
// After
slog.Error("Failed to load the configuration file", "err", err, "path", cfgPath)
```

_Same level, same structured fields, same call; only the message text changed, and the new wording is supported by the surrounding `LoadConfig` code._

**Good: correcting a misleading success claim**

```python
# Before: logged before the commit actually happens
logger.info("Order saved!")
db.commit()
# After: wording corrected; position of the call is left untouched and reported
logger.info("Saving order to the database")   # attempted, not completed
db.commit()
```

_Finding (not modified): the message was emitted before `db.commit()`. Moving it after the commit changes execution order, so it is reported for approval instead._

**Good: reporting a safety issue with a minimal fix**

```java
// Before
log.debug("Login request: user={} password={}", user, password);
// After (minimal safe correction, proposed and reported)
log.debug("Login request received: user={}", user);
```

**Bad: behavior-changing "improvement"**

```js
// Before
logger.warn(`Retrying request ${id}`);
// After
logger.error(`Request ${id} failed after retries`); // level raised, claim invented, retry semantics unverified
```

_Why it's bad: silently changes severity, asserts an outcome the code does not confirm, and may break alert rules._

**Scope handling**

- **Prompt**: `scope=function`, `target=LoadConfig`.
- **Good**: Audits and rewrites messages inside `LoadConfig`, lists inconsistent messages in `ParseConfig` as notes, edits nothing else.
- **Bad**: Rewrites every log line in the `config` package and renames fields in structured logs.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope, target, language, and detail level resolved and stated.
- [ ] Logging libraries, wrappers, levels, and conventions identified and summarized.
- [ ] Every logging statement in scope located and read in context.
- [ ] Consumers (tests, parsers, alerts, automation) checked for message-text dependencies.
- [ ] Audit table produced before any edit; each message classified A/B/C/D; class D untouched.
- [ ] Messages state only verified behavior (attempted vs. completed vs. skipped vs. failed).
- [ ] Terminology, structure, capitalization, punctuation, and language consistent across scope.
- [ ] Placeholders, format specifiers, argument order, and structured fields/types unchanged.
- [ ] No secrets or sensitive data exposed; any found are reported with a minimal fix.
- [ ] Severity unchanged, or changes listed separately with justification and approval.
- [ ] No new logging framework, dependency, config, or statement changes beyond approved items.
- [ ] Syntax checks, tests, and linters run; `git diff` shows message-text-only changes.
- [ ] No out-of-scope file modified; out-of-scope inconsistencies reported as notes.
- [ ] All seven output sections provided; unresolved messages listed.

## Common Pitfalls

- **Breaking log consumers:** Rewording a message that an alert rule, parser, or test matches by string. Search for consumers first.
- **Inventing specifics:** Adding a failure reason or resource name the code does not supply. Use only what the implementation confirms.
- **Silent severity edits:** Changing a level "for cleanliness" alters alerting and filtering. Propose it separately.
- **Mangled placeholders:** Reordering or dropping `%s`, `{}`, `{0}`, or template variables, or turning structured key/value logs into formatted strings.
- **Claiming success early:** Fixing the text but not noticing the log precedes the operation; report the ordering issue rather than moving the call.
- **Over-verbose rewrites:** Dumping objects or payloads, or leaking tokens and PII while "adding context".
- **Cosmetic churn:** Rewording messages that are already accurate (class A) inflates the diff without value.
- **Scope creep:** Standardizing neighboring modules because they look inconsistent. Report them as notes.

## References (official docs, standards)

- Project logging documentation and style guides; the library's own docs (`log/slog`, SLF4J/Logback, Python `logging`, Winston/Pino, etc.).
- OWASP Logging Cheat Sheet (what not to log, log injection, sensitive data).
- RFC 5424 (Syslog severity levels) as a general severity reference.
- Sibling skills: `observability-logging` (logging design, PII masking), `documentation-code-deep-dive` (inline comments), `code-quality-refactoring`.
