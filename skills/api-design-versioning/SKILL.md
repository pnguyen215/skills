---
name: api-design-versioning
description: 'Strategies for API versioning (URI, Header) and deprecation policies. Trigger: "API versioning strategy", "deprecate API endpoint", "sunset API".'
metadata:
  category: api-design
  tags: "api, versioning, deprecation, backward-compatibility, rest"
---

# API Versioning & Deprecation

## Purpose

Manages breaking changes gracefully without disrupting existing clients. Responsibility boundary: designs and reviews versioning and deprecation strategy, headers and migration guidance; does NOT implement endpoints, change business logic, or redesign payloads or error models.

## When to Use / When NOT to Use

- **Use**: Introducing breaking changes, managing multiple API versions, sunsetting endpoints.
- **NOT**: Non-breaking changes (additive fields, new endpoints).
- **NOT**: Endpoint naming, payload structure, or pagination design (use `api-design-rest-grpc-conventions`).
- **NOT**: Error response and status code standardization (use `api-design-error-models`).

## Prerequisites & Assumptions

- Semantic versioning of the API contract.

### Scope & Context Resolution

- **Supported scopes**: whole API, single API spec (OpenAPI/proto), endpoint or resource group. Default: the API or spec the user names; if none, the whole API under discussion.
- **Rule 1 - Explicit context**: user-stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to versioning/deprecation artifacts (spec version fields, deprecation headers, migration guide) inside the resolved scope; MUST NOT edit handler logic.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Choose versioning strategy (URI `/v1/` vs Header `Api-Version`) for the resolved scope.
3. Define deprecation policy (e.g., 6 months notice).
4. Add `Deprecation` and `Sunset` HTTP headers to affected endpoints only.
5. Monitor legacy version traffic via telemetry.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Communicate deprecation via `Deprecation` HTTP header.
- **MUST**: Provide a migration guide for breaking changes.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Support N-1 versions concurrently.
- **MUST NOT**: Introduce breaking changes in minor/patch versions.
- **MUST NOT**: Deprecate or re-version endpoints outside the named scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Deleting `/users` and replacing with `/v2/users` without warning.
- **Good**: Header: `Deprecation: true`, `Sunset: Sat, 01 Jan 2025 00:00:00 GMT`.
- **Good (scope)**: Prompt "deprecate only `GET /v1/orders`" -> add `Deprecation`/`Sunset` headers and a migration note for that endpoint; list other legacy endpoints as notes.
- **Bad (scope)**: Same prompt -> bumping the whole API to `/v2/` and deprecating every `/v1` route.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Deprecation headers added.
- [ ] Migration guide published.
- [ ] Telemetry tracking enabled.

## Common Pitfalls

- Breaking backwards compatibility silently.
- Maintaining too many legacy versions indefinitely.
- Scope creep: re-versioning an entire API when only one endpoint was named.

## References (official docs, standards)

- [RFC 8594: The Sunset HTTP Header Field](https://datatracker.ietf.org/doc/html/rfc8594)
- [Semantic Versioning 2.0.0](https://semver.org/)
