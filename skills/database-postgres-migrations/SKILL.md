---
name: database-postgres-migrations
description: 'Standardizes PostgreSQL migration scripts (Flyway/Liquibase) with strict schema design, partitioning, and mandatory documentation. Trigger: "write postgres migration", "create sql script", "design postgres schema", "flyway migration", "add COMMENT ON".'
metadata:
  category: database
  tags: "postgresql, migrations, flyway, liquibase, partitioning"
---

# PostgreSQL Migration & Schema Standards

## Purpose

Defines the strict enterprise standards for writing PostgreSQL database migration scripts, ensuring multi-tenancy, soft-deletes, auditability, performance (partitioning/indexes), and mandatory documentation via `COMMENT ON`. Responsibility boundary: authors or edits migration scripts only; does NOT run migrations against any database and does NOT edit already-applied migrations.

## When to Use / When NOT to Use

- **Use**: Writing new Flyway/Liquibase migration scripts (`VXXX__name.sql`), designing PostgreSQL tables, adding columns to existing tables.
- **NOT**: NoSQL databases, simple SQLite prototypes, or ORM-only auto-migrations in production.
- **NOT**: Zero-downtime rollout and rollback strategy (use `database-migrations`).
- **NOT**: Query tuning or EXPLAIN analysis (use `database-query-optimization`).
- **NOT**: Conceptual schema modelling or ERDs (use `database-schema-design`).

## Prerequisites & Assumptions

- PostgreSQL 12+ (for declarative partitioning and JSONB features).
- Migration tool (Flyway, Liquibase, or golang-migrate) managing versioned SQL files.

### Scope & Context Resolution

- **Supported scopes**: project/repository, migration directory, migration script file, table, column, index/constraint. Default when none is given: the single new migration script for the table(s) the user names.
- **Rule 1 - Explicit context in the prompt**: the user's stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules(never drop data or edit applied migrations without confirmation), which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to new or explicitly named migration files; MUST NOT modify applied migrations, execute SQL against a database, or alter application code.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Create a new migration file with sequential versioning (e.g., `V001__add_carrier_domain.sql`).
3. Define tables with standard audit, multi-tenant, and soft-delete columns.
4. Add explicit constraints (PK, UK, FK, CHECK) using `ALTER TABLE` after creation.
5. Create targeted indexes for performance and soft-delete filtering.
6. Apply declarative partitioning for high-volume/audit tables.
7. Write `COMMENT ON TABLE` and `COMMENT ON COLUMN` for _every single entity_.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

### 0. Scope

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST NOT**: Alter tables, columns or data outside the named scope, or edit already-applied migration files (add a new versioned script instead).

### 1. Naming Conventions

- **MUST**: Use `snake_case` for all tables, columns, and constraints.
- **MUST**: Prefix domain tables (e.g., `crr_orders`, `iam_users`, `audit_ffm_batches`).
- **MUST**: Name indexes `idx_{table}_{column}`, UKs `uk_{table}_{column}`, FKs `fk_{table}_{ref}`, Checks `chk_{table}_{column}`.

### 2. Standard Columns (Boilerplate)

- **MUST**: Include `id SERIAL PRIMARY KEY` (or `BIGSERIAL` for partitioned/high-volume).
- **MUST**: Include `tenant_id INTEGER NOT NULL` for multi-tenancy.
- **MUST**: Include `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()` and `updated_at TIMESTAMPTZ`.
- **MUST**: Include `created_by INTEGER` and `updated_by INTEGER` (FK to users).
- **MUST**: Include `archived BOOLEAN NOT NULL DEFAULT FALSE` and `deleted_at TIMESTAMPTZ` for soft-deletes.

### 3. Data Types

- **MUST**: Use `TIMESTAMPTZ` for all timestamps. NEVER use `TIMESTAMP` without timezone.
- **MUST**: Use `NUMERIC(15, 4)` for financial amounts, paired with a `VARCHAR(10)` currency code.
- **MUST**: Use `JSONB DEFAULT '{}'` for flexible metadata, never `JSON` or `TEXT`.

