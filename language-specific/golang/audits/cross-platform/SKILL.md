---
name: cross-platform
description: 'Audits Go code for cross-platform compatibility (Linux/Windows/macOS), concurrency safety, and resource efficiency. Trigger: "cross-platform Go audit", "fix Windows path issues Go", "go:build tags", "data race audit".'
---

# Go Audit: Cross-Platform & Concurrency Safety

## Purpose

Conducts a strict technical audit focused on runtime stability across OS boundaries (Linux, Windows, macOS), identifying non-portable syscalls, path parsing errors, and concurrency hazards (data races, deadlocks).

## When to Use / When NOT to Use

- **Use**: CLI tools distributed to multiple OSs, agents running on diverse infrastructure, fixing "works on my machine" bugs.
- **NOT**: Linux-only containerized microservices that will never run on Windows/macOS.

## Prerequisites & Assumptions

- Go toolchain installed for target platforms (`GOOS=windows`, `GOOS=darwin`).

## Step-by-Step Workflow

1. **Compatibility Audit**: Scan for hardcoded path separators (`/`), OS-specific syscalls, and locale-dependent string operations.
2. **Safety Report**: Run `go vet` and race detector analysis to find deadlocks, nil-pointer escapes, and slice bounds risks.
3. **Performance Analysis**: Identify heap allocation hotspots and sub-optimal I/O buffering.
4. **Abstraction Strategy**: Implement `//go:build` tags to isolate platform-specific code.

## Enterprise Rules & Standards

- **MUST**: Use `filepath.Join` and `filepath.Separator` for all filesystem paths; NEVER hardcode `/` or `\`.
- **MUST**: Use `//go:build` constraints to abstract OS-specific syscalls (e.g., `file_windows.go` vs `file_unix.go`).
- **MUST**: Wrap all errors with `fmt.Errorf("context: %w", err)` to preserve the chain across platform boundaries.
- **MUST NOT**: Use `os.Executable()` without handling platform-specific path resolution edge cases.
- **MUST NOT**: Rely on `/tmp` directly; use `os.TempDir()`.

## Examples

- **Bad**: `path := "/var/log/app/" + name + ".log"` (Fails on Windows)
- **Good**: `path := filepath.Join(os.TempDir(), "app", name+".log")`

## Checklist

- [ ] `filepath` used exclusively for paths.
- [ ] `//go:build` tags applied to platform-specific files.
- [ ] Race detector (`-race`) passes on all target OS architectures.
- [ ] No hardcoded `/tmp` or `/var` paths.

## Common Pitfalls

- Assuming case-sensitivity in filesystem paths (Windows is case-insensitive, Linux is case-sensitive).
- Forgetting to handle CRLF (`\r\n`) vs LF (`\n`) line endings when parsing text files across platforms.

## References

- [Go Build Constraints Documentation](https://pkg.go.dev/cmd/go#hdr-Build_constraints)
