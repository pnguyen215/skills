---
name: readme-generator
description: 'Creating standardized, comprehensive README.md files for repositories. Trigger: "write README", "generate project docs", "open source readme".'
---

# README Generator

## Purpose

Provides the first impression and onboarding guide for a repository.

## When to Use / When NOT to Use

- **Use**: New repos, open-source projects, internal tools.
- **NOT**: Deep architectural decisions (use ADRs).

## Prerequisites & Assumptions

- Project metadata. Installation steps.

## Step-by-Step Workflow

1. Add badges (build status, coverage, version).
2. Write quickstart/install guide (< 5 mins).
3. Document API/usage with code snippets.
4. Add contributing guidelines and license.

## Enterprise Rules & Standards

- **MUST**: Include Quickstart that works out of the box.
- **MUST**: List prerequisites (OS, language version, DB).
- **SHOULD**: Add architecture diagram (Mermaid).
- **MUST NOT**: Assume prior internal company knowledge.

## Examples

- **Bad**: README with only `npm install`.
- **Good**: Complete guide with env vars, examples, and troubleshooting.

## Checklist

- [ ] Badges added.
- [ ] Quickstart works.
- [ ] License included.

## Common Pitfalls

- Missing required environment variables.
- Outdated CLI commands.

## References

- [Make a README](https://www.makeareadme.com/)
