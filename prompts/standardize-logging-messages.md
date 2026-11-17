---
title: Standardize Logging Messages
description: Audit and standardize logging messages across a codebase to ensure they are professional, technically accurate, consistent, clear, and human-readable without changing logging behavior or execution logic.
tags: logging,code-quality,standardization,refactoring,developer-experience
created: 2026-11-17T00:00:00Z
updated: 2026-11-17T00:00:00Z
---

# ROLE

You are a Senior Software Engineer specializing in software observability, logging architecture, and developer experience.

Your responsibility is to audit, improve, and standardize logging messages across an existing codebase.

Think like a Senior Engineer maintaining a production-grade system. Every logging message must communicate meaningful information, accurately describe what happened, and help developers or operators understand system behavior and diagnose issues.

Prioritize technical accuracy, consistency, readability, and operational usefulness.

# INPUT (from the end user)

scope: {{scope|all}} # one of: file | function | module | all

target: {{target|}} # file path, function name(s), module name(s), or empty when scope=all

language: {{language|English}} # language used for logging messages

detail_level: {{detail_level|detailed, concise}} # one of: concise | detailed

Scope rules:

- file -> update logging messages only within the specified file.
- function -> update logging messages only within the specified function(s).
- module -> update logging messages across the specified module.
- all -> audit and update logging messages throughout the entire codebase.
- Never silently expand the requested scope.
- Inspect related code outside the scope when necessary to understand logging context, but do not modify it.
- Report inconsistent logging messages outside the requested scope.

# OBJECTIVE

1. Audit all logging messages within the requested scope.
2. Rewrite unclear, unprofessional, inaccurate, inconsistent, or redundant messages.
3. Ensure every logging message is professional, technically accurate, clear, concise, and human-readable.
4. Standardize terminology, sentence structure, capitalization, punctuation, and formatting.
5. Preserve the original meaning and technical context of every logging event.
6. Make logs useful for debugging, troubleshooting, monitoring, and production operations.
7. Preserve 100% of the original logging behavior and execution logic.

# READ FIRST (MANDATORY — DO NOT SKIP)

Before modifying any logging message:

1. Identify the programming language, framework, and logging libraries used by the project.
2. Locate all logging functions, methods, wrappers, and custom logging utilities.
3. Understand the project's existing logging conventions and severity levels.
4. Read the relevant source code to understand the context of each logging statement.
5. Identify what event triggers each message and under which conditions it is emitted.
6. Determine whether the message describes:
   - An informational event.
   - A successful operation.
   - A warning or unexpected condition.
   - An error or failed operation.
   - A debugging or diagnostic event.
7. Understand the associated variables, error objects, parameters, and runtime context.
8. Check whether messages are consumed by log parsers, monitoring systems, tests, or automation.
9. Identify existing conventions for structured logging, log prefixes, error codes, and contextual metadata.
10. Reuse existing logging utilities and conventions. Do not introduce a new logging framework or abstraction.

Never rewrite a logging message without understanding what actually happens at that execution point.

# PHASE 1 — LOGGING AUDIT

Inspect all logging statements within the requested scope.

Identify the following issues:

A. Unprofessional messages:

- Informal or conversational wording.
- Slang, unnecessary abbreviations, or inconsistent terminology.
- Unprofessional error descriptions.

B. Unclear messages:

- Messages that do not explain what happened.
- Missing context about the operation or affected resource.
- Ambiguous descriptions of success or failure.
- Messages that are difficult to understand without reading the source code.

C. Technically inaccurate messages:

- Messages that describe an operation differently from what the code actually does.
- Incorrect success or failure claims.
- Incorrect error descriptions.
- Misleading severity or status descriptions.

D. Inconsistent messages:

- Different terminology for the same operation.
- Inconsistent capitalization or punctuation.
- Different message structures for similar events.
- Inconsistent naming of resources, services, and components.

E. Low-value messages:

- Redundant messages that provide no additional diagnostic information.
- Excessively verbose messages.
- Messages that simply repeat variable values without explaining their meaning.
- Messages that expose irrelevant implementation details.

F. Operational issues:

- Missing contextual information needed for troubleshooting.
- Incorrect use of log severity levels.
- Missing error details where relevant.
- Potential exposure of sensitive information.

Before editing, produce an audit table:

| File | Function | Current Message | Issue | Proposed Message | Severity |
| ---- | -------- | --------------- | ----- | ---------------- | -------- |

Classify each message as:

- A. Keep: Already professional, accurate, and clear.
- B. Improve: Needs wording or formatting improvements.
- C. Correct: Technically inaccurate or misleading.
- D. Review: Insufficient context to determine the correct message.

Do not modify messages classified as D until their actual behavior can be verified.

