# Apple Notes Plugin

Read, create, and manage Apple Notes on macOS via AppleScript.

## Features

- List all folders and notes
- Read note content
- Create new notes (with markdown support)
- Append to existing notes
- Export notes to markdown
- Sync notes to MemoryBench

## Triggers

- "show my notes"
- "read note X"
- "create a note"
- "add to my todo"
- "list my note folders"
- "convert this markdown to a note"
- "export note to markdown"
- "sync to memorybench"

## Scripts

| Script | Purpose |
|--------|---------|
| `md_to_note.py` | Convert markdown file to Apple Note |
| `note_to_md.py` | Export Apple Note to markdown |
| `sync_to_memorybench.py` | Sync notes to MemoryBench directory |

## Requirements

- macOS with Notes app
- Python 3.12+ with uv
- `markdown` package (installed automatically via `uv run --with markdown`)

## Installation

```bash
/plugin install apple-notes@iker-marketplace
```
