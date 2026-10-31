---
name: skill-optimizer
description: Analyzes, refactors, and optimizes existing SKILL.md files to enhance LLM performance and enforce coding standards.
metadata:
  category: meta-skills
  tags: "prompt-engineering, optimization, agent-skills, performance"
---

# Agent Skill Optimizer

## Context & Purpose

This skill is designed to analyze, refactor, and optimize existing `SKILL.md` files to maximize LLM performance, reduce hallucinations, and enforce enterprise-grade coding standards.

## Activation Triggers

- User asks to "optimize a skill", "improve SKILL.md", or "refactor agent prompt".
- User provides an existing `SKILL.md` and asks for a better version.

## Instructions (Chain of Thought)

When asked to optimize a skill, you MUST follow these steps sequentially:

1. **Analyze Current State:** Identify weak points: Vague instructions, missing constraints, or ambiguous triggers.
2. **Define Guardrails:** Create a strict `## Anti-Patterns & Constraints` section.
3. **Inject Chain-of-Thought (CoT):** Add a mandatory planning phase. Instruct the AI to output a `<plan>` block before writing any code.
4. **Provide Few-Shot Examples:** Write a brief `## Examples` section showing the ideal Input/Output interaction.

## Anti-Patterns (DO NOT)

- DO NOT remove the original `metadata` frontmatter.
- DO NOT make instructions overly verbose; keep them punchy and directive.
- DO NOT use subjective language (e.g., "try to write good code"). Use absolute directives (e.g., "MUST validate all inputs").
