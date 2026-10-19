# Enterprise Engineering Skills Repository

A standardized, enterprise-grade collection of AI agent skills (SKILL.md) designed to enforce large-enterprise engineering standards across Go, Java, Python, and cross-cutting concerns like Security, CI/CD, and Observability.

## 📁 Structure

The repository is organized by domain:

- **`api-design/`**: REST/gRPC conventions, versioning, error models.
- **`ci-cd/`**: Pipelines, quality gates, release management.
- **`code-quality/`**: Reviews, refactoring, static analysis.
- **`database/`**: Schema design, migrations, query optimization.
- **`design/`**: Design patterns, design systems.
- **`documentation/`**: API docs, READMEs, technical writing (ADRs).
- **`git-workflow/`**: Branching, commits, PR templates.
- **`incident-response/`**: Postmortems and RCA.
- **`language-specific/`**: Go, Java, Python best practices.
- **`observability/`**: Logging, metrics, tracing.
- **`performance/`**: Profiling, benchmarking.
- **`security/`**: Secure coding, secrets, dependency scanning.
- **`testing/`**: Unit, integration, coverage, strategy.

## 🚀 How to Use

### For AI Agents (Claude/GitHub Copilot)

1. Copy the contents of the relevant `SKILL.md` file.
2. Paste it into your AI agent's system prompt, custom instructions, or project knowledge base.
3. The agent will now enforce these enterprise standards when generating or reviewing code.

### For Humans

Browse the repository to understand the strict rules, checklists, and workflows we enforce across our engineering organization.

## 🛠️ Tooling

We use a `Makefile` to maintain repository health:

- `make lint`: Lints markdown files.
- `make validate`: Ensures every skill folder has a valid `SKILL.md`.
- `make new-skill NAME=category/skill`: Scaffolds a new skill from the template.

## 🤝 Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines on adding or updating skills. All skills must follow the strict template format and use `kebab-case` for folder names.
