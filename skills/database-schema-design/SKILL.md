---
name: database-schema-design
description: 'Normalization, denormalization trade-offs, constraint enforcement. Trigger: "design database schema", "model entity relationships", "ERD".'
metadata:
  category: database
  tags: "database, schema, normalization, constraints, data-modeling"
---

# Schema Design

## Purpose

Structures data for integrity, performance, and scalability.

## When to Use / When NOT to Use

- **Use**: New features, data modeling, core domain entities.
- **NOT**: Simple key-value caches or ephemeral logs.

## Prerequisites & Assumptions

- Domain understanding. ACID requirements.

## Step-by-Step Workflow

1. Identify entities & relationships.
2. Normalize to 3NF to prevent anomalies.
3. Denormalize for read performance if proven bottleneck.
4. Enforce constraints (PK, FK, Check, Not Null).

## Enterprise Rules & Standards

- **MUST**: Define Primary and Foreign Keys.
- **MUST**: Use ENUMs or Check constraints for limited values.
- **SHOULD**: Denormalize only with proven read bottlenecks.
- **MUST NOT**: Store JSON blobs for highly queryable data.

## Examples

- **Bad**: Storing CSV tags in a TEXT column.
- **Good**: Relational `user_tags` table with proper FKs.

## Checklist

- [ ] PKs/FKs defined.
- [ ] Constraints applied.
- [ ] Normalization reviewed.

## Common Pitfalls

- Entity-Attribute-Value (EAV) pattern abuse.
- Missing indexes on Foreign Keys.

## References

- [Database Design Tutorial](https://www.vertabelo.com/blog/database-design-tutorial/)
