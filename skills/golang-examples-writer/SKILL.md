---
name: golang-examples-writer
description: 'Write complete, compiling, runnable sample programs under the examples/ folder of a Go library, CLI, or service (HTTP/gRPC API endpoints), covering every public capability, usage case, and error path using only the public API. Supports library, service, or endpoint scope. Trigger: "write examples for this Go library", "create the examples folder", "add sample code for every case", "write runnable examples for this API endpoint", "generate usage examples for this Go service", "examples/ directory for Go package".'
metadata:
  category: language-specific
  tags: "golang, examples, sample-code, documentation, library, api-endpoint, runnable"
---

# Golang Examples Writer

## Purpose

Act as a Senior Go Engineer and developer-experience owner. Read a Go project (library, CLI, or service) and produce the `examples/` folder: one small, self-contained, runnable program per usage case, so a new user can copy, run, and adapt working code instead of reading the source.

Principle: **every example is verified code, not prose.** An example that does not compile, hangs, needs undocumented setup, or demonstrates a behavior the code does not have is worse than no example. Examples use the **public API only**, the same way an external consumer would.

## When to Use / When NOT to Use

**Use when:**

- A Go library or package has no `examples/` folder, or it covers only a few features.
- A service needs client-side or in-process samples for its API endpoints (HTTP, gRPC, WebSocket).
- Public features, options, or error paths are undocumented by working code.
- Existing examples are stale (do not compile against the current API) and must be regenerated.

**Do NOT use when:**

- Writing GoDoc comments or `Example*` functions in `_test.go` files for pkg.go.dev (use `golang-godoc-engineer` or `golang-audit-godoc-coverage`).
- Writing unit, integration, or benchmark tests (use `testing-unit-testing`, `performance-benchmarking`).
- Writing OpenAPI/Swagger or proto documentation (use `documentation-api-documentation`).
- Writing the README (use `documentation-readme-generator`).
- Adding inline comments to implementation code (use `documentation-code-deep-dive`).

## Prerequisites & Assumptions

- Go toolchain is installed; `go build`, `go vet`, and `go run` can execute. If not, state the limitation and mark every example "unverified".
- **Source is ground truth.** Every call, option, return value, and output shown by an example is confirmed by reading the code or running it. MUST NOT invent APIs, flags, endpoints, or response shapes.
- **Examples live inside the project module** by default (`<module>/examples/...`) so they compile against the current source. Use a nested `examples/go.mod` with a `replace` directive only when examples need heavy extra dependencies that must not leak into the main module.
- **No new heavy dependencies.** Prefer the standard library plus dependencies already in `go.mod`.

### Inputs

| Input          | Values                                                      | Default          | Meaning                                                                                                                                                                             |
| -------------- | ----------------------------------------------------------- | ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `kind`         | `library` \| `service` \| `endpoint` \| `auto`              | `auto`           | What is being exemplified. `auto` detects it from the code (exported packages vs. `main`/router/proto).                                                                             |
| `scope`        | `all` \| `package` \| `feature` \| `endpoint`               | `all`            | How much to cover.                                                                                                                                                                  |
| `target`       | package path, feature/function names, route(s) or RPC names | empty            | What to process; empty only when `scope=all`.                                                                                                                                       |
| `output_dir`   | path                                                        | `examples`       | Folder to write to (relative to the module root).                                                                                                                                   |
| `mode`         | `self-contained` \| `client`                                | `self-contained` | Services only. `self-contained`: start the handler in-process (`httptest`/`bufconn`) so the example runs with no setup. `client`: call a running server at a configurable base URL. |
| `language`     | any natural language                                        | `English`        | Language of comments and README text (identifiers stay English).                                                                                                                    |
| `detail_level` | `concise` \| `detailed`                                     | `detailed`       | `concise`: minimal comments, short README table. `detailed`: explanatory comments, expected output, notes on pitfalls per example.                                                  |

### Scope & Context Resolution

- **Rule 1 - Explicit context wins.** The user's stated kind, scope, target, folder, and constraints are authoritative. If they conflict with a rule here, follow the user and state the deviation in one line, EXCEPT the safety rules (no real secrets, no destructive side effects, no mutation of non-example code), which stay mandatory.
- **Rule 2 - No extra context.** Use the defaults above and this skill as the sole context.
- **Rule 3 - Mutation boundary.** Create or update files only under `output_dir`. MUST NOT modify library or service source, `go.mod` of the root module (unless a missing dependency is explicitly approved), tests, or CI. If an example reveals a bug or a missing exported API, report it; do not fix it.

## Step-by-Step Workflow

