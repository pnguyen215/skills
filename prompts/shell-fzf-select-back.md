---
title: Enforce shell::fzf::select with back option
description: Implement/verify the back option in shell::fzf::select and enforce it in a file, a function, or the whole shell library
tags: shell,fzf,back,refactor,lint
created: 2026-11-14T00:00:00Z
updated: 2026-11-14T00:00:00Z
---

# ROLE

You are a senior Bash/Zsh engineer working on the `pnguyen215/shell` library
(Linux Ubuntu + macOS). Public functions are named `shell::<module>::<name>`,
internal helpers `_shell::<module>::<name>`. Source lives under `src/`
(lib/, lang/, devops/, shield/, bot/, llm/).

# INPUT (from the end user)

scope: {{scope|all}} # one of: file | function | all
target: {{target|}} # file path when scope=file; function name(s) when scope=function; empty when scope=all

Scope rules:

- file -> change only callers inside that file.
- function -> change only the named function(s) (locate the file with grep) plus
  the private helpers that render its menu.
- all -> change every caller under `src/`.
  Phase 1 (the primitive) is ALWAYS verified, whatever the scope. Offenders outside
  the scope are REPORTED, never modified.

# OBJECTIVE

1. `shell::fzf::select` natively supports a "back" option, with a clean,
   backward-compatible contract.
2. Every interactive "choose from a list" flow inside the scope uses
   `shell::fzf::select` (no raw `fzf`, bash `select`, `read` menus or custom
   numbered lists) and exposes "back" with identical behavior everywhere.
3. The rule stays enforced afterwards by a lint check and tests.

# READ FIRST (MANDATORY — DO NOT SKIP)

1. Find and read the current `shell::fzf::select` (likely `src/lib/fuzzy.sh` or
   `src/lib/common.sh`): signature, forwarded fzf arguments, stdin/stdout
   contract, exit codes, dependency check (`shell::dependency::fzf::ensure`).
2. Read the existing back convention already used in `src/lang/git.sh` and
   `src/lib/conf.sh`:
   - label constant `SHELL_FZF_BACK_LABEL` (rendered "← Back"), return constant
     `RETURN_BACK` (exit code 11)
   - callers append the label as the LAST item:
     printf '%s\n%s\n' "$list" "$SHELL_FZF_BACK_LABEL" | shell::fzf::select --prompt="..."
   - on back: `shell::logger::info "Back — nothing was <verb>"`, then
     `return "$RETURN_BACK"` BEFORE any mutation
   - empty selection (ESC/Ctrl-C): `shell::logger::error` + `return 1`
   - docs: `@exitcode 11 The user picked the "← Back" entry (SHELL_FZF_BACK_LABEL); nothing was changed.`
   - `-n` dry-run prints via `shell::logger::command_clip` and never executes
3. Find where the constants are declared and how `RETURN_*` codes are defined;
   reuse them. Never introduce magic numbers.
4. List EVERY existing caller of `shell::fzf::select`
   (`grep -rn 'shell::fzf::select' src/ test/`) before changing the primitive, so
   the contract change can be verified against all of them.
5. Read the existing tests in `test/` and the CI workflow(s) in `.github/workflows/`.

# PHASE 1 — IMPLEMENT / VERIFY THE PRIMITIVE

Design `shell::fzf::select` so back is built in, with a contract that does not
break existing callers (including those that already append the label manually).

Required behavior:

- Flags: `--back` / `--no-back`, optional `--back-label <text>` (default
  `$SHELL_FZF_BACK_LABEL`). Choose the DEFAULT (recommended: back ON for
  single-select menus, `--no-back` as the explicit opt-out for non-menu uses such
  as file/path pickers or pure fuzzy search). Justify the choice after auditing
  callers, and add `--no-back` where back is semantically wrong.
- Append the label as the LAST item, streaming, in ONE process (for example awk:
  print every line; append the label only if it was not already present).
  Idempotent: callers that already append the label must not produce a duplicate.
- Stdout contract stays unchanged: the selected line is printed, and the label is
  printed when back is chosen. Exit code stays 0 for a selection (back included) and
  non-zero only for cancel/ESC, so every existing `selected=$(...)` caller keeps
  working. Add a tiny helper, for example
  `shell::fzf::select::is_back "<value>"` (exit 0 when the value equals the back
  label), so callers never hard-code the comparison. If you believe a different
  exit-code contract is better, justify it against the audited callers first.
- Multi-select (`--multi`/`-m`): strip the back label from valid selections; if the
  only selected line is back, treat it as back; never return back mixed with items.
- Empty list: Back must still be shown; the caller's "nothing found" message keeps
  working.
- Collisions: a real item equal to the back label is impossible by design; document
  the reserved label and handle it deterministically.
- Forward every other argument to fzf unchanged (`--prompt`, `--preview`,
  `--header`, `--bind`, `--expect`, `--height`, ...). With `--expect`, keep the key
  line semantics intact.
- No extra subprocess per menu beyond the single streaming one; do not buffer big
  lists in shell variables unnecessarily.
- Non-interactive safety: if stdin/stdout is not a TTY or fzf is missing, keep the
  current behavior (clear error via `shell::dependency::fzf::ensure`); never hang.
- Bash and zsh compatible; Linux and macOS; no GNU-only flags.
- Update its doc header and `-h|--help` text (@option --back/--no-back/--back-label,
  @exitcode, @example) in the repo style.

# PHASE 2 — AUDIT (scope-limited)

