---
name: api-design-rest-grpc-conventions
description: 'Defines RESTful and gRPC endpoint naming, payload structures, and pagination. Trigger: "design REST API", "gRPC service conventions", "API pagination".'
metadata:
  category: api-design
---

# REST & gRPC Conventions

## Purpose

Standardizes URL paths, HTTP methods, protobuf naming, and pagination patterns.

## When to Use / When NOT to Use

- **Use**: Designing new endpoints, standardizing resource naming, implementing pagination.
- **NOT**: Internal service-to-service RPC calls where conventions are relaxed.

## Prerequisites & Assumptions

- Clear domain boundaries and resource models.

## Step-by-Step Workflow

1. Define resources as nouns (REST) or services (gRPC).
2. Apply standard HTTP verbs (GET, POST, PUT, PATCH, DELETE).
3. Implement cursor-based pagination for large datasets.
4. Enforce `snake_case` in protobufs, `camelCase` in JSON.

## Enterprise Rules & Standards

- **MUST**: Use plural nouns for REST collections (`/users`).
- **MUST**: Use cursor-based pagination for real-time/large datasets.
- **SHOULD**: Use `camelCase` for JSON, `snake_case` for Protobuf.
- **MUST NOT**: Use verbs in REST paths (e.g., `/getUsers`).

## Examples

- **Bad**: `POST /getUserList`
- **Good**: `GET /users?cursor=abc&limit=50`

## Checklist

- [ ] Plural nouns used.
- [ ] Cursor pagination implemented.
- [ ] Protobuf style guide enforced.

## Common Pitfalls

- Mixing RPC styles in REST endpoints.
- Using offset pagination for high-churn data.

## References

- [Google API Design Guide](https://cloud.google.com/apis/design)
