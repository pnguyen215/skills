---
name: code-quality-function-renamer
description: 'Rename functions and methods to follow the naming convention of the current programming language, after reading the body so the new name matches what the function really does. Every candidate name is validated as clear, short, meaningful and professional (senior-engineer level) before it is applied, and all call sites are updated without changing behavior. Trigger: "rename this function", "fix function names", "follow naming convention", "better name for this method", "rename by language convention", "function name does not match its logic".'
metadata:
  category: code-quality
  tags: "naming, refactoring, conventions, clean-code, readability, rename"
---

# Function Renamer

## Purpose

Gives every function or method a name that (1) follows the idiomatic naming convention of its language and (2) accurately describes the logic inside its body. A rename is a pure refactor: behavior, signatures (other than the name), and public contracts stay the same unless the user approves otherwise.

## When to Use / When NOT to Use

- **Use**: Vague or misleading names (`doStuff`, `process`, `handle2`), names that violate language style, names that no longer match the logic after changes, naming cleanup before review.
- **NOT**: General smell removal or restructuring (use `code-quality-refactoring`).
- **NOT**: Renaming files/folders by topic (use `documentation-topic-organizer`).
- **NOT**: Changing API paths or versions (use `api-design-rest-grpc-conventions`, `api-design-versioning`).
- **NOT**: Bug hunting (use `code-quality-bug-detection`).

## Prerequisites & Assumptions

- Scope is given (function, file, module, or whole codebase). If absent, default to the files the user named; never the whole repo silently.
- Language is detected from the file extension and project config; mixed-language repos are handled per file.
- Tests or at least a compiler/type-check/linter can be run to prove nothing broke.

## Step-by-Step Workflow

1. **Detect language and convention** (see Language Conventions). Also read the project's own linter/style config (`.golangci.yml`, `.eslintrc`, `pyproject.toml`, `checkstyle.xml`); local config wins over the table.
2. **Read the full body** of each function, not just the signature: inputs, outputs, side effects (I/O, mutation, network, DB), error paths, and what callers do with the result.
3. **Summarize the logic in one sentence**: "<verb> <object> [qualifier]". If the sentence needs "and", the function does two things: flag it and name the dominant job (do NOT split it unless asked).
4. **Draft 2-3 candidates** using the Naming Formula.
5. **Validate each candidate** against the four rules (clear, short, meaningful, professional) and the Logic-Fidelity check. Drop failures; pick the best survivor.
6. **Find all references** (call sites, tests, docs, interface/mock implementations, reflection/string usages, exports, generated code). Check visibility: public/exported API renames are breaking.
7. **Apply** with the IDE/language-server rename or a scoped, word-boundary search-replace; update comments and docs that mention the old name.
8. **Verify**: build, type-check, lint, run tests. Re-grep the old name to confirm zero leftovers.
9. **Report** the rename table and anything skipped.

## Naming Formula

`<verb><Object>[Qualifier]`, cased per the language.

| Function kind          | Pattern                                                  | Examples                         |
| ---------------------- | -------------------------------------------------------- | -------------------------------- |
| Query, no side effects | `get/find/list/compute/parse` + object                   | `findUserByEmail`, `parseConfig` |
| Boolean                | `is/has/can/should` + condition                          | `isExpired`, `hasPermission`     |
| Mutation / command     | strong verb + object                                     | `markOrderPaid`, `appendEvent`   |
| Constructor / factory  | `new/create/build/from` + object                         | `newClient`, `fromJSON`          |
| Conversion             | `to` + target or `from` + source                         | `toDTO`, `fromEntity`            |
| Validation             | `validate/ensure/verify` + object                        | `validateToken`                  |
| Async / IO boundary    | follow language idiom (`Async`, `fetch`, `load`, `read`) | `loadSettings`                   |

