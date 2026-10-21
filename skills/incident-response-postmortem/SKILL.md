---
name: incident-response-postmortem
description: 'Blameless postmortem frameworks, root-cause analysis (5 Whys), and action item tracking. Trigger: "write incident postmortem", "RCA template", "incident review".'
metadata:
  category: incident-response
  tags: "incident-response, postmortem, rca, five-whys, blameless"
---

# Postmortem & RCA

## Purpose

Learns from incidents to prevent recurrence.

## When to Use / When NOT to Use

- **Use**: After SEV-1/SEV-2 incidents, customer-impacting outages.
- **NOT**: Minor bugs or expected maintenance.

## Prerequisites & Assumptions

- Incident timeline. Blameless culture.

## Step-by-Step Workflow

1. Gather detailed timeline from logs/metrics.
2. Perform 5 Whys (Root Cause Analysis).
3. Draft postmortem document.
4. Create and track action items in Jira/Issues.

## Enterprise Rules & Standards

- **MUST**: Keep it blameless (focus on process, not people).
- **MUST**: Assign owners and due dates to action items.
- **SHOULD**: Share widely across engineering.
- **MUST NOT**: Hide root causes or sweep under rug.

## Examples

- **Bad**: "John broke prod by typing the wrong command."
- **Good**: "Deployment pipeline lacked validation step for config changes."

## Checklist

- [ ] Timeline complete.
- [ ] RCA (5 Whys) done.
- [ ] Action items tracked.

## Common Pitfalls

- Finger-pointing.
- Action items never completed.

## References

- [Google SRE Book: Postmortem Culture](https://sre.google/sre-book/postmortem-culture/)
