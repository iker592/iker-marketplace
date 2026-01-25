# Claude E-Mart Testing Plugin

Test and run the Claude E-Mart chat application with FastAPI backend and React frontend.

## Features

- Start backend and frontend servers
- Automated UI testing with agent-browser
- Verification checklist for app functionality

## Project Location

`/Users/iker/dev/claude-e-mart/`

## Quick Start

### Backend (FastAPI)
```bash
cd /Users/iker/dev/claude-e-mart/agent && uv run uvicorn server:app --reload --port 8000
```

### Frontend (React + Vite)
```bash
cd /Users/iker/dev/claude-e-mart/ui && ~/.bun/bin/bun dev
```

## Testing with agent-browser

```bash
agent-browser open http://localhost:5173
agent-browser snapshot -i
agent-browser fill @e1 "Hello"
agent-browser click @e2
agent-browser screenshot /tmp/screenshot.png --full
```

## Installation

```bash
/plugin install claude-e-mart-testing@iker-marketplace
```