Choose the verb by the real effect: `get` = cheap, pure lookup; `find` = may return nothing; `load/fetch/read` = does I/O; `compute/calculate` = real work; `ensure` = idempotent create-if-missing; `validate` = returns or raises on invalid; `parse` = text to structure.

## Language Conventions

| Language                | Functions / methods                                                                        | Notes                                                                                                                                                                                            |
| ----------------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Go                      | `MixedCaps`; exported = `UpperCamel`, unexported = `lowerCamel`                            | No `Get` prefix on plain getters (`Name()`, not `GetName()`); no stuttering with package (`user.New`, not `user.NewUser`); error-returning ctor `NewX`; acronyms keep case (`ID`, `URL`, `HTTP`) |
| Java / Kotlin           | `lowerCamelCase`                                                                           | Booleans `is/has`; getters `getX` in Java beans; no Hungarian prefixes                                                                                                                           |
| JavaScript / TypeScript | `lowerCamelCase`; React components and classes `UpperCamel`                                | Hooks `useX`; handlers `handleX` (internal) / `onX` (props)                                                                                                                                      |
| Python                  | `snake_case`; private `_leading_underscore`                                                | Boolean `is_/has_`; dunder only for protocol methods                                                                                                                                             |
| Rust                    | `snake_case`                                                                               | Conversions `to_/as_/into_/from_`; getters without `get_`                                                                                                                                        |
| C#                      | `PascalCase` for methods; async methods end with `Async`                                   | Private fields `_camel` (not functions)                                                                                                                                                          |
| C / C++                 | Follow the project (`snake_case` for C, Google style `PascalCase` or `snake_case` for C++) | Do not mix styles within one codebase                                                                                                                                                            |
| Ruby                    | `snake_case`; predicates end `?`, mutating-in-place end `!`                                |                                                                                                                                                                                                  |
| PHP                     | `camelCase` (PSR-12)                                                                       |                                                                                                                                                                                                  |
| Shell                   | `snake_case`, optionally `namespace::name`                                                 |                                                                                                                                                                                                  |
| SQL functions           | `snake_case`                                                                               |                                                                                                                                                                                                  |

If the language is not listed, use its official style guide and state which one.

## Validation Rules (a name MUST pass all four)

1. **Clear**: A reader understands what it does without opening the body. No ambiguous words (`handle`, `process`, `manage`, `do`, `run`, `data`, `info`, `util`, `helper`, `stuff`) unless they are the true domain term.
2. **Short**: As few words as keep it unambiguous. Target 2-3 words, hard limit 4. Drop words implied by the type, receiver, or package (`user.UserService.getUserFromUserRepo` becomes `service.find`).
3. **Meaningful**: Uses the domain vocabulary of the codebase; reflects the real effect (verb matches side effects) and the returned thing (object matches output). No encoded types, no numbers (`handle2`), no temporal words (`new`, `old`, `temp`, `v2`) unless versioning is the point.
4. **Professional**: Senior-level, neutral, searchable. No slang, jokes, abbreviations that are not industry standard (`cfg`, `ctx`, `ID`, `URL` are fine; `usrMgr`, `chkAuth` are not), no emotion, no negations in booleans (`isNotValid`), no misleading verbs.

**Logic-Fidelity check (MUST)**: re-read the body against the new name and confirm all four:

- [ ] Every side effect is either named or genuinely implied (a function that writes to the DB is not `get...`).
- [ ] The name does not promise more than the body does (`validateUser` that only checks nulls is `requireUserFields`).
- [ ] The name does not hide a significant action (`getUser` that also creates one is `getOrCreateUser`).
- [ ] The return value matches the object in the name.

