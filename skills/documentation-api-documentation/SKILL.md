---
name: documentation-api-documentation
description: 'Generating and maintaining OpenAPI/Swagger specs and gRPC Proto docs. Trigger: "generate OpenAPI", "document gRPC", "swagger UI".'
metadata:
  category: documentation
  tags: "documentation, openapi, swagger, grpc, proto"
---

# API Documentation

## Purpose

Creates accurate, interactive documentation for API consumers. Responsibility boundary: edits API specs, annotations and doc-generation config in the named scope; does NOT change API behavior or design.

## When to Use / When NOT to Use

- **Use**: Public APIs, internal SDK generation, client onboarding.
- **NOT**: Internal code comments (use inline docs).
- **NOT**: Designing endpoints or payloads (use `api-design-rest-grpc-conventions`).
- **NOT**: Designing error models (use `api-design-error-models`).
- **NOT**: ADRs, runbooks or READMEs (use `documentation-technical-writing` or `documentation-readme-generator`).

## Prerequisites & Assumptions

- Code-first or Design-first approach selected.

### Scope & Context Resolution

- **Supported scopes**: project/repository, API spec file (OpenAPI/Proto), service/package, endpoint or RPC, schema/message. Default when none is given: the API spec file(s) of the named service; if none is named, the project.
- **Rule 1 - Explicit context in the prompt**: the user's stated requirements, constraints, versions (e.g., OpenAPI 3.0 vs 3.1), targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to specs, doc annotations and doc-generation/hosting config inside the resolved scope; MUST NOT change runtime API behavior.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Write OpenAPI/Proto specs or annotate code (within the resolved scope).
3. Generate server stubs and documentation.
4. Host via Swagger UI, Redoc, or Bazel.
5. Automate updates in CI/CD pipeline.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Keep spec in sync with code (use annotations/generators).
- **MUST**: Provide example requests/responses for all endpoints.
- **SHOULD**: Include error schemas (RFC 7807).
- **MUST NOT**: Publish outdated specs that mislead clients.
- **MUST NOT**: Alter code behavior to make it match the docs; report the mismatch instead.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Outdated static Swagger JSON file.
- **Good**: Auto-generated OpenAPI from code comments on every build.

**Scope handling**

- **Prompt**: "Document only `POST /orders` in `openapi.yaml`."
- **Good**: Adds summary, schemas, request/response and error examples for that operation; lists undocumented endpoints as notes.
- **Bad**: Regenerates the whole spec and edits handler code to fit it.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Spec matches code.
- [ ] Examples provided.
- [ ] Hosted and accessible.

## Common Pitfalls

- Drift between code and docs.
- Missing error cases in examples.
- Regenerating an entire spec when only one endpoint was requested.

## References (official docs, standards)

- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html)
