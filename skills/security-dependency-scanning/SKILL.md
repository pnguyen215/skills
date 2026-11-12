---
name: security-dependency-scanning
description: 'SBOM generation, CVE scanning (Trivy, Dependabot), license compliance. Trigger: "setup dependency scanning", "generate SBOM", "check CVEs".'
metadata:
  category: security
  tags: "security, sbom, cve, trivy, dependabot, license-compliance"
---

# Security: Dependency Scanning

## Purpose

Prevents using vulnerable or non-compliant third-party libraries. Responsibility boundary: configures and interprets SBOM, CVE and license scans; does NOT audit first-party source code and does NOT upgrade dependencies unless asked.

## When to Use / When NOT to Use

- **Use**: CI pipelines, compliance audits, release sign-off.
- **NOT**: Internal proprietary code analysis.
- **NOT**: Go source-level vulnerability audit (use `golang-audit-security`).
- **NOT**: Secret storage or rotation (use `security-secrets-management`).
- **NOT**: OWASP-style code hardening (use `security-secure-coding`).

## Prerequisites & Assumptions

- Dependency manifest (`go.mod`, `package.json`, `pom.xml`).

### Scope & Context Resolution

- **Supported scopes**: repository (default), single manifest/module, container image, CI scan job, SBOM file, license policy.
- **Rule 1 - Explicit context**: The user's stated requirements, constraints, versions, targets and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line. Security/data-loss rules (e.g. Critical CVEs with known exploits) stay mandatory; flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at repository scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to scan configuration and CI scan steps in scope. MUST NOT bump dependency versions or alter manifests unless asked.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Generate SBOM (CycloneDX/SPDX) on build.
3. Scan for CVEs (Trivy, Dependabot, Snyk).
4. Check licenses against allowlist.
5. Block build on Critical/High CVEs.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Scan on every PR and nightly on `main`.
- **MUST**: Generate SBOM for all production releases.
- **SHOULD**: Auto-update minor/patch deps via Renovate/Dependabot.
- **MUST NOT**: Ignore Critical CVEs with known exploits.
- **MUST NOT**: Upgrade dependencies or edit manifests outside the requested scope while remediating findings.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: Merging PR with vulnerable `log4j` version.
- **Good**: Trivy fails build on `CVE-2021-44228`.
- **Scope - Good**: Prompt "only the `payments` image" -> scan that image and report its CVEs; note a vulnerable `orders` dependency without changing it.
- **Scope - Bad**: Same prompt -> bumping dependencies across all services.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] SBOM generated.
- [ ] CVE scan active in CI.
- [ ] Licenses checked.

## Common Pitfalls

- Alert fatigue leading to ignored warnings.
- False positives blocking releases.
- Mass-upgrading every dependency when one finding was requested.

## References (official docs, standards)

- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
- [CycloneDX](https://cyclonedx.org/)
- [SPDX](https://spdx.dev/)
- [Trivy](https://trivy.dev/)