Score each candidate on the four rules plus fidelity; if none passes, keep the old name and report why.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Preserve behavior; a rename changes identifiers only.
- **MUST**: Read the body before naming; never name from the old name or signature alone.
- **MUST**: Follow the language convention AND the project's local style; local config overrides this skill.
- **MUST**: Update every reference, including tests, mocks, docs, comments, and interface implementers; rename overriding methods together.
- **MUST**: Run build/type-check/lint/tests after renaming and report results honestly.
- **MUST**: Keep visibility (exported or not) unchanged unless the convention forces a case change (Go).
- **SHOULD**: Keep names consistent for the same concept across the codebase (one of `find`/`lookup`, not both).
- **SHOULD**: For public API renames, provide a deprecated alias or ask for approval first.
- **MUST NOT**: Rename framework/protocol-bound names: `main`, `init`, `__init__`, `toString`, `Test*`/`Benchmark*`, `@Override` methods, lifecycle hooks, interface methods of third-party types, serialized/reflection/RPC/ORM-mapped names, CLI/route handlers bound by string, generated code.
- **MUST NOT**: Rename vendored or third-party code.
- **MUST NOT**: Introduce a name that collides with an existing symbol in the same scope.
- **MUST NOT**: Change signatures, logic, formatting, or unrelated code in the same change.

## Examples (good vs. bad, with realistic code or output)

Go, name hides a side effect and breaks convention:

```go
// Bad: "Get" prefix, stutters with package, but also writes to the DB.
func (r *UserRepo) GetUserData(id string) (*User, error) {
    u, err := r.db.Find(id)
    if err == nil { r.cache.Set(id, u) }
    return u, err
}

// Good: no Get prefix, cache write is implied by Load (I/O + populate).
func (r *UserRepo) Load(id string) (*User, error) { ... }
```

Python, vague name and convention violation:

```python
# Bad
def processData(d):
    return [x for x in d if x.expires_at > now()]

# Good: snake_case, verb matches the filter, object matches the output
def filter_active_sessions(sessions): ...
```

TypeScript, boolean and handler:

```ts
// Bad: negated boolean, vague handler
const isNotValid = (t: Token) => t.exp < Date.now();
function doClick() {}

// Good
const isExpired = (t: Token) => t.exp < Date.now();
function handleSubmit() {}
```

Rejected candidate (logic fidelity): `validateOrder` for a function that only checks `order != nil` is rejected; use `requireOrder`.

Report format:

| File           | Old           | New    | Why (logic)              | Refs | Risk     |
| -------------- | ------------- | ------ | ------------------------ | ---- | -------- |
| `repo/user.go` | `GetUserData` | `Load` | Reads DB and fills cache | 7    | exported |

## Checklist (verifiable, copy-pasteable)

- [ ] Language and project style config identified
- [ ] Full body read for every renamed function
- [ ] One-sentence logic summary written per function
- [ ] New name passes clear, short, meaningful, professional
- [ ] Logic-Fidelity check passed (side effects, scope, return)
- [ ] No collision; no protected/bound name renamed
- [ ] All references, tests, docs, mocks updated; old name grep returns zero
- [ ] Build, lint, tests pass (or failures reported)
- [ ] Public API renames flagged

## Common Pitfalls

- Naming from the signature without reading the body.
- Verbs that lie: `get` that mutates, `validate` that fixes, `check` that throws.
- Too long names that restate the type or package.
- Renaming one half of an interface/override pair.
- Search-replace hitting substrings or unrelated symbols (`Load` inside `Download`); use word boundaries or the language server.
- Missing string-based usages: reflection, JSON/ORM tags, DI containers, route tables, config files.
- Using a different convention than the rest of the file because "that is what I prefer".

## References

- Effective Go (names): https://go.dev/doc/effective_go#names
- Go Code Review Comments: https://go.dev/wiki/CodeReviewComments
- PEP 8 naming: https://peps.python.org/pep-0008/#naming-conventions
- Google Java Style: https://google.github.io/styleguide/javaguide.html#s5-naming
- Rust API Guidelines (naming): https://rust-lang.github.io/api-guidelines/naming.html
- Clean Code, Ch. 2 "Meaningful Names" (R. C. Martin)
