---
name: replify-response-wrapping
description: 'Enforces that every Go function with outputs (1, 2 or N return values) includes a *replify.R among them, carrying the status, message, body and error. Trigger: "every function must return *replify.R", "wrap output in replify.R", "add *replify.R to return values", "standardize function results with replify".'
metadata:
  category: ecosystem-replify
  tags: "replify, golang, response-wrapping, error-handling, refactoring"
---

# Replify: Every Function Output Includes `*replify.R`

## Purpose

Makes every function in scope return a `*replify.R` envelope as one of its outputs. A function may have 1, 2 or N return values; whatever the shape, exactly one of them is `*replify.R`, carrying the status code, message, body, error chain and optional pagination/metadata. Responsibility boundary: edits the signatures, return statements and direct call sites of functions in the named scope; does NOT redesign option/setter APIs (`replify-go-api-design`), struct encapsulation (`replify-go-encapsulation`) or logging (`replify-slogger`).

## When to Use / When NOT to Use

- **Use**: Service, repository, usecase and handler-layer functions of a Go project that adopts `github.com/polarixa/replify`.
- **Use**: New code in such a project: every new function with outputs includes a `*replify.R`.
- **NOT**: Functions whose signature is dictated by the language or a framework (see "Allowed exceptions").
- **NOT**: GraphQL, gRPC or WebSocket handlers, where the wire format is fixed by the protocol.
- **NOT**: Performance-critical hot paths where the extra allocation is measured as unacceptable; report instead of changing.
- **NOT**: Choosing between functional options and setters (use `replify-go-api-design`).

## Prerequisites & Assumptions

- Go 1.24+ and `go get github.com/polarixa/replify@latest` (import path `github.com/polarixa/replify`).
- `replify.New()` returns an **unexported** `*wrapper`, so its type can never appear in a signature. The nameable envelope type is `replify.R`, and the pointer form `*replify.R` comes from `.ReplyPtr()`. Never write `var r *replify.R = replify.New()...` (it does not compile); end every chain with `.ReplyPtr()`.
- The body is stored as `any`; read it back with `r.Body()` or `r.JSONBodyCast(&v)`.

### Scope & Context Resolution

- **Supported scopes**: project/repository, package, file, function/method. Default when none is given: the function(s) or file the user names; if none is named, ask which scope to convert instead of rewriting the whole project.
- **Rule 1 - Explicit context in the prompt**: the user's stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules (never leak internal error detail or secrets into the envelope), which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to functions in scope, their tests, and the minimal call-site updates needed to compile. Call sites outside the scope MUST be listed and approved before editing.

## Step-by-Step Workflow

1. **Resolve scope and context**: state the resolved scope and mutation boundary in one line at the start of the output.
2. **Inventory**: list every function and method in scope with its current return signature. Classify each as _convert_, _already compliant_ or _allowed exception_ (below). Record all call sites.
3. **Shape the signature**: keep every existing output and append one `*replify.R` as the **last** output (after `error` too):
   - no outputs: `func F()` becomes `func F() *replify.R`
   - 1 output: `func F() T` becomes `func F() (T, *replify.R)`
   - 2 outputs: `func F() (T, error)` becomes `func F() (T, error, *replify.R)`
   - N outputs: `func F() (A, B, C)` becomes `func F() (A, B, C, *replify.R)`

   Position is fixed: `*replify.R` is always the last element of the output list, after `error` too. Note: this deliberately departs from the Go convention of `error` last, so linters such as `staticcheck` ST1008 may warn; report it, do not reorder.

4. **Wrap every return path**: every `return` supplies a non-nil `*replify.R` plus the other outputs.
   - Success with data: `replify.WrapOk("<message>", data).ReplyPtr()` or `replify.New().OK().WithBody(data).WithMessage("...").ReplyPtr()`, returned with the real values (envelope last).
   - Created / no content / accepted: `WrapCreated`, `WrapNoContent`, `WrapAccepted` (or `.Created()`, `.NoContent()`, `.Accepted()`), then `.ReplyPtr()`.
   - Failure: `replify.New().<Status>().WithErrorAck(err).WithMessage("...").ReplyPtr()`, with the status matching the cause (`BadRequest`, `NotFound`, `InternalServerError`, ...). Return the zero value for the other outputs, and return the same `err` in the `error` output if the signature keeps one.
   - Void functions: return `replify.WrapNoContent("", nil).ReplyPtr()` or an `OK()` envelope so success is still observable.
   - Lists: add `WithPagination(replify.FromPages(total, perPage))` and `WithTotal(n)` when the data is paged.
