---
name: database-postgres-migrations
description: 'Standardizes PostgreSQL migration scripts (Flyway/Liquibase) with strict schema design, partitioning, and mandatory documentation. Trigger: "write postgres migration", "create sql script", "design postgres schema", "flyway migration", "add COMMENT ON".'
metadata:
  category: database
  tags: "postgresql, migrations, flyway, liquibase, partitioning"
---

# PostgreSQL Migration & Schema Standards

## Purpose

Defines the strict enterprise standards for writing PostgreSQL database migration scripts, ensuring multi-tenancy, soft-deletes, auditability, performance (partitioning/indexes), and mandatory documentation via `COMMENT ON`.

## When to Use / When NOT to Use

- **Use**: Writing new Flyway/Liquibase migration scripts (`VXXX__name.sql`), designing PostgreSQL tables, adding columns to existing tables.
- **NOT**: NoSQL databases, simple SQLite prototypes, or ORM-only auto-migrations in production.

## Prerequisites & Assumptions

- PostgreSQL 12+ (for declarative partitioning and JSONB features).
- Migration tool (Flyway, Liquibase, or golang-migrate) managing versioned SQL files.

## Step-by-Step Workflow

1. Create a new migration file with sequential versioning (e.g., `V001__add_carrier_domain.sql`).
2. Define tables with standard audit, multi-tenant, and soft-delete columns.
3. Add explicit constraints (PK, UK, FK, CHECK) using `ALTER TABLE` after creation.
4. Create targeted indexes for performance and soft-delete filtering.
5. Apply declarative partitioning for high-volume/audit tables.
6. Write `COMMENT ON TABLE` and `COMMENT ON COLUMN` for _every single entity_.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

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

## Examples

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

## Checklist

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

## References

- [PostgreSQL Declarative Partitioning](https://www.postgresql.org/docs/current/ddl-partitioning.html)
- [Flyway SQL Migration Syntax](https://flywaydb.org/documentation/concepts/migrations.html#sql-based-migrations)
