---
description: Manage daily tasks and to-do lists. Use when creating, viewing, completing, or organizing daily tasks.
---

# Daily To-Dos

A simple daily task management system.

## Capabilities

- **Add**: Create new tasks for today or future dates
- **List**: View tasks for today or any date
- **Complete**: Mark tasks as done
- **Prioritize**: Set task priorities (high, medium, low)
- **Rollover**: Move incomplete tasks to the next day

## Usage

Use `/daily-todos` to:
- Add a new task: "Add: Buy groceries"
- List today's tasks: "Show today"
- Complete a task: "Done: Buy groceries"
- View pending: "Show pending"

## Storage

Tasks are stored in `~/.daily-todos/` organized by date:
```
~/.daily-todos/
├── 2026-01-25.json
├── 2026-01-24.json
└── ...
```

## Task Format

Each task has:
- `id`: Unique identifier
- `text`: Task description
- `priority`: high | medium | low
- `status`: pending | completed
- `created`: Timestamp
- `completed`: Timestamp (if done)
