---
name: replify-go-encapsulation
description: 'Enforces extreme struct encapsulation, nil-receiver safety, and defensive copying in Go. Trigger: "encapsulate struct", "defensive copy Go", "nil-safe getter", "refactor struct encapsulation".'
metadata:
  category: ecosystem-replify
---

# Go: Extreme Struct Encapsulation

## Purpose

Guarantees memory safety and airtight API boundaries by preventing external mutation of internal state and handling nil pointers gracefully, based on strict enterprise refactoring rules.

## When to Use / When NOT to Use

- **Use**: All domain models, public DTOs, configuration structs, and library APIs.
- **NOT**: Simple internal loop variables or pure data-transfer structs within a single trusted package boundary where performance is absolutely critical.

## Prerequisites & Assumptions

- Go standard library.
- Willingness to generate or write verbose accessor methods.

## Step-by-Step Workflow

1. Make all struct fields unexported (lowercase).
2. Generate Getters with nil-receiver guards (`if s == nil { return zero }`).
3. Generate Setters that perform defensive copies for slices/maps.
4. Add targeted mutators (`AddX`, `RemoveX`) for collections instead of exposing the slice.

## Enterprise Rules & Standards

- **MUST**: All struct fields MUST be unexported (lowercase) without exception.
- **MUST**: Every pointer-receiver Getter MUST implement a nil guard to prevent panics on uninitialized pointers.
- **MUST**: Slices, maps, and pointers MUST be deep-copied in Getters/Setters to prevent external mutation of internal state.
- **MUST NOT**: Expose internal slices/maps directly via Getters (e.g., `func (u *User) Tags() []string`).

## Examples

- **Bad**: `func (u *User) Tags() []string { return u.tags }` (Leaks reference, allows external mutation)
- **Good**: `func (u *User) Tags() []string { if u == nil { return nil }; c := make([]string, len(u.tags)); copy(c, u.tags); return c }`

## Checklist

- [ ] All fields unexported.
- [ ] Nil guards present on all pointer-receiver getters.
- [ ] Defensive copies implemented for slices/maps.
- [ ] Targeted mutators (`AddTag`, `RemoveTag`) created.

## Common Pitfalls

- Forgetting to copy the slice in the Setter, allowing the caller to modify the original slice after passing it in.
- Over-encapsulating simple internal structs, leading to unnecessary boilerplate.
