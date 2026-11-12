---
name: documentation-collapsible-readme
description: 'Refactor messy, overly long, or complex README.md files into a clean, collapsible (<details>/<summary>) structure for experienced engineers. Trigger: "refactor this README", "our README is a wall of text", "add collapsible sections to the README", "make this README scannable for seniors", "generate docs for this package".'
metadata:
  category: documentation
  tags: "documentation, readme, markdown, collapsible, refactoring"
---

# Collapsible README Refactoring

## Purpose

Produce a README.md that reads like a senior engineer walking a sharp new colleague through the codebase: precise, grounded in the actual project, organized so a reader can jump straight to the one section they need instead of scrolling a wall of text. The deliverable always follows the same collapsible (`<details>`/`<summary>`) skeleton defined below, regardless of the project's language or stack. Responsibility boundary: writes or restructures README.md only; does NOT modify source code, API reference docs, changelogs or ADRs.

## When to Use / When NOT to Use

**Use when:**

- There is no README yet and you have (or can get) real project material to document — not just a project name.
- An existing README needs restructuring into a scannable, collapsible format without losing any of its current content.
- The request is phrased indirectly ("our docs are a mess", "make this look professional", "generate docs for this package") but the deliverable is clearly a project-level README.

**Do NOT use when:**

- The only input is a project name or a one-line idea, with no source, manifest, or fetchable repo behind it — see Prerequisites below; gather material first instead of forcing this skill to invent one.
- The request is for API reference docs, a CHANGELOG, or an ADR — those are different deliverables with their own conventions, even though they live next to the README (use `documentation-api-documentation`, `documentation-changelog-writer` or `documentation-technical-writing`).
- A standard non-collapsible README is wanted from scratch (use `documentation-readme-generator`).
- The user explicitly wants a flat, non-collapsible README (some teams intentionally avoid `<details>` for accessibility or static-site-generator reasons) — ask before applying this skeleton, don't assume it's always wanted.

## Prerequisites & Assumptions

- **Real material, not a name.** You MUST NEVER invent a README from imagination — a README describing an API that doesn't exist is worse than no README, because it actively misleads. Gather, in order of preference:
  1. Files handed over directly: manifest/package file, main source files, an existing README, `LICENSE`, CI config.
  2. A repository you can actually read (local path, fetchable URL): read the manifest first (name, language/runtime version), then entry-point docs, then the public API surface, then tests/benchmarks, then CI config.
  3. Neither available → stop and ask for exactly what's missing (e.g. "send me the manifest and the main exported functions, or a repo link"). MUST NOT guess.
- **Target renderer is GitHub-flavored Markdown**, where `<details>`/`<summary>` render as native collapsible sections. If the destination is a different renderer (internal wiki, static site), MUST confirm it supports the same HTML before committing to this structure.
- **Existing README language is preserved** unless the user asks for translation — SHOULD NOT silently anglicize someone's docs.

### Scope & Context Resolution

- **Supported scopes**: repository root README, package/module README, or a single README section. Default: the README the user names; if none, the project-level README.md of the repository provided.
- **Rule 1 - Explicit context**: user-stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to README.md files inside the resolved scope; MUST NOT edit source code, other docs, or READMEs of other packages.

## Step-by-Step Workflow

1. **Resolve scope and context.** Apply the Scope & Context Resolution section; state the resolved scope and mutation boundary in one line at the start of the output.
2. **Resolve inputs.** Apply the Prerequisites rule above before writing a single line.
3. **Audit first, if updating.** For an existing README, mentally inventory every section, example, config flag, and caveat it already has. This is your checklist so nothing gets silently dropped during restructuring — merge overlapping sections (e.g. an old "Usage" and "Examples" covering the same snippet) rather than keeping duplicates.
4. **Draft the header and table of contents** — see Enterprise Rules & Standards for exactly what's mandatory and what's conditional.
5. **Build each section inside its own `<details>` block**, skipping Architecture Notes / Testing & Benchmarks when the project genuinely doesn't warrant them (see Common Pitfalls for why forcing them is worse than omitting them).
6. **Place an anchor immediately before every `<details>` block** and point the table of contents at those same anchor IDs — see the Example below; this is the step most frequently skipped and the most common way the whole structure breaks.
7. **Check every code block**: MUST live inside its own `<details>`, MUST actually compile/run as shown, MUST handle errors explicitly, and MUST use the correct backtick-fence depth (see Common Pitfalls).
8. **Run the Checklist** below before returning the final document.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST** stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST NOT** edit source code or READMEs outside the named scope.

### README Structure

Only two elements MUST stay **outside** any `<details>` block — everything else MUST be wrapped:

1. **Header** — project name (H1), one-line value proposition, badges.
2. **Table of contents** — MUST link to real anchor IDs (see Step 6), MUST NOT link to text buried inside a `<summary>`.

Mandatory wrapped sections, in order:

