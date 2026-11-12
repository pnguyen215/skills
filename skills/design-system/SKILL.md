---
name: design-system
description: 'Building consistent UI/UX component libraries and design tokens. Trigger: "create design system", "standardize UI", "design tokens".'
metadata:
  category: design
  tags: "design-system, ui, ux, design-tokens, component-library"
---

# Design System

## Purpose

Ensures visual and functional consistency across products. Responsibility boundary: defines tokens and components and may edit UI code within scope; does NOT redesign product UX, create brand identity, or write backend logic.

## When to Use / When NOT to Use

- **Use**: New frontend projects, scaling UI teams, brand consistency.
- **NOT**: One-off marketing landing pages.
- **NOT**: Explaining a design concept (use `design-concept-explainer`).
- **NOT**: Applying GoF/enterprise code patterns (use `design-pattern`).

## Prerequisites & Assumptions

- Design tokens (Figma). Component framework (React/Vue/Angular).

### Scope & Context Resolution

- **Supported scopes**: repository/UI package (default), token file, single component, component family (e.g. form inputs), Storybook docs.
- **Rule 1 - Explicit context**: The user's stated requirements, constraints, versions, targets and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line. Security/data-loss rules stay mandatory; flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at UI-package scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to token definitions, component styles and docs inside the resolved scope.

## Step-by-Step Workflow

1. Resolve scope and context (see above); state the resolved scope and mutation boundary in one line at the start of the output.
2. Define design tokens (colors, spacing, typography) within scope.
3. Build atomic components (Button, Input).
4. Compose molecules/organisms.
5. Publish to internal package registry.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **MUST**: Use design tokens for all styles (no hardcoded hex).
- **MUST**: Document accessibility (a11y) requirements (WCAG).
- **SHOULD**: Version the component library via SemVer.
- **MUST NOT**: Hardcode colors or spacing in components.
- **MUST NOT**: Restyle or rename components outside the requested scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `color: #0000FF; margin: 10px;`
- **Good**: `color: var(--color-primary); margin: var(--spacing-md);`
- **Scope - Good**: Prompt "only the Button component" -> replace hardcoded values in `Button.css` with tokens; list hardcoded colors found in `Card.css` as a note.
- **Scope - Bad**: Same prompt -> retokenizing every component and renaming the token scale.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Tokens defined.
- [ ] A11y compliant.
- [ ] Documented in Storybook.

## Common Pitfalls

- Ignoring dark mode.
- Poor accessibility (contrast, keyboard nav).
- Renaming tokens library-wide when only one component was requested.

## References (official docs, standards)

- [Atomic Design by Brad Frost](https://bradfrost.com/blog/post/atomic-web-design/)
- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [Design Tokens Community Group](https://www.w3.org/community/design-tokens/)
