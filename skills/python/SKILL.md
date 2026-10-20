---
name: python
description: 'Modern Python: type hinting (Pydantic), async/asyncio, packaging. Trigger: "Python type hints", "async Python best practices", "FastAPI standards".'
metadata:
  category: language-specific
---

# Modern Python Standards

## Purpose

Ensures Python code is typed, async-safe, and packaged correctly.

## When to Use / When NOT to Use

- **Use**: FastAPI services, data pipelines, modern CLI tools.
- **NOT**: Legacy Python 2 or untyped scripts.

## Prerequisites & Assumptions

- Python 3.11+.

## Step-by-Step Workflow

1. Use Pydantic V2 for data validation and serialization.
2. Apply type hints strictly (`mypy` / `pyright`).
3. Use `async`/`await` for I/O bound tasks.
4. Package with `Poetry` or `uv`.

## Enterprise Rules & Standards

- **MUST**: Use type hints for all function signatures.
- **MUST**: Validate external inputs with Pydantic.
- **SHOULD**: Use `uv` or `Poetry` for dependency management.
- **MUST NOT**: Use bare `except Exception: pass`.

## Examples

- **Bad**: `def get_user(id): return db.query(id)`
- **Good**: `def get_user(id: int) -> User: ...`

## Checklist

- [ ] Type hints present and checked.
- [ ] Pydantic used for inputs.
- [ ] Exceptions specific.

## Common Pitfalls

- Mutable default arguments (`def func(a=[])`).
- Blocking the async event loop with synchronous I/O.

## References

- [Real Python](https://realpython.com/)
