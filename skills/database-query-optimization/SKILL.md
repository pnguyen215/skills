---
name: database-query-optimization
description: 'Indexing strategies, EXPLAIN plan analysis, N+1 prevention. Trigger: "optimize SQL query", "fix N+1 queries", "slow query log".'
metadata:
  category: database
  tags: "database, sql, indexing, explain-plan, n-plus-one, performance"
---

# Query Optimization

## Purpose

Reduces database load and improves response times. It analyzes and rewrites the named queries and proposes indexes; it does NOT change schema design, run migrations, or tune database server configuration.

## When to Use / When NOT to Use

- **Use**: Slow query logs, scaling DB reads, high CPU on DB.
- **NOT**: Premature optimization before profiling.
- **NOT**: Schema redesign or normalization (use `database-schema-design`).
- **NOT**: Authoring or rolling out migration scripts (use `database-migrations`).

## Prerequisites & Assumptions

- Query access. EXPLAIN plan knowledge.

### Scope & Context Resolution

- **Supported scopes**: single query, function/method issuing queries (ORM call site), table, module/package, project/repository. Default when none is given: the queries provided in the prompt.
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, constraints, versions, targets (database engine, ORM), and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow, and rules as the sole context at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits are limited to the in-scope queries and proposed index DDL. MUST NOT execute DDL or write statements against a database unless the user explicitly asks.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Identify slow queries via APM or slow logs within the scope.
3. Analyze EXPLAIN plan for full table scans.
4. Add/adjust indexes based on WHERE/JOIN clauses.
5. Fix N+1 queries via JOINs or Eager loading at the in-scope call sites.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Analyze EXPLAIN before adding indexes.
- **MUST**: Prevent N+1 queries in ORMs.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use covering indexes for frequent read patterns.
- **MUST NOT**: Use `SELECT *` in large tables.
- **MUST NOT**: Add or drop indexes on tables outside the named scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Looping users and fetching posts individually (N+1).
- **Good**: `SELECT * FROM users JOIN posts ON users.id = posts.user_id`

**Scope handling**

- **Prompt**: "Optimize only the `orders` query in `report.sql`."
- **Good**: Runs EXPLAIN on that query, proposes one index on `orders(customer_id, created_at)`, notes that `invoices` has a similar scan.
- **Bad**: Rewrites every query in the repository and adds indexes to five other tables.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] EXPLAIN analyzed.
- [ ] N+1 fixed.
- [ ] Indexes added and monitored.

## Common Pitfalls

- Over-indexing (slows down writes).
- Ignoring ORM generated SQL.
- Scope creep: tuning every table's indexes when asked about one query.

## References (official docs, standards)

- [Use The Index, Luke!](https://use-the-index-luke.com/)