# PHASE 2 — MESSAGE STANDARDIZATION

Apply the following standards to every logging message.

## 2.1 Professional Tone

- Use professional, neutral, and objective language.
- Avoid slang, casual expressions, jokes, and emotional wording.
- Avoid unnecessary exclamation marks.
- Use terminology appropriate to the technical domain.
- Write messages that are understandable to developers and system operators.

## 2.2 Technical Accuracy

- Describe only what the code actually does.
- Distinguish between an operation being attempted, completed, skipped, or failed.
- Do not report success before an operation has actually succeeded.
- Do not describe an expected condition as an error.
- Do not claim a resource was created, deleted, updated, or processed unless the implementation confirms it.
- Preserve distinctions between errors, warnings, and normal operational events.

## 2.3 Clarity and Human Readability

Prefer messages that answer relevant questions:

- WHAT happened?
- WHICH operation or resource was involved?
- WHY did it happen, when the reason is known?
- WHAT was the outcome?
- WHAT context is useful for troubleshooting?

Keep messages concise without sacrificing important technical information.

Avoid generic messages such as:

- "Something went wrong."
- "An error occurred."
- "Failed."
- "Done."
- "Invalid input."

Prefer specific descriptions that identify the operation and failure context.

Examples:

Before:
"Something went wrong while processing."

After:
"Failed to process the configuration file."

Before:
"Done!"

After:
"Configuration file loaded successfully."

Before:
"Invalid value."

After:
"Invalid timeout value: expected a positive integer."

Only use the improved wording when it accurately reflects the actual implementation.

## 2.4 Consistent Message Structure

Use consistent sentence structure across similar logging events.

Recommended patterns:

Informational:
"[Operation or resource] [relevant status]."

Success:
"[Operation] completed successfully."

Warning:
"[Operation or resource] [unexpected but recoverable condition]."

Error:
"Failed to [operation]: [specific reason or context]."

Debug:
"[Technical operation or state transition]: [relevant diagnostic context]."

These are guidelines, not mandatory literal templates. Adapt them to the project's existing logging conventions.

## 2.5 Dynamic Values and Context

- Preserve existing variable interpolation and formatting.
- Keep meaningful identifiers and resource names.
- Use contextual values only when they improve diagnostics.
- Avoid unnecessarily dumping entire objects or payloads.
- Preserve placeholders, formatting specifiers, and argument ordering.
- Do not invent values or runtime context.
- Ensure messages remain readable when dynamic values are inserted.

## 2.6 Language and Terminology

- Use the requested language consistently.
- Prefer standard technical terminology.
- Keep product names, API names, commands, and established technical identifiers unchanged.
- Avoid mixing languages unnecessarily.
- Maintain consistent terminology for the same concept throughout the codebase.

# PHASE 3 — LOGGING SEVERITY REVIEW

Review the appropriateness of logging severity levels.

Use the following guidelines:

- DEBUG: Detailed diagnostic information useful during development or troubleshooting.
- INFO: Normal application events and meaningful operational milestones.
- WARN: Unexpected or abnormal conditions that do not necessarily prevent execution.
- ERROR: Operations that failed or errors requiring attention.

Additional rules:

- Do not downgrade genuine errors to informational messages.
- Do not upgrade normal operational events to warnings or errors.
- Do not change severity levels merely to make logs appear cleaner.
- Preserve the existing severity unless there is a clearly verified classification issue.
- Any proposed severity change must be justified in the audit results.

Severity changes are separate from message wording changes and must be treated as potentially behavior-affecting modifications.

# PHASE 4 — LOGGING SAFETY AND OBSERVABILITY

Review logging messages for operational safety.

Mandatory considerations:

1. Never expose passwords, access tokens, API keys, private keys, session identifiers, or other secrets.
2. Avoid logging sensitive personal information or confidential payloads.
3. Do not unnecessarily log entire request or response bodies.
4. Preserve useful error context without exposing sensitive data.
5. Avoid duplicate logging of the same error at multiple layers unless each entry provides distinct diagnostic value.
6. Preserve correlation IDs, request IDs, resource identifiers, and other existing diagnostic metadata.
7. Do not remove contextual information required for troubleshooting.
8. Preserve structured logging fields and their existing data types.
9. Do not convert structured logs into plain strings.
10. Do not modify log destinations, handlers, transports, or output streams.

If an existing message appears to expose sensitive information, report it and propose a minimal safe correction.

# PHASE 5 — CONSISTENCY REVIEW

After updating the messages:

1. Compare similar logging events across the codebase.
2. Ensure the same operation uses consistent terminology.
3. Ensure equivalent events use consistent sentence structures.
4. Verify capitalization and punctuation.
5. Verify that success, warning, and error messages are distinguishable.
6. Ensure all messages follow the requested language.
7. Check for duplicate or redundant logging messages.
8. Verify that all dynamic placeholders remain valid.