1. **Resolve context.** State `kind`, `scope`, `target`, `output_dir`, `mode`, `language`, `detail_level`, and the mutation boundary in one line.
2. **Discover the project.** Read `go.mod` (module path, Go version, dependencies), the package layout, existing `examples/`, `README.md`, GoDoc, and `_test.go` files (tests show real usage and expected results). Detect build tags and OS constraints.
3. **Build the case inventory** (see "Case Discovery"). Every public capability and error path becomes a named case with a stable ID. Show the inventory before writing code when it has more than ~10 cases.
4. **Plan the layout.** One folder per case under `output_dir`, ordered from simplest to advanced (see "Layout"). Reuse a single shared helper package only when three or more examples would otherwise duplicate the same setup.
5. **Write each example** following the "Example Standards". Read the implementation of every call used; copy signatures from source, not memory.
6. **Compile gate.** Run `gofmt -l`, `go build ./<output_dir>/...`, and `go vet ./<output_dir>/...`. Fix every failure.
7. **Run gate.** Run each example with a timeout (`timeout 30s go run ./<output_dir>/<case>` or `go run` plus context deadline). Capture its real output. Examples that need external systems are run only against local fakes or marked "not run" with the reason.
8. **Write the index.** Generate `<output_dir>/README.md` with the case table, run instructions, and expected output pointers.
9. **Coverage review.** Compare the final examples against the inventory; list gaps with reasons.
10. **Report** using the output format.

For large projects: work package by package, keep naming and structure uniform, never silently skip a case, and continue until the whole scope is covered or gaps are explicitly listed.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

### Case Discovery

Derive cases from the code, not from guesswork.

**Library / package:**

- Every exported function, type, method, constructor, and option (`With*`, config structs) is mapped to at least one case; closely related symbols MAY share one example.
- Cover: quick start (minimal "hello world"), common tasks, configuration/options, extension points (interfaces, hooks, middleware), concurrency usage (context cancellation, goroutine safety), and every documented sentinel/custom error (`errors.Is`/`errors.As`).
- Cover edge cases the code explicitly handles: empty input, nil, timeouts, limits, retries.

**Service / API endpoint** (route tables, handlers, `.proto` services, OpenAPI):

- One case per endpoint and method, plus: authentication flow, pagination, filtering/sorting, idempotency/retry, validation errors (4xx), not-found, conflict, server-error handling, timeouts and cancellation, streaming (if present), and an end-to-end workflow that chains several calls.
- Request and response shapes come from the actual handler/DTO/proto types. If a typed client package exists, use it; otherwise use `net/http` (or the generated gRPC client).

**Output of this step** is the inventory table:

| ID  | Case | Kind | Public symbols / endpoint | Needs external system | Planned folder |
| --- | ---- | ---- | ------------------------- | --------------------- | -------------- |

### Layout

```text
examples/
  README.md                  # index: table of cases, how to run, prerequisites
  01_quickstart/main.go      # smallest working usage
  02_options/main.go
  03_error_handling/main.go
  ...
  internal/exutil/           # OPTIONAL shared helpers (only if reused by 3+ examples)
```

- **MUST** give each case its own directory with a `package main` and a `main.go` (add `doc.go` or extra files only when needed), so `go run ./examples/<case>` works.
- **MUST** use lowercase `snake_case` or `kebab-case` directory names prefixed with an ordering number (`01_`, `02_`), simplest first. Go import paths allow neither spaces nor uppercase surprises across OSes.
- **MUST** keep one concept per example. Combine concepts only in an explicit "workflow"/"end-to-end" example.
- **SHOULD** group by package or domain with nested folders (`examples/<pkg>/<case>`) when the project has several public packages.
- **MUST NOT** create a `_test.go`-only example set when the request is for runnable programs. (`Example*` test functions belong to `golang-godoc-engineer`.)

### Example Standards

- **MUST** import the module by its real path and use exported symbols only. MUST NOT import `internal/` packages (it will not compile for external users and misrepresents the API).
- **MUST** compile with the module's Go version and pass `go vet`. MUST be `gofmt`-formatted.
- **MUST** be deterministic and self-terminating: no unbounded loops, no waiting on stdin or signals unless the example is explicitly about that and has a timeout; use `context.WithTimeout` for anything that can block.
- **MUST** handle every returned error (print and `os.Exit(1)`/`log.Fatal` in `main`, or return from a `run() error` helper). MUST NOT use `_ =` to hide errors, `panic` for control flow, or ignore `Close`/`Shutdown` results where they matter.
- **MUST** start each file with a header comment: what the case demonstrates, prerequisites, how to run (`go run ./examples/<case>`), and (when `detail_level=detailed`) the expected output.
- **MUST** print visible, stable output (`fmt.Println`/`slog`) so a reader can see the result; keep it short.
- **SHOULD** structure as `func main() { if err := run(); err != nil { fmt.Fprintln(os.Stderr, err); os.Exit(1) } }` with the logic in `run()`.
- **SHOULD** show idiomatic Go: `context.Context` first parameter, `defer` for cleanup, `errors.Is/As` for error checks, functional options as the library defines them.
- **SHOULD** keep each example under ~120 lines; extract a helper only when it clarifies the demonstrated concept.
- **MUST NOT** pad examples with unrelated boilerplate, TODOs, or placeholder text.