5. **Keep outputs consistent with the envelope**: when the function returns both a value and the envelope, the value should equal `r.Body()` (or be what the body was built from), and the `error` output must be nil exactly when `r.IsSuccess()`.
6. **Propagate**: when function A calls function B (also compliant), check `r.IsError()` / `IsSuccess()` on B's envelope, then return B's `*replify.R` unchanged or re-wrap the original cause with `AppendError(cause, "context")`. Do not rebuild it from `errors.New(r.Error())`.
7. **Update tests and call sites**: destructure the new output (`user, err, r := FindUser(id)`) and assert on `r.IsSuccess()`, `r.StatusCode()`, `r.Body()` and `r.Error()` as well as the original values.
8. **Verify**: `gofmt -l`, `go build ./...`, `go vet ./...`, `go test` for the affected packages. Grep the scope for converted functions still missing `*replify.R` and for `return` statements passing `nil` as the envelope.

## Allowed exceptions (keep the original signature, list each one in the report)

- `main`, `init`, `TestXxx`, `BenchmarkXxx`, `ExampleXxx`, `FuzzXxx`.
- Methods that satisfy a standard or third-party interface: `String`, `Error`, `Write`, `Read`, `Close`, `ServeHTTP`, `Less/Len/Swap`, `MarshalJSON`/`UnmarshalJSON`, `Scan`/`Value`, middleware `func(http.Handler) http.Handler`, framework handler signatures (e.g. `gin.HandlerFunc`).
- Callbacks passed to a library with a fixed signature (e.g. a `sort.Slice` less func, `http.HandlerFunc`).
- Functions with no outputs when the user's scope says "functions that have output"; otherwise convert them (void functions return just `*replify.R`).
- Constructors/factories and trivial accessors are a **user decision**: default to converting them when the user said "every function", and state the choice in one line.

For an exception that still computes a result, keep the signature and build the envelope in the nearest caller layer instead.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Every converted function has exactly one `*replify.R` among its 1, 2 or N outputs, on every code path including early returns and recovered panics.
- **MUST**: Preserve every original output (type, order, meaning); only append the envelope as the last output.
- **MUST**: Build the envelope through `.ReplyPtr()`; MUST NOT declare variables as the unexported wrapper type.
- **MUST**: Return a non-nil `*replify.R` on every path, including failures.
- **MUST**: Set a status that reflects the outcome (2xx success, 4xx caller faults, 5xx server faults); MUST NOT return an error envelope with status 200.
- **MUST**: Attach errors with `WithErrorAck`/`WithErrorAckf`/`AppendError*` so the cause chain and stack trace survive.
- **MUST**: Preserve behaviour: same data, same error causes, same side effects and ordering.
- **SHOULD**: Give every envelope a short, human-readable `WithMessage`.
- **SHOULD**: Use one message/status convention across the scope.
- **MUST NOT**: Return `nil`, a zero `replify.R{}` or a bare `replify.New()` envelope (`Processing` status) as the envelope.
- **MUST NOT**: Let the envelope and the other outputs disagree (success envelope with non-nil `error`, or error envelope with nil `error`).
- **MUST NOT**: Put secrets, raw SQL, internal paths or stack traces in the client-facing `message`; keep detail in the error chain/debugging fields and expose it only in non-production builds (`WithDebugging*`).
- **MUST NOT**: Panic to signal failure in converted functions.
- **MUST NOT**: Change exported function names, or edit call sites outside the scope without approval.

## Examples (good vs. bad, with realistic code or output)

**Bad**: no envelope.

```go
func FindUser(id string) (*User, error) {
    u, err := repo.Get(id)
    if err != nil {
        return nil, err
    }
    return u, nil
}
```

**Good**: 2 outputs become 3, `*replify.R` appended last.

