---
name: security-secrets-management
description: 'HashiCorp Vault, AWS Secrets Manager, preventing hardcoded secrets. Trigger: "setup Vault", "remove hardcoded secrets", "rotate credentials".'
metadata:
  category: security
---

# Security: Secrets Management

## Purpose

Secures credentials, API keys, and certificates.

## When to Use / When NOT to Use

- **Use**: App configuration, DB credentials, third-party API keys.
- **NOT**: Public config values (e.g., UI feature flags).

## Prerequisites & Assumptions

- Secret manager (Vault, AWS SM, GCP Secret Manager).

## Step-by-Step Workflow

1. Identify all secrets in code and configs.
2. Move to Secret Manager.
3. Inject at runtime via env vars or CSI driver.
4. Enable automatic rotation.

## Enterprise Rules & Standards

- **MUST**: Zero hardcoded secrets in source code.
- **MUST**: Use IAM/OIDC to access secrets (no long-lived access keys).
- **SHOULD**: Enable auto-rotation for DB passwords.
- **MUST NOT**: Log secret values or print to stdout.

## Examples

- **Bad**: `password := "SuperSecret123"`
- **Good**: `password := os.Getenv("DB_PASSWORD")` (injected by Vault agent)

## Checklist

- [ ] GitGuardian/pre-commit hooks active.
- [ ] Vault/SM integrated.
- [ ] Rotation enabled.

## Common Pitfalls

- Committing `.env` files to Git.
- Static, long-lived access keys.

## References

- [HashiCorp Vault](https://www.vaultproject.io/)
- [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
- [GCP Secret Manager](https://cloud.google.com/secret-manager)
