---
name: security-secrets-management
description: 'HashiCorp Vault, AWS Secrets Manager, preventing hardcoded secrets. Trigger: "setup Vault", "remove hardcoded secrets", "rotate credentials".'
metadata:
  category: security
  tags: "security, secrets, vault, aws-secrets-manager, hardcoded-secrets"
---

# Security: Secrets Management

## Purpose

Secures credentials, API keys, and certificates. Responsibility boundary: finds hardcoded secrets and moves them to a secret manager within the named scope; does NOT rotate live credentials or access production secret stores unless the user explicitly asks.

## When to Use / When NOT to Use

- **Use**: App configuration, DB credentials, third-party API keys.
- **NOT**: Public config values (e.g., UI feature flags).
- **NOT**: Dependency CVE scanning or SBOMs (use `security-dependency-scanning`).
- **NOT**: General OWASP/input-validation hardening (use `security-secure-coding`).

## Prerequisites & Assumptions

- Secret manager (Vault, AWS SM, GCP Secret Manager).

### Scope & Context Resolution

- **Supported scopes**: project/repository, directory/module, file, config or deployment manifest, secret-manager policy. Default when none is given: all source and config files of the project (read for detection; edits only where a secret is found).
- **Rule 1 - Explicit context in the prompt**: the user's stated requirements, constraints, versions, targets (Vault vs AWS SM) and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules (no hardcoded or logged secrets), which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to secret references and secret-manager config in the resolved scope; MUST NOT print, copy or commit real secret values, and MUST NOT rotate or delete live secrets without approval.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Identify all secrets in code and configs within the resolved scope.
3. Move to Secret Manager.
4. Inject at runtime via env vars or CSI driver.
5. Enable automatic rotation.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Zero hardcoded secrets in source code.
- **MUST**: Use IAM/OIDC to access secrets (no long-lived access keys).
- **SHOULD**: Enable auto-rotation for DB passwords.
- **MUST NOT**: Log secret values or print to stdout.
- **MUST NOT**: Rotate, revoke or delete live secrets outside the named scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `password := "SuperSecret123"`
- **Good**: `password := os.Getenv("DB_PASSWORD")` (injected by Vault agent)

**Scope handling**

- **Prompt**: "Remove hardcoded secrets only in `config/db.go`."
- **Good**: Replaces the literals in that file with injected env vars; reports a key found in `deploy/ci.yml` as a note without masking the value.
- **Bad**: Edits every config file and rotates the production DB password.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] GitGuardian/pre-commit hooks active.
- [ ] Vault/SM integrated.
- [ ] Rotation enabled.

## Common Pitfalls

- Committing `.env` files to Git.
- Static, long-lived access keys.
- Rotating or rewriting secrets across environments when one file was in scope.

## References (official docs, standards)

- [HashiCorp Vault](https://www.vaultproject.io/)
- [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
- [GCP Secret Manager](https://cloud.google.com/secret-manager)
