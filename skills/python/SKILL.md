---
name: python
description: 'Modern Python: type hinting (Pydantic), async/asyncio, packaging. Trigger: "Python type hints", "async Python best practices", "FastAPI standards".'
metadata:
  category: language-specific
  tags: "python, type-hints, pydantic, asyncio, packaging"
---

# Modern Python Standards

## Purpose

Ensures Python code is typed, async-safe, and packaged correctly. This skill may edit Python code and packaging metadata inside the requested scope; it does NOT write docstrings (see `python-pydoc-engineer`) or redesign application architecture.

## When to Use / When NOT to Use

- **Use**: FastAPI services, data pipelines, modern CLI tools.
- **NOT**: Legacy Python 2 or untyped scripts.
- **NOT**: Docstring generation or audit (use `python-pydoc-engineer`).
- **NOT**: General smell removal or restructuring (use `code-quality-refactoring`).

## Prerequisites & Assumptions

- Python 3.11+.

### Scope & Context Resolution

- **Supported scopes**: project/repository, package/module directory, file, class, function. Default: the files the user names; if none, the project's Python sources.
- **Rule 1 - Explicit context in the prompt**: The user's stated requirements, constraints, Python versions, tooling and scope are authoritative. Apply this skill strictly within them. MUST NOT add assumptions or expand beyond them. If a user instruction conflicts with a skill rule, follow the user and state the deviation in one line, EXCEPT security/data-loss rules, which stay mandatory: flag the conflict instead.
- **Rule 2 - No extra context**: Use this skill's Purpose, workflow and rules as the sole context, at the default scope. MUST NOT import unrelated requirements or assumptions.
- **Rule 3 - Explicit scope**: Operate ONLY inside the named scope. Out-of-scope files may be READ as evidence but MUST NOT be modified; report out-of-scope observations as notes, never as changes. Widening scope requires explicit user approval.
- **Mutation boundary**: Edits limited to typing, validation, async and packaging changes inside the resolved scope. MUST NOT change behavior, public signatures of out-of-scope code, or the dependency manager unless asked.

## Step-by-Step Workflow

1. **Resolve scope and context**: Apply Scope & Context Resolution; state the resolved scope and mutation boundary in one line at the start of the output.
2. Use Pydantic V2 for data validation and serialization.
3. Apply type hints strictly (`mypy` / `pyright`).
4. Use `async`/`await` for I/O bound tasks.
5. Package with `Poetry` or `uv`.

Apply steps 2-5 only to code inside the resolved scope.

## Enterprise Rules & Standards (MUST / SHOULD / MUST NOT)

- **MUST**: Use type hints for all function signatures.
- **MUST**: Validate external inputs with Pydantic.
- **MUST**: Stay within the resolved scope; MUST NOT modify or expand beyond it without explicit user approval.
- **SHOULD**: Use `uv` or `Poetry` for dependency management.
- **MUST NOT**: Use bare `except Exception: pass`.
- **MUST NOT**: Convert sync code to async, or migrate packaging tools, outside the requested scope.

## Examples (good vs. bad, with realistic code or output)

- **Bad**: `def get_user(id): return db.query(id)`
- **Good**: `def get_user(id: int) -> User: ...`
- **Good (scoped)**: Prompt "add type hints to `services/users.py` only" -> annotate that module; note untyped functions in `services/orders.py`.
- **Bad (scope-expanding)**: Same prompt -> annotate the whole package and switch the project from pip to `uv`.

## Checklist (verifiable, copy-pasteable)

- [ ] Scope and context resolved and stated.
- [ ] No changes outside the resolved scope.
- [ ] Type hints present and checked.
- [ ] Pydantic used for inputs.
- [ ] Exceptions specific.

## Common Pitfalls

- Mutable default arguments (`def func(a=[])`).
- Blocking the async event loop with synchronous I/O.
- Scope creep: migrating packaging or converting unrelated modules to async.

## References (official docs, standards)

- [Real Python](https://realpython.com/)
- [Python typing documentation](https://docs.python.org/3/library/typing.html)
- [asyncio documentation](https://docs.python.org/3/library/asyncio.html)
- [Pydantic documentation](https://docs.pydantic.dev/latest/)
