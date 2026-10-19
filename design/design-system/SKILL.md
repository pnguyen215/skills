---
name: design-system
description: 'Building consistent UI/UX component libraries and design tokens. Trigger: "create design system", "standardize UI", "design tokens".'
---

# Design System

## Purpose

Ensures visual and functional consistency across products.

## When to Use / When NOT to Use

- **Use**: New frontend projects, scaling UI teams, brand consistency.
- **NOT**: One-off marketing landing pages.

## Prerequisites & Assumptions

- Design tokens (Figma). Component framework (React/Vue/Angular).

## Step-by-Step Workflow

1. Define design tokens (colors, spacing, typography).
2. Build atomic components (Button, Input).
3. Compose molecules/organisms.
4. Publish to internal package registry.

## Enterprise Rules & Standards

- **MUST**: Use design tokens for all styles (no hardcoded hex).
- **MUST**: Document accessibility (a11y) requirements (WCAG).
- **SHOULD**: Version the component library via SemVer.
- **MUST NOT**: Hardcode colors or spacing in components.

## Examples

- **Bad**: `color: #0000FF; margin: 10px;`
- **Good**: `color: var(--color-primary); margin: var(--spacing-md);`

## Checklist

- [ ] Tokens defined.
- [ ] A11y compliant.
- [ ] Documented in Storybook.

## Common Pitfalls

- Ignoring dark mode.
- Poor accessibility (contrast, keyboard nav).

## References

- [Atomic Design by Brad Frost](https://bradfrost.com/blog/post/atomic-web-design/)
