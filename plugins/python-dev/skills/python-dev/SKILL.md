---
name: Python Development
description: This skill should be used when the user asks to "create a Python project", "add a dependency", "write a FastAPI endpoint", "create an MCP server", "write tests", "run pytest", "fix linting", "use uv", or works on any Python code. Covers uv, FastAPI, FastMCP, pytest, ruff, and standard Makefile targets.
---

# Python Development Standards

Standards for Python development in this organization. All projects use uv for package management, FastAPI for web services, FastMCP for MCP servers, pytest for testing (never unittest), and ruff for linting.

## Core Requirements

- **Python 3.12+** - Minimum version for all projects
- **uv** - Package management (not pip, poetry, or conda)
- **pytest** - Testing framework (never use unittest)
- **ruff** - Linting and formatting

## uv Commands

### Project Setup

```bash
uv init project-name        # Create new project
uv python install 3.12      # Install Python version
uv venv                     # Create virtual environment
uv sync                     # Install dependencies from pyproject.toml
```

### Dependency Management

```bash
uv add fastapi              # Add dependency
uv add pytest --dev         # Add dev dependency
uv remove package-name      # Remove dependency
uv lock                     # Update lock file
uv run python script.py     # Run with project environment
```

### pyproject.toml Structure

```toml
[project]
name = "project-name"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn>=0.32.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "ruff>=0.8.0",
]

[tool.ruff]
line-length = 120
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "I", "UP"]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
```

## FastAPI Patterns

### Basic Application

```python
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel

app = FastAPI(title="Service Name")

class ItemCreate(BaseModel):
    name: str
    value: int

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.post("/items", status_code=201)
async def create_item(item: ItemCreate):
    return {"id": 1, **item.model_dump()}
```

### Dependency Injection

```python
from typing import Annotated
from fastapi import Depends

async def get_db():
    db = Database()
    try:
        yield db
    finally:
        await db.close()

DB = Annotated[Database, Depends(get_db)]

@app.get("/items/{item_id}")
async def get_item(item_id: int, db: DB):
    return await db.get_item(item_id)
```

### Middleware

```python
from fastapi import Request
from fastapi.middleware.cors import CORSMiddleware
import time

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.middleware("http")
async def add_timing(request: Request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    response.headers["X-Process-Time"] = str(time.perf_counter() - start)
    return response
```

### Error Handling

```python
from fastapi import HTTPException
from fastapi.responses import JSONResponse

class NotFoundError(Exception):
    def __init__(self, resource: str, id: int):
        self.resource = resource
        self.id = id

@app.exception_handler(NotFoundError)
async def not_found_handler(request, exc: NotFoundError):
    return JSONResponse(
        status_code=404,
        content={"error": f"{exc.resource} {exc.id} not found"}
    )

# Usage
raise NotFoundError("Item", item_id)
```

## FastMCP Server Setup

### Basic MCP Server

```python
from fastmcp import FastMCP

mcp = FastMCP("service-name")

@mcp.tool()
def get_data(query: str) -> str:
    """Retrieve data based on query."""
    return f"Results for: {query}"

@mcp.resource("data://{item_id}")
def get_item(item_id: str) -> str:
    """Get item by ID."""
    return f"Item: {item_id}"

if __name__ == "__main__":
    mcp.run()
```

### Running MCP Server

```bash
uv run python server.py              # stdio mode (default)
uv run python server.py --sse        # SSE mode for web
```

## pytest Patterns

### Basic Tests

```python
import pytest
from app import create_item, get_item

def test_create_item():
    result = create_item(name="test", value=42)
    assert result["name"] == "test"
    assert result["value"] == 42

def test_get_item_not_found():
    with pytest.raises(NotFoundError):
        get_item(999)
```

### Fixtures

```python
import pytest
from fastapi.testclient import TestClient
from app import app

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def sample_item():
    return {"name": "test", "value": 42}

@pytest.fixture
def db():
    database = TestDatabase()
    database.setup()
    yield database
    database.teardown()

def test_create_endpoint(client, sample_item):
    response = client.post("/items", json=sample_item)
    assert response.status_code == 201
```

### Mocking

```python
from unittest.mock import Mock, patch, AsyncMock

def test_with_mock():
    mock_db = Mock()
    mock_db.get_item.return_value = {"id": 1, "name": "test"}

    result = service.get_item(1, db=mock_db)

    mock_db.get_item.assert_called_once_with(1)
    assert result["name"] == "test"

@patch("app.external_api")
def test_with_patch(mock_api):
    mock_api.fetch.return_value = {"data": "value"}
    result = process_data()
    assert result == "value"

@pytest.mark.asyncio
async def test_async_mock():
    mock_client = AsyncMock()
    mock_client.get.return_value = {"status": "ok"}
    result = await fetch_data(mock_client)
    assert result["status"] == "ok"
```

### Parameterization

```python
import pytest

@pytest.mark.parametrize("input,expected", [
    (1, 2),
    (2, 4),
    (3, 6),
])
def test_double(input, expected):
    assert double(input) == expected

@pytest.mark.parametrize("name,valid", [
    ("valid_name", True),
    ("", False),
    ("a" * 100, False),
])
def test_validate_name(name, valid):
    assert validate_name(name) == valid
```

## ruff

Use ruff for all linting and formatting:

```bash
uv run ruff check .          # Check for issues
uv run ruff check --fix .    # Auto-fix issues
uv run ruff format .         # Format code
```

## Standard Makefile

All projects must have a Makefile with these targets:

```makefile
.PHONY: setup sync local test fix evals all

setup:
	curl -LsSf https://astral.sh/uv/install.sh | sh
	uv python install 3.12
	uv venv
	uv sync

sync:
	uv sync

local:
	uv run uvicorn app:app --reload --port 8000

test:
	uv run pytest

fix:
	uv run ruff check --fix .
	uv run ruff format .

evals:
	uv run pytest tests/evals/ -v

all: fix test evals
```

### Target Usage

| Target | When to Use |
|--------|-------------|
| `make setup` | First time cloning the repo |
| `make sync` | After pulling changes with new dependencies |
| `make local` | Start the application for development |
| `make test` | Run all tests |
| `make fix` | Before committing - fixes linting and formatting |
| `make evals` | Run AI evaluation tests |
| `make all` | Before pushing - runs fix, test, evals |

## Project Structure

Typical project layout:

```
project-name/
├── pyproject.toml
├── Makefile
├── README.md
├── app/
│   ├── __init__.py
│   ├── main.py          # FastAPI app
│   ├── routes/
│   ├── models/
│   └── services/
├── tests/
│   ├── __init__.py
│   ├── conftest.py      # Shared fixtures
│   ├── test_routes.py
│   └── evals/           # AI evaluation tests
│       └── test_evals.py
└── scripts/
```

## Key Rules

1. **Never use unittest** - Always pytest
2. **Never use pip directly** - Always uv
3. **Always have Makefile** - With standard targets
4. **Python 3.12+** - Minimum version
5. **Run `make fix` before committing** - Keep code clean
6. **Run `make all` before pushing** - Ensure everything passes
