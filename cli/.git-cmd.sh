# Navigate to your repository
cd /path/to/skills

# Create a new branch following Conventional Commits
git checkout -b chore/standardize-skills-repo

# Add all generated files
git add .

# Commit with a detailed message
git commit -m "chore: standardize and modernize enterprise skills repository

- Consolidate legacy Go skills into cross-language categories
- Add 21 new skills (Security, CI/CD, Observability, API Design, etc.)
- Enforce strict SKILL.md template with enterprise rules
- Add Makefile for validation, linting, and scaffolding
- Align with SOLID, 12-Factor, OWASP, and SRE principles"

# Push to remote
git push origin chore/standardize-skills-repo