### 4. Constraints & Indexes

- **MUST**: Define Foreign Keys, Unique Constraints, and Check Constraints explicitly via `ALTER TABLE`.
- **MUST**: Add `CHECK` constraints for numeric bounds (e.g., `quantity >= 0`).
- **MUST**: Create a composite index on `(archived, deleted_at)` for all soft-deletable tables.
- **MUST**: Index all Foreign Key columns and frequent query filters.

### 5. Partitioning (High-Volume/Audit Tables)

- **MUST**: Use Declarative Range Partitioning (`PARTITION BY RANGE (created_at)`) for audit trails and history tables.
- **MUST**: Include the partition key in the Primary Key (`PRIMARY KEY (id, created_at)`).
- **MUST**: Pre-create monthly partitions (`_YYYYMM`) and a `DEFAULT` partition.

### 6. Documentation (Zero Exceptions)

- **MUST**: Add `COMMENT ON TABLE` immediately after table creation.
- **MUST**: Add `COMMENT ON COLUMN` for _every single column_ explaining its purpose, especially JSONB, timestamps, and foreign keys.

## Examples (good vs. bad, with realistic code or output)

**Bad**:

```sql
CREATE TABLE orders (
  id INT PRIMARY KEY,
  created_at TIMESTAMP,
  amount FLOAT,
  metadata TEXT
);
```

**Good**:

```sql
CREATE TABLE crr_orders (
  id SERIAL PRIMARY KEY,
  tenant_id INTEGER NOT NULL,
  amount NUMERIC(15, 4) NOT NULL DEFAULT 0,
  currency VARCHAR(10) DEFAULT 'USD',
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  archived BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at TIMESTAMPTZ
);
ALTER TABLE crr_orders ADD CONSTRAINT chk_crr_orders_amount CHECK (amount >= 0);
CREATE INDEX idx_crr_orders_archived_deleted ON crr_orders(archived, deleted_at);
COMMENT ON TABLE crr_orders IS 'Delivery orders for last-mile logistics';
COMMENT ON COLUMN crr_orders.metadata IS 'Additional metadata for the order, stored as JSONB';
COMMENT ON COLUMN crr_orders.deleted_at IS 'Soft delete timestamp; deleted orders are not visible';
```

**Scope handling**

- **Prompt**: "Add a `carrier_id` column to `crr_orders` only."
- **Good**: New `V0xx__add_carrier_id_to_crr_orders.sql` with the column, FK via `ALTER TABLE`, index and `COMMENT ON COLUMN`; notes other tables lacking comments.
- **Bad**: Edits the original `V001` script and adds comments/indexes to unrelated tables.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] File named correctly (`VXXX__description.sql`).
- [ ] Standard audit/tenant/soft-delete columns present.
- [ ] `TIMESTAMPTZ` and `NUMERIC` used correctly.
- [ ] Constraints added via `ALTER TABLE`.
- [ ] Indexes created for FKs and `(archived, deleted_at)`.
- [ ] `COMMENT ON` applied to Table and ALL Columns.
- [ ] Partitioning applied if table is high-volume/audit.

## Common Pitfalls

- Using `TIMESTAMPT` instead of `TIMESTAMPTZ`, causing timezone shift bugs across regions.
- Forgetting to include `created_at` in the Primary Key of a partitioned table (PostgreSQL requirement).
- Missing `COMMENT ON` for JSONB columns, leaving future devs guessing the internal schema.
- Using `FLOAT` or `REAL` for currency, leading to precision loss.
- Editing an applied migration or touching neighbouring tables when only one change was requested.

## References (official docs, standards)

- [PostgreSQL Declarative Partitioning](https://www.postgresql.org/docs/current/ddl-partitioning.html)
- [Flyway SQL Migration Syntax](https://flywaydb.org/documentation/concepts/migrations.html#sql-based-migrations)
