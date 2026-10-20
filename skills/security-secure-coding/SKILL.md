---
name: security-secure-coding
description: 'Preventing OWASP Top 10, input validation, secure-by-default design. Trigger: "prevent SQL injection", "secure coding checklist", "XSS prevention".'
metadata:
  category: security
---

# Security: Secure Coding

## Purpose

Eliminates vulnerabilities at the source code level.

## When to Use / When NOT to Use

- **Use**: Writing new features, security reviews, handling PII.
- **NOT**: Network firewall rules or WAF configuration.

## Prerequisites & Assumptions

- OWASP Top 10 knowledge.

## Step-by-Step Workflow

1. Validate all inputs at trust boundaries.
2. Use parameterized queries (never string concat).
3. Encode outputs based on context (HTML, JS, SQL).
4. Enforce least privilege for DB/App users.

## Enterprise Rules & Standards

- **MUST**: Use parameterized queries (ORM or prepared statements).
- **MUST**: Validate inputs strictly (allowlists over denylists).
- **SHOULD**: Use vetted crypto libraries (never roll own crypto).
- **MUST NOT**: Trust client-side validation alone.

## Examples

- **Bad**: `db.Query("SELECT * FROM users WHERE id = " + id)`
- **Good**: `db.Query("SELECT * FROM users WHERE id = ?", id)`

## Checklist

- [ ] Inputs validated.
- [ ] Parameterized queries used.
- [ ] Output encoded.

## Common Pitfalls

- Security by obscurity.
- Custom cryptography implementations.

## References

- [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
