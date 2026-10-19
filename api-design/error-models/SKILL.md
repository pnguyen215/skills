---
name: error-models
description: 'Standardizes API error responses, HTTP/gRPC status codes, and RFC 7807. Trigger: "design error model", "standardize API errors", "fix API status codes".'
---

# API Error Models

## Purpose

Defines consistent, machine-readable error response structures for REST and gRPC APIs.

## When to Use / When NOT to Use

- **Use**: Designing new APIs, standardizing legacy errors, debugging client error handling.
- **NOT**: Designing internal domain errors (use language-specific error types).

## Prerequisites & Assumptions

- API exposed over HTTP/REST or gRPC.
- Clients require predictable error schemas for retries and UI.

## Step-by-Step Workflow

1. Adopt RFC 7807 (`application/problem+json`) for REST.
2. Define standard error codes (e.g., `AUTH_INVALID_TOKEN`).
3. Map internal errors to HTTP/gRPC status codes.
4. Include correlation IDs in error payloads.

## Enterprise Rules & Standards

- **MUST**: Use RFC 7807 for REST errors (include `type`, `title`, `status`, `detail`, `instance`).
- **MUST**: Include a `trace_id` or `correlation_id` in every error response.
- **SHOULD**: Provide actionable `help` links in the payload.
- **MUST NOT**: Expose stack traces or internal IPs in production.

## Examples

- **Bad**: `{"error": "user not found"}` (HTTP 200)
- **Good**: `{"type": "https://api/errors/not-found", "title": "Not Found", "status": 404, "trace_id": "abc-123"}` (HTTP 404)

## Checklist

- [ ] RFC 7807 adopted.
- [ ] Trace ID propagated.
- [ ] Stack traces disabled.

## Common Pitfalls

- Returning HTTP 200 for application errors.
- Leaking sensitive database constraints in error details.

## References

- [RFC 7807: Problem Details for HTTP APIs](https://datatracker.ietf.org/doc/html/rfc7807)
