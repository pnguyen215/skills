---
name: documentation-readme-generator
description: 'Creating standardized, comprehensive README.md files for repositories. Trigger: "write README", "generate project docs", "open source readme".'
metadata:
  category: documentation
  tags: "documentation, readme, markdown, onboarding, repository"
---

# README Generator

## Purpose

Provides the first impression and onboarding guide for a repository. This skill writes or edits README files only; it does NOT modify source code, build files, or other documentation.

## When to Use / When NOT to Use

- **Use**: New repos, open-source projects, internal tools.
- **NOT**: Deep architectural decisions (use ADRs; see `documentation-technical-writing`).
- **NOT**: Restructuring an existing long README into collapsible sections (use `documentation-collapsible-readme`).
- **NOT**: Changelogs or release notes (use `documentation-changelog-writer`).

## Prerequisites & Assumptions

- Project metadata. Installation steps.

### Scope & Context Resolution

- **Supported scopes**: repository root README, a package/module README, a single README section. Default: the repository root `README.md`.
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to the README file(s) or section inside the resolved scope. MUST NOT edit code, CI, or other docs.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply Scope & Context Resolution; state the resolved scope and mutation boundary in one line at the start of the output.
2. Add badges (build status, coverage, version).
3. Write quickstart/install guide (< 5 mins).
4. Document API/usage with code snippets.
5. Add contributing guidelines and license.

Apply steps 2-5 only to the sections inside the resolved scope.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Include Quickstart that works out of the box.
- **MUST**: List prerequisites (OS, language version, DB).
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Add architecture diagram (Mermaid).
- **MUST NOT**: Assume prior internal company knowledge.
- **MUST NOT**: Rewrite untouched README sections or invent commands, badges, or features not present in the project.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: README with only `npm install`.
- **Good**: Complete guide with env vars, examples, and troubleshooting.
- **Good (scoped)**: Prompt "update only the Installation section" -> revise that section and leave Usage, License, and badges unchanged.
- **Bad (scope-expanding)**: Same prompt -> regenerate the entire README with new badges and an architecture diagram.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Badges added.
- [ ] Quickstart works.
- [ ] License included.

## Common Pitfalls

- Missing required environment variables.
- Outdated CLI commands.
- Scope creep: rewriting the whole README when asked to fix one section.

## References (official docs, standards)

- [Make a README](https://www.makeareadme.com/)
