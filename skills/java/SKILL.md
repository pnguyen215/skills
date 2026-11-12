---
name: java
description: 'Modern Java standards: Spring Boot 3, Records, Virtual Threads, GraalVM. Trigger: "Java 21 best practices", "Spring Boot conventions", "modern Java".'
metadata:
  category: language-specific
  tags: "java, spring-boot, records, virtual-threads, graalvm"
---

# Modern Java Standards

## Purpose

Leverages modern Java features and frameworks securely. Responsibility boundary: writes and reviews Java code against these standards within the named scope; does NOT write JavaDoc (separate skill) and does NOT migrate or restructure code outside the scope.

## When to Use / When NOT to Use

- **Use**: Spring Boot 3 services, enterprise apps, high-concurrency I/O.
- **NOT**: Legacy Java EE or Java 8 codebases.
- **NOT**: Writing or auditing JavaDoc (use `java-javadoc-engineer`).

## Prerequisites & Assumptions

- Java 21+ (LTS).

### Scope & Context Resolution

- **Supported scopes**: project/repository, module/package, file, class/record, method. Default: the class or method the user names; if none, the code snippet or change under discussion.
- **Rule 1 - Explicit context**: user-stated requirements, constraints, versions, targets and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory (flag the conflict instead).
- **Rule 2 - No extra context**: use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: operate ONLY inside the named scope. Out-of-scope files MAY be read as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: edits limited to Java code inside the resolved scope; a review request is analysis-only and MUST NOT edit code.

## Step-by-Step Workflow

1. **Resolve scope and context**: apply the section above; state the resolved scope and mutation boundary in one line at the start of the output.
2. Use `record` types for DTOs and immutable data.
3. Use Virtual Threads (`ExecutorService.newVirtualThreadPerTaskExecutor`) for I/O.
4. Apply Spring Boot 3 conventions and AOT compilation.
5. Use `Optional` correctly (never as field/parameter).

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Use Records for immutable data transfer objects.
- **MUST**: Prefer Virtual Threads over platform threads for blocking I/O.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use Spring Data JPA safely (avoid N+1).
- **MUST NOT**: Return `null` instead of `Optional` or empty collections.
- **MUST NOT**: Convert classes outside the named scope to records or change their public API.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `class UserDTO { String name; }`
- **Good**: `record UserDTO(String name) {}`
- **Good (scope)**: Prompt "convert only `UserDTO` to a record" -> change `UserDTO`; note other mutable DTOs without touching them.
- **Bad (scope)**: Same prompt -> converting every DTO in the module and upgrading Spring Boot.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Records used for DTOs.
- [ ] Virtual Threads for I/O.
- [ ] No null returns.

## Common Pitfalls

- Blocking virtual threads with `synchronized` blocks.
- N+1 queries in Hibernate/JPA.
- Scope creep: modernizing the whole module when one class was named.

## References (official docs, standards)

- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [JEP 444: Virtual Threads](https://openjdk.org/jeps/444)
- [JEP 395: Records](https://openjdk.org/jeps/395)
