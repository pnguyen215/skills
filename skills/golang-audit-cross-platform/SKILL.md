---
name: golang-audit-cross-platform
description: 'Audits Go code for cross-platform compatibility (Linux/Windows/macOS), concurrency safety, and resource efficiency. Trigger: "cross-platform Go audit", "fix Windows path issues Go", "go:build tags", "data race audit".'
metadata:
  category: language-specific
  tags: "golang, audit, cross-platform, concurrency, resource-safety"
---

# Go Audit: Cross-Platform & Concurrency Safety

## Purpose

Conducts a strict technical audit focused on runtime stability across OS boundaries (Linux, Windows, macOS), identifying non-portable syscalls, path parsing errors, and concurrency hazards (data races, deadlocks). This skill audits and reports; it edits code only for portability and concurrency fixes inside the resolved scope, and does NOT perform security, GoDoc, or general refactoring work.

## When to Use / When NOT to Use

- **Use**: CLI tools distributed to multiple OSs, agents running on diverse infrastructure, fixing "works on my machine" bugs.
- **NOT**: Linux-only containerized microservices that will never run on Windows/macOS.
- **NOT**: Vulnerability/crypto/injection audits (use `golang-audit-security`).
- **NOT**: Documentation comments (use `golang-audit-godoc-coverage`).
- **NOT**: Deep CPU/memory profiling (use `performance-profiling`).

## Prerequisites & Assumptions

- Go toolchain installed for target platforms (`GOOS=windows`, `GOOS=darwin`).

### Scope & Context Resolution

- **Supported scopes**: repository/module, directory/package, file, function/method. Default: the Go module in the working directory.
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, constraints, Go versions, target platforms and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them (e.g., audit only the named OS targets). If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at the default scope, targeting Linux, Windows and macOS. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Findings are reported first; edits limited to portability/concurrency fixes (and `//go:build` file splits) inside the resolved scope. MUST NOT change public APIs or unrelated logic.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply Scope & Context Resolution; state the resolved scope and mutation boundary in one line at the start of the output.
2. **Compatibility Audit**: Scan the scope for hardcoded path separators (`/`), OS-specific syscalls, and locale-dependent string operations.
3. **Safety Report**: Run `go vet` and race detector analysis to find deadlocks, nil-pointer escapes, and slice bounds risks.
4. **Performance Analysis**: Identify heap allocation hotspots and sub-optimal I/O buffering.
5. **Abstraction Strategy**: Implement `//go:build` tags to isolate platform-specific code.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Use `filepath.Join` and `filepath.Separator` for all filesystem paths; NEVER hardcode `/` or `\`.
- **MUST**: Use `//go:build` constraints to abstract OS-specific syscalls (e.g., `file_windows.go` vs `file_unix.go`).
- **MUST**: Wrap all errors with `fmt.Errorf("context: %w", err)` to preserve the chain across platform boundaries.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST NOT**: Use `os.Executable()` without handling platform-specific path resolution edge cases.
- **MUST NOT**: Rely on `/tmp` directly; use `os.TempDir()`.
- **MUST NOT**: Fix unrelated packages or restructure the build layout beyond the platform split the audit requires.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `path := "/var/log/app/" + name + ".log"` (Fails on Windows)
- **Good**: `path := filepath.Join(os.TempDir(), "app", name+".log")`
- **Good (scoped)**: Prompt "audit only `internal/store/files.go` for Windows" -> fix path joins in that file, report a hardcoded `/tmp` in `cmd/` as a note.
- **Bad (scope-expanding)**: Same prompt -> rewrite path handling across every package and add macOS build tags.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] `filepath` used exclusively for paths.
- [ ] `//go:build` tags applied to platform-specific files.
- [ ] Race detector (`-race`) passes on all target OS architectures.
- [ ] No hardcoded `/tmp` or `/var` paths.

## Common Pitfalls

- Assuming case-sensitivity in filesystem paths (Windows is case-insensitive, Linux is case-sensitive).
- Forgetting to handle CRLF (`\r\n`) vs LF (`\n`) line endings when parsing text files across platforms.
- Scope creep: auditing and rewriting the whole module when asked about one package.

## References (official docs, standards)

- [Go Build Constraints Documentation](https://pkg.go.dev/cmd/go#hdr-Build_constraints)
- [Go Data Race Detector](https://go.dev/doc/articles/race_detector)
- [`path/filepath` package](https://pkg.go.dev/path/filepath)
