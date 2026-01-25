# Python Dev Plugin

Python development standards plugin for Claude Code.

## Tech Stack

- **uv** - Package management
- **FastAPI** - Web framework
- **FastMCP** - MCP server development
- **pytest** - Testing (never unittest)
- **ruff** - Linting & formatting
- **Python 3.12+** - Minimum version

## Components

### Skill: python-dev

Auto-activates for Python development questions. Covers:
- uv commands
- FastAPI patterns (dependency injection, middleware, error handling)
- FastMCP server setup
- pytest (fixtures, mocking, parameterization)
- Standard Makefile targets

### Agent: local-tester

Tests your locally running FastAPI app:
- Checks if app is running on localhost:8000
- Discovers endpoints via `/openapi.json`
- Queries and validates responses

### Hook: block-unittest

Prevents use of unittest library. Enforces pytest.

## Standard Makefile Targets

All projects should have:

| Target | Purpose |
|--------|---------|
| `make setup` | First-time setup (install uv, python) |
| `make sync` | Download dependencies |
| `make local` | Start app locally |
| `make test` | Run pytest |
| `make fix` | Format and lint with ruff |
| `make evals` | Run AI evaluations |
| `make all` | Run fix, test, evals |

## Installation

```bash
/plugin install python-dev@iker-marketplace
```
