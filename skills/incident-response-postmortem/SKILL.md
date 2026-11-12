---
name: incident-response-postmortem
description: 'Blameless postmortem frameworks, root-cause analysis (5 Whys), and action item tracking. Trigger: "write incident postmortem", "RCA template", "incident review".'
metadata:
  category: incident-response
  tags: "incident-response, postmortem, rca, five-whys, blameless"
---

# Postmortem & RCA

## Purpose

Learns from incidents to prevent recurrence. It produces a postmortem document, RCA, and action items for the named incident; it does NOT run live incident triage, change code or infrastructure, or assign blame.

## When to Use / When NOT to Use

- **Use**: After SEV-1/SEV-2 incidents, customer-impacting outages.
- **NOT**: Minor bugs or expected maintenance.
- **NOT**: Live incident triage or mitigation (use `engineering:incident-response`).
- **NOT**: Fixing the root cause in code (use `code-quality-refactoring` or the owning team's workflow).

## Prerequisites & Assumptions

- Incident timeline. Blameless culture.

### Scope & Context Resolution

- **Supported scopes**: single incident, postmortem document, timeline section, action-item list. Default when none is given: the one incident described in the prompt.
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, constraints, severity, template, targets, and scope are authoritative. Apply the skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow, and rules as the sole context at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits are limited to the postmortem document. MUST NOT edit source code, runbooks, or alert configuration, and MUST NOT create tickets unless the user asks.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Gather detailed timeline from logs/metrics for the in-scope incident.
3. Perform 5 Whys (Root Cause Analysis).
4. Draft postmortem document.
5. Create and track action items in Jira/Issues.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Keep it blameless (focus on process, not people).
- **MUST**: Assign owners and due dates to action items.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Share widely across engineering.
- **MUST NOT**: Hide root causes or sweep under rug.
- **MUST NOT**: Merge unrelated incidents into one postmortem or attribute causes without timeline evidence.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: "John broke prod by typing the wrong command."
- **Good**: "Deployment pipeline lacked validation step for config changes."

**Scope handling**

- **Prompt**: "Postmortem for the 2026-11-03 checkout outage only."
- **Good**: Builds the timeline and 5 Whys for that outage; notes a similar earlier incident as a reference.
- **Bad**: Merges three past incidents into one document and proposes an org-wide reliability overhaul.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Timeline complete.
- [ ] RCA (5 Whys) done.
- [ ] Action items tracked.

## Common Pitfalls

- Finger-pointing.
- Action items never completed.
- Scope creep: turning one incident review into a program-wide reliability audit.

## References (official docs, standards)

- [Google SRE Book: Postmortem Culture](https://sre.google/sre-book/postmortem-culture/)