Detect candidates within the scope:
grep -nE 'shell::fzf::select' <scope files>
grep -nE '(^|[^:_a-zA-Z])fzf( |$)|fzf-tmux|gum choose|peco' <scope files>
grep -nE '\bselect +[a-zA-Z_]+ +in\b|PS3=|read -r? ?-p' <scope files>
Also inspect functions named `*::fzf`, `*select*`, `*choose*`, `*pick*`, `*switch*`,
`*manage*`, `*view*`, `*remove*`, and any function that prints numbered options and
waits for input.

Classify each candidate into exactly one bucket:
A. Uses `shell::fzf::select` and already handles back correctly -> leave untouched
(only simplify to the helper if it is a trivial, safe change).
B. Uses `shell::fzf::select` but has no back, or handles it inconsistently -> fix.
C. Single-choice list built WITHOUT `shell::fzf::select` (raw fzf, bash `select`,
`read` menu) -> migrate to `shell::fzf::select` + back.
D. Multi-select or non-menu usage (path/file pickers, free-text fuzzy search,
scripts consuming the output) -> do not change blindly; apply multi-select
rules when a menu, or `--no-back` when back makes no sense; justify each case.
Print the audit table BEFORE editing:
| File | Function | Mechanism | Bucket | Planned change |

# PHASE 3 — ENFORCE (buckets B, C, D-as-menu)

For each function in scope:

1. Build the option list; call `shell::fzf::select` (back enabled).
2. Empty selection -> keep the function's existing cancel behavior.
3. Back chosen -> `shell::logger::info "Back — nothing was <verb>"` and
   `return "$RETURN_BACK"` BEFORE any state change (no file write, no `rm`, no
   `git`/`ssh`/`brew`/network call, no clipboard side effect).
4. Nested menus: back returns to the PREVIOUS level; only the top level exits the
   function. Loops (`while true`) must `break`/`return` correctly on back (no
   infinite loop, no skipped cleanup).
5. Preserve everything else: arguments, `-n` dry-run (print only, never execute),
   OS branches, other exit codes, output format, function names and signatures.
6. Update the function doc header (add `@exitcode 11`, mention the back entry)
   and its help text, matching the style in `conf.sh`.
7. Do not refactor unrelated code; smallest diff per function.

# PHASE 4 — GUARDRAILS (so it stays enforced)

- Add a lint script (for example `scripts/lint-fzf-back.sh`, or the repo's existing
  script folder) and a `make lint-fzf` target that fails when:
  a) raw `fzf`/`fzf-tmux` is invoked anywhere except inside the allow-listed file
  that implements `shell::fzf::select` (and documented exceptions),
  b) a function calls `shell::fzf::select` without `--no-back` and without
  handling back (via `is_back` or the label) before mutating,
  c) bash `select ... in` or `PS3=` menus appear in `src/`.
  Make it fast (grep/awk), POSIX, and runnable on Linux and macOS.
- Add tests under `test/` using a stub `fzf` placed first in PATH (a tiny script
  that prints a line chosen through an env var), so tests never need a TTY:
  back appended exactly once; no duplicate when the caller already appended it;
  `--no-back` leaves the list untouched; multi-select strips back; only-back in
  multi-select counts as back; ESC returns non-zero with empty stdout; empty
  list still offers back; extra fzf args are forwarded; dry-run does not mutate;
  representative functions return `RETURN_BACK` (11) without side effects.
- Run the lint in CI: add it to the existing GitHub workflow next to the
  shfmt/tests steps.
- Document the rule in the README (section "fzf selection convention"): label,
  helper, exit codes, `--no-back` guidance and a copy-paste snippet for new
  functions.

# CONSTRAINTS

- Keep backward compatibility: public names, flags, exit codes (0, 1, 11), outputs.
- Follow repo conventions: doc headers, `shell::logger::*`, shfmt style, `-n`
  semantics, bash + zsh, Linux + macOS.
- No new hard dependencies beyond fzf. Do not modify files outside the stated
  scope except for the primitive, the lint script, tests, CI, and README.
- If something in the primitive blocks the design, STOP and report the exact blocker
  with a minimal proposal instead of working around it in callers.

# PROCESS

1. Summarize the existing conventions and the current primitive in <= 10 lines.
2. Present the primitive design (flags, default, contract, edge cases) and the list
   of existing callers it affects, with the compatibility decision for each.
3. Implement Phase 1; run tests; then print the Phase 2 audit table for the scope.
4. Apply Phase 3 file by file / function by function.
5. Implement Phase 4 (lint, tests, CI, README).
6. After every step run: `bash -n <files>`, `zsh -n` if available, `shellcheck`,
   `shfmt -d` per repo config, and `make test`.
7. Re-run the detection greps for the scope and confirm there is no bucket B/C
   leftover; run `make lint-fzf` and show it passing.

# OUTPUT FORMAT

- Conventions summary and primitive design.
- Audit table (before) and results table (after, with bucket and status).
- Unified diffs grouped by phase and file.
- Test and lint results.
- Out-of-scope offenders (file, function, bucket) left untouched, with a suggested
  follow-up command for the maintainer.
- Risks and compatibility notes (callers that needed `--no-back`, behavior changes).

# DEFINITION OF DONE

- `shell::fzf::select` supports the back option idempotently, documented and tested,
  with no regression for existing callers.
- Every interactive single-choice flow in scope uses `shell::fzf::select`, offers
  "← Back" as the last entry, and returns `RETURN_BACK` (11) without side effects.
- The lint check and tests pass locally and in CI; README documents the convention.
- `bash -n`, shellcheck, shfmt and `make test` pass on the Linux and macOS code paths.
