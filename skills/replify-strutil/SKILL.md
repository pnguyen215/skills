---
name: replify-strutil
description: 'Standardizes string manipulation, validation, and transformation using replify/pkg/strutil. Trigger: "string manipulation replify", "slugify string", "use strutil", "string validation".'
metadata:
  category: ecosystem-replify
---

# replify/strutil: Comprehensive String Utilities

## Purpose

Eliminates boilerplate and edge-case bugs in string handling by leveraging the comprehensive, well-tested `strutil` API for validation, transformation, and formatting.

## When to Use / When NOT to Use

- **Use**: URL slug generation, input validation (`IsEmpty`, `IsAlpha`), safe trimming, and display formatting (`Truncate`).
- **NOT**: High-performance binary parsing, byte-level operations, or hot-loop string concatenation (use `strchain` or `strings.Builder`).

## Prerequisites & Assumptions

- `github.com/polarixa/replify/pkg/strutil` imported.

## Step-by-Step Workflow

1. Replace custom regex or `strings.*` boilerplate with `strutil` equivalents.
2. Use `strutil.Slugify` for generating URL-friendly keys from user input.
3. Use `strutil.Truncate` with ellipsis for UI/display strings to prevent layout breaking.
4. Use `strutil.DefaultIfBlank` for safe fallback values.

## Enterprise Rules & Standards

- **MUST**: Use `strutil.IsEmpty` or `strutil.IsBlank` instead of `s == ""` or `len(s) == 0` to correctly handle whitespace-only inputs.
- **MUST**: Use `strutil.Slugify` for generating URL routes or resource identifiers from human-readable titles.
- **SHOULD**: Use `strutil.DefaultIfEmpty` for fallback values instead of manual `if/else` blocks.
- **MUST NOT**: Re-implement functions like `Capitalize`, `Strip`, `Chomp`, or `Truncate` locally within the codebase.

## Examples

- **Bad**: `if len(strings.TrimSpace(s)) == 0 { s = "default" }`
- **Good**: `s = strutil.DefaultIfBlank(s, "default")`

## Checklist

- [ ] Replaced manual string checks with `strutil` validators.
- [ ] `Slugify` used for all URL/resource keys.
- [ ] No custom string utility functions exist in the project.

## Common Pitfalls

- Confusing `IsEmpty` (checks length) with `IsBlank` (checks whitespace).
- Using `Truncate` without considering UTF-8 rune boundaries (though `strutil` handles this safely).

## References

- `github.com/polarixa/replify/pkg/strutil` API Documentation
