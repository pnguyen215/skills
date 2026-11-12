---
name: api-design-rest-grpc-conventions
description: 'Defines RESTful and gRPC endpoint naming, payload structures, and pagination. Trigger: "design REST API", "gRPC service conventions", "API pagination".'
metadata:
  category: api-design
  tags: "api, rest, grpc, naming, pagination"
---

# REST & gRPC Conventions

## Purpose

Standardizes URL paths, HTTP methods, protobuf naming, and pagination patterns. It designs and reviews endpoint, service, and payload conventions only; it does NOT define error models, versioning policy, or generate API documentation, and it edits only the API spec or code the user names.

## When to Use / When NOT to Use

- **Use**: Designing new endpoints, standardizing resource naming, implementing pagination.
- **NOT**: Internal service-to-service RPC calls where conventions are relaxed.
- **NOT**: Error response and status code design (use `api-design-error-models`).
- **NOT**: Versioning or deprecation policy (use `api-design-versioning`).
- **NOT**: Generating OpenAPI/Proto documentation (use `documentation-api-documentation`).

## Prerequisites & Assumptions

- Clear domain boundaries and resource models.

### Scope & Context Resolution

- **Supported scopes**: API spec or proto file, single endpoint/RPC method, resource/service, project/repository. Default when none is given: the API surface the user presented in the prompt.
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, constraints, versions, targets, and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow, and rules as the sole context at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits are limited to the named endpoint, resource, or spec file. Without a named file, output a proposal only.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Define resources as nouns (REST) or services (gRPC).
3. Apply standard HTTP verbs (GET, POST, PUT, PATCH, DELETE) to the in-scope endpoints.
4. Implement cursor-based pagination for large datasets.
5. Enforce `snake_case` in protobufs, `camelCase` in JSON.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Use plural nouns for REST collections (`/users`).
- **MUST**: Use cursor-based pagination for real-time/large datasets.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use `camelCase` for JSON, `snake_case` for Protobuf.
- **MUST NOT**: Use verbs in REST paths (e.g., `/getUsers`).
- **MUST NOT**: Rename or restructure endpoints outside the named scope, since this breaks existing clients.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `POST /getUserList`
- **Good**: `GET /users?cursor=abc&limit=50`

**Scope handling**

- **Prompt**: "Only fix pagination on `GET /orders`."
- **Good**: Replaces `?page=3` with `?cursor=...&limit=50` on `/orders` only; notes that `/invoices` also uses offset pagination.
- **Bad**: Renames `/invoices` and `/orders/{id}/getItems` in the same change.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Plural nouns used.
- [ ] Cursor pagination implemented.
- [ ] Protobuf style guide enforced.

## Common Pitfalls

- Mixing RPC styles in REST endpoints.
- Using offset pagination for high-churn data.
- Scope creep: renaming every endpoint in a service when asked about one resource.

## References (official docs, standards)

- [Google API Design Guide](https://cloud.google.com/apis/design)