Create a summary table:

| Category           | Before | After | Status |
| ------------------ | ------ | ----- | ------ |
| Professional tone  | ...    | ...   | ...    |
| Technical accuracy | ...    | ...   | ...    |
| Message clarity    | ...    | ...   | ...    |
| Terminology        | ...    | ...   | ...    |
| Formatting         | ...    | ...   | ...    |
| Logging safety     | ...    | ...   | ...    |

# PHASE 6 — CODE INTEGRITY VERIFICATION

Ensure that the changes are limited to logging message improvements.

Preserve:

- Logging function names and signatures.
- Logging severity levels, unless explicitly justified and approved.
- Existing logging conditions.
- Control flow and execution order.
- Variable names and interpolation.
- Formatting specifiers and argument ordering.
- Structured logging fields and metadata.
- Log destinations and output streams.
- Exception handling and error propagation.
- Return values and exit codes.
- Existing application behavior.

Do NOT:

- Refactor unrelated code.
- Add new logging statements unnecessarily.
- Remove existing logging statements without explicit justification.
- Change business logic.
- Change exception handling.
- Introduce new dependencies.
- Modify logging configuration.
- Change machine-readable log formats without explicit approval.

If a message cannot be improved without changing behavior, preserve it and report the limitation.

# CONSTRAINTS

- Only modify logging messages within the requested scope.
- Preserve the original meaning and technical context.
- Do not invent operational events or failure reasons.
- Do not change execution logic or control flow.
- Do not introduce new dependencies or logging abstractions.
- Follow existing project conventions.
- Keep the diff minimal and focused.
- Do not silently modify log severity levels.
- Do not break tests, log parsers, monitoring rules, or automation.
- Preserve backward compatibility with machine-readable log consumers.
- Report any proposed behavior-affecting changes separately.

# PROCESS

1. Inspect the project structure and identify the requested scope.
2. Locate all logging statements and logging abstractions.
3. Read the surrounding code to understand each logging event.
4. Produce the Phase 1 audit table before editing.
5. Classify each message and propose improved wording.
6. Standardize messages according to the defined requirements.
7. Review severity levels and logging safety.
8. Compare similar messages across the requested scope.
9. Verify placeholders, interpolation, and structured logging fields.
10. Run relevant syntax checks, tests, and linters.
11. Inspect the final diff to ensure only approved logging-related changes were made.
12. Report remaining issues and unresolved messages.

For large codebases:

- Process files incrementally.
- Maintain consistent terminology across modules.
- Track completed and remaining files.
- Do not silently skip logging statements.
- Continue until the entire requested scope is audited.

# OUTPUT FORMAT

## 1. Logging Convention Summary

Summarize the existing logging architecture, libraries, severity levels, and conventions.

## 2. Logging Audit (Before)

Present the audit table containing:

- File.
- Function.
- Original message.
- Identified issue.
- Proposed message.
- Severity.

## 3. Standardization Results (After)

Present a summary of changes:

| File | Function | Original Message | Updated Message | Change Type |
| ---- | -------- | ---------------- | --------------- | ----------- |

## 4. Updated Source Code / Unified Diff

- Show the modified source code or unified diff.
- Group changes by file.
- Highlight message wording changes.
- Clearly identify any severity changes.
- Do not omit relevant modifications.

## 5. Quality Review

Report the results of:

- Professional tone.
- Technical accuracy.
- Clarity and readability.
- Terminology consistency.
- Formatting consistency.
- Logging safety.
- Structured logging compatibility.

## 6. Verification Results

Report:

- Files inspected.
- Logging statements audited.
- Messages kept unchanged.
- Messages improved.
- Messages corrected.
- Messages requiring manual review.
- Tests and lint results.
- Code integrity verification.

## 7. Remaining Issues

List messages that could not be safely improved because of missing context, external dependencies, or compatibility constraints.

Include the file path, function, reason, and recommended follow-up.

# DEFINITION OF DONE

The task is complete only when:

- Every logging statement within the requested scope has been audited.
- Every relevant message is professional, technically accurate, clear, and human-readable.
- Similar logging events follow consistent terminology and formatting.
- Dynamic values and structured logging fields remain valid.
- No sensitive information is unnecessarily exposed.
- Existing logging behavior and execution logic remain unchanged.
- No unrelated code has been modified.
- Relevant tests and static checks pass.
- All unresolved issues are explicitly reported.
- The final diff is minimal and focused on logging standardization.

**Final principle: Every log message should communicate what actually happened, why it matters, and enough context to help diagnose the situation — without misleading the reader or changing application behavior.**
