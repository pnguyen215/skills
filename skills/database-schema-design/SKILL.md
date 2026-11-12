---
name: database-schema-design
description: 'Normalization, denormalization trade-offs, constraint enforcement. Trigger: "design database schema", "model entity relationships", "ERD".'
metadata:
  category: database
  tags: "database, schema, normalization, constraints, data-modeling"
---

# Schema Design

## Purpose

Structures data for integrity, performance, and scalability. Responsibility boundary: designs and reviews logical schemas (entities, keys, constraints, normalization); does NOT write migration scripts, tune queries, or modify application code.

## When to Use / When NOT to Use

- **Use**: New features, data modeling, core domain entities.
- **NOT**: Simple key-value caches or ephemeral logs.
- **NOT**: Writing or running migration scripts (use `database-migrations` or `database-postgres-migrations`).
- **NOT**: Indexing and slow-query tuning (use `database-query-optimization`).

## Prerequisites & Assumptions

- Domain understanding. ACID requirements.

### Scope & Context Resolution

- **Supported scopes**: whole database/schema, single table or entity, relationship between entities, or a schema artifact (DDL file, ERD). Default: the entities or feature the user names; if none, the domain model described in the prompt.
- **Rule 1 - Explicit context**: user-stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: design output and DDL/ERD files inside the resolved scope only; MUST NOT alter existing tables or data outside it.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Identify entities & relationships within the resolved scope.
3. Normalize to 3NF to prevent anomalies.
4. Denormalize for read performance if proven bottleneck.
5. Enforce constraints (PK, FK, Check, Not Null).

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Define Primary and Foreign Keys.
- **MUST**: Use ENUMs or Check constraints for limited values.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Denormalize only with proven read bottlenecks.
- **MUST NOT**: Store JSON blobs for highly queryable data.
- **MUST NOT**: Redesign tables or relationships outside the named scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Storing CSV tags in a TEXT column.
- **Good**: Relational `user_tags` table with proper FKs.
- **Good (scope)**: Prompt "design only the `invoices` table" -> define `invoices` with PK, FK to `customers`, CHECK on `status`; note any `customers` issues without changing them.
- **Bad (scope)**: Same prompt -> renormalizing `customers`, `orders` and `payments` as well.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] PKs/FKs defined.
- [ ] Constraints applied.
- [ ] Normalization reviewed.

## Common Pitfalls

- Entity-Attribute-Value (EAV) pattern abuse.
- Missing indexes on Foreign Keys.
- Scope creep: remodeling adjacent tables when one entity was requested.

## References (official docs, standards)

- [Database Design Tutorial](https://www.vertabelo.com/blog/database-design-tutorial/)
- [PostgreSQL Documentation: Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html)