### Services and API Endpoints

- **`mode=self-contained` (default).** Start the real handler/router in-process so the example runs with zero setup:
  - HTTP: `httptest.NewServer(handler)` (or `NewRecorder` for a single handler), then call it with `http.Client`.
  - gRPC: `bufconn` listener plus the generated client.
  - Dependencies the handler needs (database, queue, third-party API) are replaced by in-memory fakes defined in the example or `internal/exutil`, using the service's own interfaces. MUST NOT edit service code to make this possible; if no seam exists, switch that case to `client` mode and report it.
- **`mode=client`.** Read the base URL and credentials from environment variables with documented names and safe defaults (`BASE_URL` defaulting to `http://localhost:8080`); fail fast with a clear message when the server is unreachable. Use per-request timeouts.
- **MUST** show request, response, and status handling for success and the main failure responses of each endpoint; decode into the real response types and check `resp.StatusCode` before using the body; `defer resp.Body.Close()`.
- **MUST NOT** send requests to production or third-party hosts. Default hosts are `localhost` or in-process only.
- **MUST** use obviously fake credentials (`"example-token"`, `"user@example.com"`), read secrets from env vars in `client` mode, and never hardcode real tokens, keys, or URLs with embedded credentials.
- **SHOULD** show auth, pagination, retries with backoff, and idempotency keys where the API supports them.

### Safety and Side Effects

- **MUST NOT** perform destructive or irreversible actions: no deleting user files, no writes outside `os.MkdirTemp`, no real network calls beyond `localhost`, no real emails/payments/messages.
- **MUST** clean up temporary files, servers, and goroutines the example creates (`defer os.RemoveAll`, `defer srv.Close()`, context cancellation).
- **MUST NOT** introduce data races or goroutine leaks; run `go vet` and, when concurrency is demonstrated, `go run -race`.
- **MUST** keep OS-specific behavior behind build tags or note the limitation in the header comment.

### Examples Index (`examples/README.md`)

- **MUST** contain: purpose, prerequisites (Go version, env vars), a table `| # | Case | What it shows | Run |`, and a "Running everything" command.
- **MUST** list only examples that exist and compile. Update the table whenever cases are added or removed.
- **SHOULD** link each case to the relevant package or endpoint docs.

### Code Integrity (non-negotiable)

- **MUST** write only under `output_dir`. MUST NOT change implementation code, root `go.mod`/`go.sum` (except approved dependency additions), tests, or CI.
- **MUST** leave existing hand-written examples that still compile untouched unless they are in scope and wrong; report them instead of rewriting.
- **MUST NOT** claim an output the example did not actually produce when run.

### Output Format

1. **Context Summary** - kind, scope, mode, module path, Go version, existing examples found.
2. **Case Inventory** - the inventory table (IDs, symbols/endpoints, planned folders).
3. **Files Created / Updated** - tree of `output_dir` with a one-line purpose per file.
4. **Example Source** - full source of each new file (or, for very large sets, the first examples in full plus an explicit pointer to the files on disk).
5. **Verification Results** - `gofmt`, `go build`, `go vet` results; per-example run status (`passed` / `not run: reason`) with captured output excerpt.
6. **Coverage Report** - `| Case ID | Example | Status |` and a list of uncovered symbols/endpoints with reasons.
7. **Findings** - bugs, missing seams, undocumented behavior, or API oddities discovered while writing examples (reported, not fixed).

## Examples (good vs. bad, with realistic code or output)

**Good: library quick start (smallest working usage, verified output)**

```go
// Package main demonstrates the smallest working use of the slugify package.
//
// Run:      go run ./examples/01_quickstart
// Expected: hello-world
package main

import (
	"fmt"
	"os"

	"github.com/acme/textkit/slugify"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
}

func run() error {
	s, err := slugify.Make("Hello, World!")
	if err != nil {
		return fmt.Errorf("make slug: %w", err)
	}
	fmt.Println(s)
	return nil
}
```

_Public API only, every error handled, one concept, expected output documented._

**Good: API endpoint example, self-contained (no server needed)**