| #   | Section                       | Rule                                                                                                                                   |
| --- | ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| 3   | Overview                      | MUST include: Problem solved, design rationale, key features, when to use vs. not.                                                     |
| 4   | Installation                  | MUST include: Prerequisites, install command(s), version requirements.                                                                 |
| 5   | Quick Start                   | MUST include: A runnable snippet, short enough to scan, showing the core value immediately.                                            |
| 6   | Usage Examples                | MUST include: 3–5 scenarios, each its own nested `<details>` with a descriptive summary; each example MUST actually run.               |
| 7   | API / Configuration Reference | MUST include: A table of exported functions/types/options/env vars.                                                                    |
| 8   | Architecture Notes            | **Conditional** — SHOULD only be included when internals are genuinely non-trivial (concurrency, plugin system, multi-stage pipeline). |
| 9   | Testing & Benchmarks          | **Conditional** — MUST only be included when tests/benchmarks actually exist in the source. MUST NEVER invent numbers.                 |
| 10  | Contributing                  | SHOULD link `CONTRIBUTING.md` if it exists, otherwise one honest sentence.                                                             |
| 11  | License                       | MUST be taken from the real `LICENSE` file, MUST NEVER be assumed.                                                                     |

Sections 3, 4, 5, 6, 7, 10, 11 MUST be present even when thin — one honest sentence beats deleting a section, because the table of contents MUST keep matching the body. Sections 8 and 9 are the only two allowed to be omitted outright.

## Examples (good vs. bad, with realistic code or output)

**Good: Anchor + collapsible pattern** (apply this to every top-level section):

````markdown
## Table of Contents

- [Overview](#overview)
- [Installation](#installation)

<a id="overview"></a>

<details>
<summary><strong>Overview</strong></summary>

This library solves X by doing Y instead of Z, because...

</details>

<a id="installation"></a>

<details>
<summary><strong>Installation</strong></summary>

```bash
go get github.com/user/project
```
````

</details>
```

**Good: Graceful omission** (Contributing section with nothing formal in place):

```markdown
<a id="contributing"></a>

<details>
<summary><strong>Contributing</strong></summary>

No formal process yet — issues and pull requests are welcome.

</details>
```

**Good: Scope Handling**

Prompt: "Refactor only the README in `packages/api`." -> Restructure `packages/api/README.md`; mention a stale root README as a note.

**Bad: Scope Expansion**

Same prompt -> rewriting the root README and every package README.

**Bad: Dead anchor link** (linking directly to summary text without explicit anchor):

```markdown
## Table of Contents

- [Overview](#overview) <!-- Dead link because GitHub does not generate IDs for <summary> text -->

<details>
<summary><strong>Overview</strong></summary>
This library solves X...
</details>
```

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Every `<details>` block has a matching `<a id="...">` anchor placed immediately before it.
- [ ] Every table-of-contents entry resolves to a real anchor, not to text inside a `<summary>`.
- [ ] No leftover template placeholders (`{{...}}` or similar) anywhere in the output.
- [ ] Sections 8 (Architecture Notes) and 9 (Testing & Benchmarks) appear only when the source material actually warrants them.
- [ ] Every code block sits inside its own `<details>` and is runnable as shown.
- [ ] License section matches a real `LICENSE` file found in the project — never assumed to be MIT.
- [ ] If the project is pre-1.0 or visibly still in flux, that's stated plainly in Overview.
- [ ] Updating an existing README: every fact from the audit in Step 3 landed somewhere in the new document.

## Common Pitfalls

- **The anchor trap.** GitHub does not auto-generate an anchor from text inside `<summary>`, because `<summary>` isn't a heading. A table of contents that links to `#overview` while "Overview" only exists inside a `<summary>` tag will produce a dead link. Always add an explicit `<a id="...">` before the block.
- **Forcing conditional sections.** Padding a 200-line utility with an "Architecture Notes" section because the template lists it reads as filler, not rigor — omit it when there's nothing non-trivial to say.
- **Inventing facts.** Fabricated benchmark numbers, a build badge for a project with no CI, or documenting an API that doesn't exist in the source — all worse than leaving the section thin or omitted.
- **Backtick-fence collisions.** If the final document is delivered wrapped in a 4-backtick fence (because it already contains 3-backtick fences internally) and one example needs to show a code block within a code block, bump the fence level up once more rather than risk closing the wrong block early.
- **Scope creep.** Restructuring sibling package READMEs or editing source comments when one README was named.
- **Monorepo ambiguity.** Multiple packages/modules in one repo with no clear primary one — ask which one this README is for rather than guessing and documenting the wrong target.

## References (official docs, standards)

- [GitHub Flavored Markdown Spec](https://github.github.com/gfm/) (specifically HTML blocks and standard Markdown).
- [MDN Web Docs: `<details>` and `<summary>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/details) (for accessibility and standard HTML rendering behaviors).
- Standard open-source README conventions (e.g., [Keep a Changelog](https://keepachangelog.com/) for changelog references, [Choose a License](https://choosealicense.com/) for license texts).
