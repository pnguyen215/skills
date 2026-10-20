---
name: security-dependency-scanning
description: 'SBOM generation, CVE scanning (Trivy, Dependabot), license compliance. Trigger: "setup dependency scanning", "generate SBOM", "check CVEs".'
metadata:
  category: security
---

# Security: Dependency Scanning

## Purpose

Prevents using vulnerable or non-compliant third-party libraries.

## When to Use / When NOT to Use

- **Use**: CI pipelines, compliance audits, release sign-off.
- **NOT**: Internal proprietary code analysis.

## Prerequisites & Assumptions

- Dependency manifest (`go.mod`, `package.json`, `pom.xml`).

## Step-by-Step Workflow

1. Generate SBOM (CycloneDX/SPDX) on build.
2. Scan for CVEs (Trivy, Dependabot, Snyk).
3. Check licenses against allowlist.
4. Block build on Critical/High CVEs.

## Enterprise Rules & Standards

- **MUST**: Scan on every PR and nightly on `main`.
- **MUST**: Generate SBOM for all production releases.
- **SHOULD**: Auto-update minor/patch deps via Renovate/Dependabot.
- **MUST NOT**: Ignore Critical CVEs with known exploits.

## Examples

- **Bad**: Merging PR with vulnerable `log4j` version.
- **Good**: Trivy fails build on `CVE-2021-44228`.

## Checklist

- [ ] SBOM generated.
- [ ] CVE scan active in CI.
- [ ] Licenses checked.

## Common Pitfalls

- Alert fatigue leading to ignored warnings.
- False positives blocking releases.

## References

- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
