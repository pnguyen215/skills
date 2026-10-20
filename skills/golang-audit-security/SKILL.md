---
name: golang-audit-security
description: 'Audits Go code for common security vulnerabilities (injection, unsafe deserialization, weak crypto, secret handling) and enforces govulncheck/gosec-backed remediation. Trigger: "security audit Go code", "run gosec", "check govulncheck", "Go CVE audit", "harden Go handler".'
metadata:
  category: language-specific
---

# Go Audit: Security

## Purpose

Finds and remediates security weaknesses in Go code before they reach production: unsafe
input handling, weak cryptography, leaked secrets, unchecked deserialization, and vulnerable
dependencies.

## When to Use / When NOT to Use

- **Use**: Before a release, during a PR touching auth/crypto/parsing/network-input code, or
  when asked to "security review" or "audit" a Go package.
- **NOT**: For non-Go code, for dependency licensing questions (see `security-dependency-scanning`),
  or as a substitute for a full threat model / pentest.

## Prerequisites & Assumptions

- Go toolchain installed (`go version`).
- `gosec` and `govulncheck` available or installable (`go install github.com/securego/gosec/v2/cmd/gosec@latest`,
  `go install golang.org/x/vuln/cmd/govulncheck@latest`).
- Read access to `go.mod`/`go.sum` to resolve the dependency graph.

## Step-by-Step Workflow

1. Run `govulncheck ./...` to find known CVEs reachable from the code (not just listed in `go.sum`).
2. Run `gosec ./...` for static security findings (SQL injection, command injection, weak RNG,
   hardcoded credentials, unsafe `tls.Config`, path traversal).
3. Triage findings: reachable + exploitable first, informational last. Never silently add
   `#nosec` to suppress a finding without a documented justification comment.
4. Review `crypto/*` usage: reject `md5`/`sha1` for anything security-sensitive, reject a nil or
   `InsecureSkipVerify: true` TLS config, require `crypto/rand` (never `math/rand`) for tokens,
   keys, and nonces.
5. Review input handling: confirm `database/sql` queries use parameter placeholders (no string
   concatenation), confirm `os/exec` calls don't interpolate untrusted input into the command,
   confirm file paths from user input are cleaned and checked against a base directory
   (`filepath.Clean` + prefix check) before use.
6. Review secret handling: no secrets in source, log statements, or error messages; secrets
   loaded from env vars or a secrets manager; `fmt.Sprintf`/`%v` never used to print a struct
   that embeds a credential — implement `String()`/`GoStringer` to redact it instead.
7. Review deserialization: `encoding/gob`, `encoding/json`, and especially
   `encoding/xml`/XXE-prone parsers only decode into bounded, typed structs; reject
   `interface{}`-typed decode targets for untrusted input.
8. Summarize findings as a checklist with severity, file:line, and a concrete fix per item.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST** run `govulncheck` and `gosec` in CI on every PR that touches `.go` files; fail the
  build on any high/critical finding.
- **MUST** use `crypto/rand` for any token, session ID, API key, or nonce.
- **MUST NOT** build SQL, shell commands, or file paths via string concatenation with untrusted
  input.
- **MUST NOT** disable TLS verification (`InsecureSkipVerify: true`) outside of local test code
  gated by a build tag.
- **SHOULD** store secrets via an external secrets manager (Vault, AWS Secrets Manager) rather
  than environment variables where the platform allows it; see `security-secrets-management`.
- **SHOULD** pin dependency versions and re-run `govulncheck` on every dependency bump.

## Examples (good vs. bad, with realistic code or output)

```go
// BAD: string-built SQL query, unsafe interpolation
query := "SELECT * FROM users WHERE email = '" + email + "'"
db.Query(query)

// GOOD: parameterized query
db.Query("SELECT * FROM users WHERE email = $1", email)
```

```go
// BAD: predictable token generation
token := fmt.Sprintf("%d", time.Now().UnixNano())

// GOOD: cryptographically secure token
buf := make([]byte, 32)
if _, err := crypto_rand.Read(buf); err != nil {
    return "", err
}
token := base64.URLEncoding.EncodeToString(buf)
```

## Checklist (verifiable, copy-pasteable)

- [ ] `govulncheck ./...` passes with no reachable high/critical CVEs.
- [ ] `gosec ./...` passes, or every suppression has a `#nosec G1xx -- reason` comment.
- [ ] No `math/rand` used for tokens, keys, nonces, or session IDs.
- [ ] No string-concatenated SQL, shell commands, or file paths built from untrusted input.
- [ ] No `InsecureSkipVerify: true` outside test-only, build-tagged code.
- [ ] No secrets in source, logs, or error strings.
- [ ] Untrusted deserialization targets are typed structs, not `interface{}`/`any`.

## Common Pitfalls

- Suppressing a `gosec` finding with `#nosec` and no justification, hiding a real issue later.
- Treating `govulncheck` dependency-only mode as sufficient; always use the call-graph mode
  (`govulncheck ./...`) which filters to reachable vulnerabilities.
- Rotating a leaked secret without also revoking the old one and auditing its usage window.

## References (official docs, standards)

- [govulncheck](https://go.dev/security/vulncheck)
- [gosec](https://github.com/securego/gosec)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Go crypto/rand vs math/rand](https://pkg.go.dev/crypto/rand)
