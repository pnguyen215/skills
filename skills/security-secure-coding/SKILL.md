---
name: security-secure-coding
description: 'Preventing OWASP Top 10, input validation, secure-by-default design. Trigger: "prevent SQL injection", "secure coding checklist", "XSS prevention".'
metadata:
  category: security
  tags: "security, owasp, input-validation, secure-by-default, injection"
---

# Security: Secure Coding

## Purpose

Eliminates vulnerabilities at the source code level. It reviews and fixes application code for injection, validation, encoding, and privilege flaws within the named scope; it does NOT configure networks, WAFs, secrets stores, or dependency scanners.

## When to Use / When NOT to Use

- **Use**: Writing new features, security reviews, handling PII.
- **NOT**: Network firewall rules or WAF configuration.
- **NOT**: Secret storage and rotation (use `security-secrets-management`).
- **NOT**: CVE and SBOM scanning (use `security-dependency-scanning`).
- **NOT**: Go-specific audits with gosec/govulncheck (use `golang-audit-security`).

## Prerequisites & Assumptions

- OWASP Top 10 knowledge.

### Scope & Context Resolution

- **Supported scopes**: function/method, file, directory/module, endpoint/handler, project/repository. Default when none is given: the code snippet or files presented in the prompt.
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, constraints, versions, targets, and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow, and rules as the sole context at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits are limited to security fixes in the named scope. Vulnerabilities found outside it are reported as notes only.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Validate all inputs at trust boundaries within the scope.
3. Use parameterized queries (never string concat).
4. Encode outputs based on context (HTML, JS, SQL).
5. Enforce least privilege for DB/App users.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Use parameterized queries (ORM or prepared statements).
- **MUST**: Validate inputs strictly (allowlists over denylists).
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use vetted crypto libraries (never roll own crypto).
- **MUST NOT**: Trust client-side validation alone.
- **MUST NOT**: Silently skip a vulnerability found in scope, or "fix" unrelated code to do so; flag it instead.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `db.Query("SELECT * FROM users WHERE id = " + id)`
- **Good**: `db.Query("SELECT * FROM users WHERE id = ?", id)`

**Scope handling**

- **Prompt**: "Fix the injection risk in `GetUser` only."
- **Good**: Parameterizes the query in `GetUser`; notes that `ListUsers` concatenates input too.
- **Bad**: Rewrites the whole data layer and swaps the ORM.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Inputs validated.
- [ ] Parameterized queries used.
- [ ] Output encoded.

## Common Pitfalls

- Security by obscurity.
- Custom cryptography implementations.
- Scope creep: rewriting the data layer when asked to fix one injection flaw.

## References (official docs, standards)

- [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
