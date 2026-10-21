---
name: replify-strchain
description: 'Enforces fluent, chainable string building and indentation management using replify/pkg/strchain. Trigger: "use strchain", "string builder replify", "indentation management", "migrate strings.Builder".'
metadata:
  category: ecosystem-replify
  tags: "replify, golang, strings, fluent-api, string-builder"
---

# replify/strchain: Fluent String Building & Indentation

## Purpose

Replaces `strings.Builder` and manual string concatenation with `strchain` for readable, thread-safe, and strictly formatted string generation, especially for code, HTML, SQL, or configuration files.

## When to Use / When NOT to Use

- **Use**: Generating multi-line text, code generation, SQL building, or HTML where indentation and layout matter.
- **NOT**: Simple single-line messages (use `fmt.Sprintf` or `strutil.Join`).

## Prerequisites & Assumptions

- `github.com/polarixa/replify/pkg/strchain` imported.

## Step-by-Step Workflow

1. Initialize with `strchain.New()` (single-goroutine) or `strchain.NewSafe()` (concurrent).
2. Use `.Append()`, `.Line()`, `.LineF()` for content addition.
3. Use `.Indent(level, text)` or `.Spaces(n)` for strict whitespace management.
4. Call `.Build()` or `.Bytes()` or `.String()` to finalize the output.

## Enterprise Rules & Standards

- **MUST**: Eliminate all `strings.Builder` in favor of `strchain.Weaver` interface.
- **MUST**: Never hardcode leading spaces or tabs in string literals; use `.Indent()` or `.Spaces()` exclusively.
- **SHOULD**: Use `strchain.C(s)` to transform existing strings fluently without creating a new weaver.
- **MUST NOT**: Use `s = s + "..."` in loops or complex formatting logic.

## Examples

- **Bad**: `b.WriteString("  <div>\n")` (Hardcoded indentation)
- **Good**: `weaver.IndentLine(1, "<div>")` (Managed indentation)

## Checklist

- [ ] `strings.Builder` completely removed from codebase.
- [ ] Hardcoded indentation replaced with `.Indent()` or `.Spaces()`.
- [ ] Thread-safe weaver (`NewSafe`) used if shared across goroutines.

## Common Pitfalls

- Using the non-thread-safe `StringWeaver` in concurrent HTTP handlers.
- Forgetting to call `.Build()` or `.String()` to materialize the final string.

## References

- `github.com/polarixa/replify/pkg/strchain` Migration Guide
