---
name: query-optimization
description: 'Indexing strategies, EXPLAIN plan analysis, N+1 prevention. Trigger: "optimize SQL query", "fix N+1 queries", "slow query log".'
---

# Query Optimization

## Purpose

Reduces database load and improves response times.

## When to Use / When NOT to Use

- **Use**: Slow query logs, scaling DB reads, high CPU on DB.
- **NOT**: Premature optimization before profiling.

## Prerequisites & Assumptions

- Query access. EXPLAIN plan knowledge.

## Step-by-Step Workflow

1. Identify slow queries via APM or slow logs.
2. Analyze EXPLAIN plan for full table scans.
3. Add/adjust indexes based on WHERE/JOIN clauses.
4. Fix N+1 queries via JOINs or Eager loading.

## Enterprise Rules & Standards

- **MUST**: Analyze EXPLAIN before adding indexes.
- **MUST**: Prevent N+1 queries in ORMs.
- **SHOULD**: Use covering indexes for frequent read patterns.
- **MUST NOT**: Use `SELECT *` in large tables.

## Examples

- **Bad**: Looping users and fetching posts individually (N+1).
- **Good**: `SELECT * FROM users JOIN posts ON users.id = posts.user_id`

## Checklist

- [ ] EXPLAIN analyzed.
- [ ] N+1 fixed.
- [ ] Indexes added and monitored.

## Common Pitfalls

- Over-indexing (slows down writes).
- Ignoring ORM generated SQL.

## References

- [Use The Index, Luke!](https://use-the-index-luke.com/)
