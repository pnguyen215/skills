---
name: database-migrations
description: 'Safe database schema migrations, zero-downtime deployments, rollbacks. Trigger: "database migration strategy", "zero-downtime schema change", "flyway".'
metadata:
  category: database
  tags: "database, migrations, zero-downtime, rollback, schema"
---

# Database Migrations

## Purpose

Manages schema evolution safely and reversibly.

## When to Use / When NOT to Use

- **Use**: Adding columns, renaming tables, changing types.
- **NOT**: Ad-hoc manual DB tweaks in production.

## Prerequisites & Assumptions

- Migration tool (Flyway, golang-migrate, Liquibase). Backups available.

## Step-by-Step Workflow

1. Write UP migration script.
2. Write DOWN migration script.
3. Test on staging environment.
4. Deploy using expand/contract pattern for breaking changes.

## Enterprise Rules & Standards

- **MUST**: Every UP migration must have a tested DOWN.
- **MUST**: Use expand/contract for breaking schema changes.
- **SHOULD**: Avoid long-running locking operations.
- **MUST NOT**: Drop columns in a single step (breaks old code).

## Examples

- **Bad**: `ALTER TABLE users DROP COLUMN email;`
- **Good**: Deploy code to ignore column -> Drop column in next release.

## Checklist

- [ ] DOWN migration tested.
- [ ] Expand/contract used.
- [ ] Zero downtime verified.

## Common Pitfalls

- Locking tables during peak traffic.
- Irreversible migrations without backups.

## References

- [Expand and Contract Pattern](https://martinfowler.com/bliki/ParallelChange.html)
