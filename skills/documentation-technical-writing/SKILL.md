---
name: documentation-technical-writing
description: 'Authoring ADRs, runbooks, RFCs, and inline code documentation. Trigger: "write ADR", "create runbook", "improve GoDoc", "technical spec".'
metadata:
  category: documentation
  tags: "documentation, adr, runbook, rfc, technical-writing"
---

# Technical Writing

## Purpose

Documents decisions, operations, and deep technical concepts.

## When to Use / When NOT to Use

- **Use**: Architecture decisions, incident runbooks, deep dives.
- **NOT**: Marketing copy or user-facing tutorials.

## Prerequisites & Assumptions

- Context and audience understanding.

## Step-by-Step Workflow

1. Identify audience (devs, ops, external).
2. Choose format (ADR, Runbook, RFC).
3. Draft with clear headings and diagrams.
4. Peer review and publish.

## Enterprise Rules & Standards

- **MUST**: Use standard templates for ADRs/Runbooks.
- **MUST**: Date and version documents.
- **SHOULD**: Use diagrams over text where possible.
- **MUST NOT**: Use ambiguous language (e.g., "soon", "later").

## Examples

- **Bad**: "We will fix the database later."
- **Good**: "ADR-001: Migrate to PostgreSQL by Q3 2024."

## Checklist

- [ ] Template used.
- [ ] Peer reviewed.
- [ ] Diagrams included.

## Common Pitfalls

- Stale docs that contradict code.
- Too verbose, burying the key point.

## References

- [Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
