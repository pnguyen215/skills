# Contributing to Skills

Thank you for improving our engineering standards!

## Adding a New Skill

1. Run `make new-skill NAME=category/skill-name` (e.g., `make new-skill NAME=security/dependency-scanning`).
2. Fill out the generated `SKILL.md` in the new folder.
3. Ensure all sections (Purpose, Rules, Examples, Checklist) are completed with concrete, verifiable rules.
4. Run `make validate` to ensure your file is correctly formatted.
5. Submit a Pull Request.

## Updating an Existing Skill

1. Edit the relevant `SKILL.md`.
2. Ensure changes align with enterprise standards (SOLID, 12-Factor, OWASP).
3. Avoid vague guidance; replace it with concrete rules and examples.
4. Submit a Pull Request.

## Naming Conventions

- **Folders**: `kebab-case` (e.g., `code-quality/static-analysis`).
- **Skill Name**: Must match the folder name in the YAML frontmatter.
- **Trigger Phrases**: Include concrete phrases in the `description` so AI agents know when to activate the skill.

## Quality Bar

Before submitting, verify:

- [ ] Every folder has a valid `SKILL.md`.
- [ ] Descriptions state clearly when the skill triggers.
- [ ] Rules are specific, testable, and justified.
- [ ] Examples are correct, idiomatic, and compile/run.