```go
func FindUser(id string) (*User, error, *replify.R) {
    u, err := repo.Get(id)
    if err != nil {
        return nil, err, replify.New().
            NotFound().
            WithErrorAck(err).
            WithMessage("User not found").
            ReplyPtr()
    }
    return u, nil, replify.WrapOk("User retrieved successfully", u).ReplyPtr()
}
```

**1 output**:

```go
func Count() (int, *replify.R) {
    n := repo.Count()
    return n, replify.WrapOk("Counted", n).ReplyPtr()
}
```

**N outputs**:

```go
func Stats() (int, float64, bool, *replify.R) {
    a, b, c := compute()
    return a, b, c, replify.WrapOk("Stats ready", map[string]any{"a": a, "b": b, "c": c}).ReplyPtr()
}
```

**No outputs**:

```go
func Purge(id string) *replify.R {
    if err := repo.Delete(id); err != nil {
        return replify.New().InternalServerError().WithErrorAck(err).WithMessage("Purge failed").ReplyPtr()
    }
    return replify.WrapNoContent("Purged", nil).ReplyPtr()
}
```

**Propagating**:

```go
func ShowProfile(id string) (*Profile, *replify.R) {
    u, _, r := FindUser(id)
    if r.IsError() {
        return nil, r // propagate unchanged
    }
    p := buildProfile(u)
    return p, replify.WrapOk("Profile ready", p).ReplyPtr()
}
```

**Bad**: success envelope with an error, nil envelope, wrong status.

```go
func Save(u *User) (error, *replify.R) {
    if err := repo.Save(u); err != nil {
        return err, replify.New().OK().WithErrorAck(err).ReplyPtr() // 200 with an error
    }
    return nil, nil // nil envelope
}
```

**Scope handling**

- **Prompt**: "Convert only `internal/user/service.go`."
- **Good**: Converts every function in that file, updates its direct callers only if approved, and lists other packages' callers as notes.
- **Bad**: Converts the whole repository and rewrites all handlers.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and mutation boundary stated once.
- [ ] Inventory table lists every in-scope function: converted, already compliant, or exception with reason.
- [ ] Every converted function has exactly one `*replify.R` as its LAST output; all original outputs preserved in order.
- [ ] Every return path supplies a non-nil `*replify.R` built with `.ReplyPtr()`.
- [ ] Error envelopes carry a matching 4xx/5xx status and `WithErrorAck`/`AppendError*`; success envelopes use 2xx.
- [ ] `error` output and envelope agree (`error == nil` iff `IsSuccess()`).
- [ ] No sensitive detail in client-facing messages.
- [ ] Nested calls propagate the inner envelope instead of rebuilding it from a string.
- [ ] Tests and call sites updated to destructure and assert on the envelope.
- [ ] `gofmt -l`, `go build ./...`, `go vet ./...` and `go test` pass for affected packages.
- [ ] Allowed exceptions and out-of-scope callers listed in the report.

## Common Pitfalls

- Writing `*replify.R` while building with `replify.New()...` and no `.ReplyPtr()`: a compile error, since `New()` returns an unexported type.
- Returning `nil` as the envelope on a failure path, so callers panic on `r.IsError()`.
- Returning `replify.New().ReplyPtr()` for success: the default status is `Processing`, not `OK`.
- Envelope and `error` output disagreeing, leaving callers unsure which to trust.
- Using `WithError(err.Error())` instead of `WithErrorAck(err)`, losing the cause chain.
- Calling `AppendError(nil, msg)`: it overwrites the envelope's error, dropping the cause.
- Converting interface-bound methods (`ServeHTTP`, `String`, `Close`) and breaking interface satisfaction.
- Placing `*replify.R` anywhere but last (e.g. first, or before `error`), or mixing positions across a package.
- Reading `r.Body()` without a nil/type check; prefer `JSONBodyCast(&v)` or check `IsBodyPresent()` first.

## References (official docs, standards)

- [replify repository and README](https://github.com/polarixa/replify)
- [replify on pkg.go.dev](https://pkg.go.dev/github.com/polarixa/replify)
- [Effective Go: Multiple return values](https://go.dev/doc/effective_go#multiple-returns)
- [Go blog: Working with Errors in Go 1.13](https://go.dev/blog/go1.13-errors)
- [RFC 9110: HTTP Semantics, status codes](https://www.rfc-editor.org/rfc/rfc9110#name-status-codes)
