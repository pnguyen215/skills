---
name: api-design-error-models
description: 'Standardizes API error responses, HTTP/gRPC status codes, and RFC 7807. Trigger: "design error model", "standardize API errors", "fix API status codes".'
metadata:
  category: api-design
  tags: "api, error-handling, rfc-7807, http-status, grpc"
---

# API Error Models

## Purpose

Defines consistent, machine-readable error response structures for REST and gRPC APIs. Responsibility boundary: designs and edits error schemas, status-code mappings and error-handling code in the named scope; does NOT design endpoints, versioning or internal domain error types.

## When to Use / When NOT to Use

- **Use**: Designing new APIs, standardizing legacy errors, debugging client error handling.
- **NOT**: Designing internal domain errors (use language-specific error types).
- **NOT**: Endpoint naming, payload or pagination design (use `api-design-rest-grpc-conventions`).
- **NOT**: Versioning or deprecation policy (use `api-design-versioning`).
- **NOT**: Writing OpenAPI/Proto documentation (use `documentation-api-documentation`).

## Prerequisites & Assumptions

- API exposed over HTTP/REST or gRPC.
- Clients require predictable error schemas for retries and UI.

### Scope & Context Resolution

- **Supported scopes**: project/repository, directory/module, API spec file, endpoint, error type/handler. Default when none is given: the error-response layer of the named API; if no API is named, the project.
- **Rule 1 - Explicit context in the prompt**: the user's stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules (e.g., no stack traces or internal details in responses), which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to error schemas, status mappings and error-handling code inside the resolved scope; MUST NOT change success payloads or business logic.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Adopt RFC 7807 (`application/problem+json`) for REST.
3. Define standard error codes (e.g., `AUTH_INVALID_TOKEN`).
4. Map internal errors to HTTP/gRPC status codes (only for endpoints within the resolved scope).
5. Include correlation IDs in error payloads.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Use RFC 7807 for REST errors (include `type`, `title`, `status`, `detail`, `instance`).
- **MUST**: Include a `trace_id` or `correlation_id` in every error response.
- **SHOULD**: Provide actionable `help` links in the payload.
- **MUST NOT**: Expose stack traces or internal IPs in production.
- **MUST NOT**: Rewrite error handling of endpoints or services outside the named scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `{"error": "user not found"}` (HTTP 200)
- **Good**: `{"type": "https://api/errors/not-found", "title": "Not Found", "status": 404, "trace_id": "abc-123"}` (HTTP 404)

**Scope handling**

- **Prompt**: "Standardize errors only for `GET /users/{id}`."
- **Good**: Changes that one endpoint's 404/403 responses to problem+json; lists other endpoints' non-compliant errors as notes.
- **Bad**: Rewrites the global error middleware and every controller's error format.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] RFC 7807 adopted.
- [ ] Trace ID propagated.
- [ ] Stack traces disabled.

## Common Pitfalls

- Returning HTTP 200 for application errors.
- Leaking sensitive database constraints in error details.
- Converting every endpoint's errors when only one was requested.

## References (official docs, standards)

- [RFC 7807: Problem Details for HTTP APIs](https://datatracker.ietf.org/doc/html/rfc7807)
