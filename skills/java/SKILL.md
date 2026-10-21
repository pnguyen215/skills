---
name: java
description: 'Modern Java standards: Spring Boot 3, Records, Virtual Threads, GraalVM. Trigger: "Java 21 best practices", "Spring Boot conventions", "modern Java".'
metadata:
  category: language-specific
  tags: "java, spring-boot, records, virtual-threads, graalvm"
---

# Modern Java Standards

## Purpose

Leverages modern Java features and frameworks securely.

## When to Use / When NOT to Use

- **Use**: Spring Boot 3 services, enterprise apps, high-concurrency I/O.
- **NOT**: Legacy Java EE or Java 8 codebases.

## Prerequisites & Assumptions

- Java 21+ (LTS).

## Step-by-Step Workflow

1. Use `record` types for DTOs and immutable data.
2. Use Virtual Threads (`ExecutorService.newVirtualThreadPerTaskExecutor`) for I/O.
3. Apply Spring Boot 3 conventions and AOT compilation.
4. Use `Optional` correctly (never as field/parameter).

## Enterprise Rules & Standards

- **MUST**: Use Records for immutable data transfer objects.
- **MUST**: Prefer Virtual Threads over platform threads for blocking I/O.
- **SHOULD**: Use Spring Data JPA safely (avoid N+1).
- **MUST NOT**: Return `null` instead of `Optional` or empty collections.

## Examples

- **Bad**: `class UserDTO { String name; }`
- **Good**: `record UserDTO(String name) {}`

## Checklist

- [ ] Records used for DTOs.
- [ ] Virtual Threads for I/O.
- [ ] No null returns.

## Common Pitfalls

- Blocking virtual threads with `synchronized` blocks.
- N+1 queries in Hibernate/JPA.

## References

- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
