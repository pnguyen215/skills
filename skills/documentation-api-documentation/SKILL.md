---
name: documentation-api-documentation
description: 'Generating and maintaining OpenAPI/Swagger specs and gRPC Proto docs. Trigger: "generate OpenAPI", "document gRPC", "swagger UI".'
metadata:
  category: documentation
  tags: "documentation, openapi, swagger, grpc, proto"
---

# API Documentation

## Purpose

Creates accurate, interactive documentation for API consumers.

## When to Use / When NOT to Use

- **Use**: Public APIs, internal SDK generation, client onboarding.
- **NOT**: Internal code comments (use inline docs).

## Prerequisites & Assumptions

- Code-first or Design-first approach selected.

## Step-by-Step Workflow

1. Write OpenAPI/Proto specs or annotate code.
2. Generate server stubs and documentation.
3. Host via Swagger UI, Redoc, or Bazel.
4. Automate updates in CI/CD pipeline.

## Enterprise Rules & Standards

- **MUST**: Keep spec in sync with code (use annotations/generators).
- **MUST**: Provide example requests/responses for all endpoints.
- **SHOULD**: Include error schemas (RFC 7807).
- **MUST NOT**: Publish outdated specs that mislead clients.

## Examples

- **Bad**: Outdated static Swagger JSON file.
- **Good**: Auto-generated OpenAPI from code comments on every build.

## Checklist

- [ ] Spec matches code.
- [ ] Examples provided.
- [ ] Hosted and accessible.

## Common Pitfalls

- Drift between code and docs.
- Missing error cases in examples.

## References

- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html)
