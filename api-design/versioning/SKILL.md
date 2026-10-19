---
name: versioning
description: 'Strategies for API versioning (URI, Header) and deprecation policies. Trigger: "API versioning strategy", "deprecate API endpoint", "sunset API".'
---

# API Versioning & Deprecation

## Purpose

Manages breaking changes gracefully without disrupting existing clients.

## When to Use / When NOT to Use

- **Use**: Introducing breaking changes, managing multiple API versions, sunsetting endpoints.
- **NOT**: Non-breaking changes (additive fields, new endpoints).

## Prerequisites & Assumptions

- Semantic versioning of the API contract.

## Step-by-Step Workflow

1. Choose versioning strategy (URI `/v1/` vs Header `Api-Version`).
2. Define deprecation policy (e.g., 6 months notice).
3. Add `Deprecation` and `Sunset` HTTP headers.
4. Monitor legacy version traffic via telemetry.

## Enterprise Rules & Standards

- **MUST**: Communicate deprecation via `Deprecation` HTTP header.
- **MUST**: Provide a migration guide for breaking changes.
- **SHOULD**: Support N-1 versions concurrently.
- **MUST NOT**: Introduce breaking changes in minor/patch versions.

## Examples

- **Bad**: Deleting `/users` and replacing with `/v2/users` without warning.
- **Good**: Header: `Deprecation: true`, `Sunset: Sat, 01 Jan 2025 00:00:00 GMT`.

## Checklist

- [ ] Deprecation headers added.
- [ ] Migration guide published.
- [ ] Telemetry tracking enabled.

## Common Pitfalls

- Breaking backwards compatibility silently.
- Maintaining too many legacy versions indefinitely.

## References

- [RFC 8594: The Sunset HTTP Header Field](https://datatracker.ietf.org/doc/html/rfc8594)
