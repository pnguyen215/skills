---
name: ci-cd-pipelines
description: 'Design CI/CD pipelines with GitHub Actions/GitLab CI, matrix builds, caching. Trigger: "build CI pipeline", "setup GitHub Actions", "optimize CI".'
metadata:
  category: ci-cd
---

# CI/CD Pipelines

## Purpose

Automates build, test, and deployment workflows securely and efficiently.

## When to Use / When NOT to Use

- **Use**: Setting up new repositories, optimizing build times, configuring matrix testing.
- **NOT**: Manual ad-hoc deployments or local testing only.

## Prerequisites & Assumptions

- Source control hosted on GitHub/GitLab.
- Containerized build environments (Docker).

## Step-by-Step Workflow

1. Define triggers (push, PR, schedule).
2. Setup dependency caching.
3. Configure matrix builds for OS/Arch/Language versions.
4. Implement artifact signing and attestation.

## Enterprise Rules & Standards

- **MUST**: Fail fast on lint/test errors.
- **MUST**: Cache dependencies to reduce build time.
- **SHOULD**: Use OIDC for cloud authentication (no long-lived secrets).
- **MUST NOT**: Store plaintext secrets in pipeline configs.

## Examples

- **Bad**: Hardcoding `AWS_ACCESS_KEY` in `.github/workflows/main.yml`.
- **Good**: Using `aws-actions/configure-aws-credentials` with OIDC.

## Checklist

- [ ] Matrix builds configured.
- [ ] Caching enabled.
- [ ] OIDC used for cloud auth.

## Common Pitfalls

- Unoptimized Docker builds (missing layer caching).
- Leaking secrets via CI logs.

## References

- [GitHub Actions Security Best Practices](https://securitylab.github.com/research/github-actions-preventing-pwn-requests/)
