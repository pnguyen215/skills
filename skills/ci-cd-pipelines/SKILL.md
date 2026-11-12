---
name: ci-cd-pipelines
description: 'Design CI/CD pipelines with GitHub Actions/GitLab CI, matrix builds, caching. Trigger: "build CI pipeline", "setup GitHub Actions", "optimize CI".'
metadata:
  category: ci-cd
  tags: "ci-cd, github-actions, gitlab-ci, matrix-builds, caching"
---

# CI/CD Pipelines

## Purpose

Automates build, test, and deployment workflows securely and efficiently. This skill designs and edits pipeline definition files only; it does NOT change application code, enforce quality thresholds, or manage releases.

## When to Use / When NOT to Use

- **Use**: Setting up new repositories, optimizing build times, configuring matrix testing.
- **NOT**: Manual ad-hoc deployments or local testing only.
- **NOT**: Coverage/lint/Sonar gate configuration (use `ci-cd-quality-gates`).
- **NOT**: Versioning, changelogs, or package publishing (use `ci-cd-release-management`).
- **NOT**: Vault or secret-rotation design (use `security-secrets-management`).

## Prerequisites & Assumptions

- Source control hosted on GitHub/GitLab.
- Containerized build environments (Docker).

### Scope & Context Resolution

- **Supported scopes**: repository (all pipeline files), a single pipeline file, a single job/stage/step, a reusable workflow. Default: the pipeline file(s) of the repository.
- **Rule 1 - Explicit context in the prompt**: The user's stated CI provider, runners, language versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules (e.g., plaintext secrets), which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to pipeline/CI configuration files inside the resolved scope. MUST NOT edit application source, infrastructure code, or cloud settings.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply Scope & Context Resolution; state the resolved scope and mutation boundary in one line at the start of the output.
2. Define triggers (push, PR, schedule).
3. Setup dependency caching.
4. Configure matrix builds for OS/Arch/Language versions.
5. Implement artifact signing and attestation (only for jobs within the resolved scope).

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Fail fast on lint/test errors.
- **MUST**: Cache dependencies to reduce build time.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use OIDC for cloud authentication (no long-lived secrets).
- **MUST NOT**: Store plaintext secrets in pipeline configs.
- **MUST NOT**: Rewrite an entire pipeline or touch unrelated jobs when asked about one job.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Hardcoding `AWS_ACCESS_KEY` in `.github/workflows/main.yml`.
- **Good**: Using `aws-actions/configure-aws-credentials` with OIDC.
- **Good (scoped)**: Prompt "add caching to the `test` job in `ci.yml` only" -> add a cache step to `test`; leave `build` and `deploy` untouched; note that `deploy` lacks OIDC.
- **Bad (scope-expanding)**: Same prompt -> restructure `ci.yml` into reusable workflows and add matrix builds to every job.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Matrix builds configured.
- [ ] Caching enabled.
- [ ] OIDC used for cloud auth.

## Common Pitfalls

- Unoptimized Docker builds (missing layer caching).
- Leaking secrets via CI logs.
- Scope creep: rewriting a whole pipeline when asked about one job.

## References (official docs, standards)

- [GitHub Actions Security Best Practices](https://securitylab.github.com/research/github-actions-preventing-pwn-requests/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
