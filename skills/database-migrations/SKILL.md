---
name: database-migrations
description: 'Safe database schema migrations, zero-downtime deployments, rollbacks. Trigger: "database migration strategy", "zero-downtime schema change", "flyway".'
metadata:
  category: database
  tags: "database, migrations, zero-downtime, rollback, schema"
---

# Database Migrations

## Purpose

Manages schema evolution safely and reversibly. Responsibility boundary: plans and writes migration scripts and rollout sequencing; does NOT run migrations against production, and does NOT design schemas from scratch.

## When to Use / When NOT to Use

- **Use**: Adding columns, renaming tables, changing types.
- **NOT**: Ad-hoc manual DB tweaks in production.
- **NOT**: PostgreSQL-specific script conventions and `COMMENT ON` standards (use `database-postgres-migrations`).
- **NOT**: Designing entities, normalization or constraints (use `database-schema-design`).
- **NOT**: Query or index tuning (use `database-query-optimization`).

## Prerequisites & Assumptions

- Migration tool (Flyway, golang-migrate, Liquibase). Backups available.

### Scope & Context Resolution

- **Supported scopes**: repository migrations directory (default), single migration script, single table/column change, rollout plan for one release.
- **Rule 1 - Explicit context**: The user's stated requirements, constraints, versions, targets and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line. Security/data-loss rules (no single-step drops, tested DOWN, backups) stay mandatory; flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at migrations-directory scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to new or named migration scripts. MUST NOT edit already-applied migrations or execute them against any database.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Write UP migration script (only for the named change).
3. Write DOWN migration script.
4. Test on staging environment.
5. Deploy using expand/contract pattern for breaking changes.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Every UP migration must have a tested DOWN.
- **MUST**: Use expand/contract for breaking schema changes.
- **SHOULD**: Avoid long-running locking operations.
- **MUST NOT**: Drop columns in a single step (breaks old code).
- **MUST NOT**: Edit previously applied migrations or alter unrelated tables while handling the requested change.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `ALTER TABLE users DROP COLUMN email;`
- **Good**: Deploy code to ignore column -> Drop column in next release.
- **Scope - Good**: Prompt "only add `users.phone`" -> one new `V12__add_users_phone.sql` (nullable column) plus its DOWN; note a missing index on `orders` without touching it.
- **Scope - Bad**: Same prompt -> also renaming `orders` columns and rewriting `V3__init.sql`.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] DOWN migration tested.
- [ ] Expand/contract used.
- [ ] Zero downtime verified.

## Common Pitfalls

- Locking tables during peak traffic.
- Irreversible migrations without backups.
- "Fixing" neighbouring migrations or tables while adding one change.

## References (official docs, standards)

- [Expand and Contract Pattern](https://martinfowler.com/bliki/ParallelChange.html)
- [Flyway Documentation](https://documentation.red-gate.com/flyway)
- [golang-migrate](https://github.com/golang-migrate/migrate)