```go
// Package main demonstrates POST /v1/users, including a validation failure.
//
// Run: go run ./examples/05_create_user
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"

	"github.com/acme/userapi/api"
	"github.com/acme/userapi/store"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
}

func run() error {
	srv := httptest.NewServer(api.NewRouter(store.NewMemory())) // real router, in-memory store
	defer srv.Close()

	for _, body := range []string{
		`{"email":"user@example.com"}`, // valid
		`{"email":"not-an-email"}`,     // rejected by the handler's validation
	} {
		resp, err := http.Post(srv.URL+"/v1/users", "application/json", bytes.NewBufferString(body))
		if err != nil {
			return fmt.Errorf("post user: %w", err)
		}
		var out map[string]any
		err = json.NewDecoder(resp.Body).Decode(&out)
		resp.Body.Close()
		if err != nil {
			return fmt.Errorf("decode response: %w", err)
		}
		fmt.Println(resp.StatusCode, out)
	}
	return nil
}
```

_Runs with zero setup, exercises the real handler, and shows both the success and the 4xx path._

**Bad: unverified, unrealistic, hides errors**

```go
package main

import (
	"fmt"

	"github.com/acme/textkit/internal/engine" // internal import: will not compile for users
)

func main() {
	res, _ := engine.Run("input")      // error ignored
	fmt.Println(res.Pretty())          // method never checked in source
	http.Get("https://api.acme.com/v1") // real production host, response unused
	select {}                           // blocks forever
}
```

_Why it's bad: imports `internal/`, invents `Pretty()`, swallows errors, calls a real host, never terminates, and was never compiled._

**Scope handling**

- **Prompt**: `kind=endpoint`, `target=GET /v1/orders`.
- **Good**: Adds `examples/orders_list/` (plus pagination and 401 cases for that route), updates `examples/README.md`, touches nothing else.
- **Bad**: Rewrites all examples, edits the router to expose a test hook, and adds a new HTTP client dependency.

## Checklist (verifiable, copy-pasteable)

- [ ] Kind, scope, target, output folder, mode, language, and detail level resolved and stated.
- [ ] Project discovered: module path, Go version, packages/routes, existing examples, tests read.
- [ ] Case inventory built from code, covering success, options, extension points, and error paths.
- [ ] One directory per case with `package main`; numbered, simplest first.
- [ ] Only exported symbols imported; no `internal/` imports; module path correct.
- [ ] Every returned error handled; no `_ =` hiding; no `panic` flow control.
- [ ] Every example terminates (timeouts/contexts) and cleans up files, servers, goroutines.
- [ ] Services: self-contained via `httptest`/`bufconn` with fakes, or `client` mode with env-configured localhost defaults.
- [ ] No real secrets, no production hosts, no destructive side effects.
- [ ] Header comment on each file: purpose, how to run, expected output.
- [ ] `gofmt -l` clean, `go build ./examples/...` and `go vet ./examples/...` pass.
- [ ] Each example actually run; output captured and matches documented output.
- [ ] `examples/README.md` index matches the files on disk.
- [ ] No file outside `output_dir` modified (`git status` confirms); root `go.mod` unchanged unless approved.
- [ ] Coverage report lists uncovered cases and findings; all seven output sections provided.

## Common Pitfalls

- **Never compiled:** Examples written from memory drift from the real signatures. Always run the compile and run gates.
- **Importing `internal/`:** Works inside the module, impossible for users. Use the public API only.
- **Invented behavior:** Showing an option, flag, endpoint, or response field that the code does not have. Read the implementation first.
- **Examples that need setup:** Requiring a database or a running server with no fallback. Default to in-process fakes or document env vars and fail fast.
- **Forever-running programs:** Servers or workers without a shutdown path. Add a context timeout and `Shutdown`.
- **Swallowed errors:** `_, _ =` in examples teaches users to ignore errors; handle them visibly.
- **Happy path only:** Missing error, validation, timeout, and cancellation cases leaves the hardest part undocumented.
- **Stale index:** `examples/README.md` listing examples that were renamed or removed.
- **Scope creep:** "Fixing" the library to make an example work. Report it under Findings instead.
- **Dependency bloat:** Pulling a new client or assertion library just for samples. Stay with the standard library.

## References (official docs, standards)

- Go Modules Reference and `go.mod` `replace` directive: https://go.dev/ref/mod
- Effective Go and Go Code Review Comments: https://go.dev/doc/effective_go
- `net/http/httptest`: https://pkg.go.dev/net/http/httptest
- gRPC Go `bufconn`: https://pkg.go.dev/google.golang.org/grpc/test/bufconn
- Testable examples (`Example*` functions): https://go.dev/blog/examples
- Sibling skills: `golang`, `golang-godoc-engineer`, `golang-audit-godoc-coverage`, `documentation-readme-generator`, `documentation-api-documentation`, `testing-unit-testing`.
