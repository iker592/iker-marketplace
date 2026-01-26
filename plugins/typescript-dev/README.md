# TypeScript Development Plugin

Standards and patterns for TypeScript/React development.

## Stack

| Category | Tool |
|----------|------|
| Package Manager | Bun |
| Build Tool | Vite |
| UI Framework | React + TypeScript |
| Styling | Tailwind CSS + shadcn/ui |
| State Management | Zustand |
| Routing | React Router |
| Unit Testing | Vitest |
| E2E Testing | Playwright |
| Linting/Formatting | Biome |

## Installation

```bash
iker setup-local   # or iker setup-global
```

## Usage

The skill is automatically loaded when working with TypeScript/React code. It provides:

- Project setup patterns
- Component structure guidelines
- State management with Zustand
- Testing patterns (Vitest + Playwright)
- Standard Makefile targets

## Key Commands

```bash
make setup    # First time setup
make dev      # Start dev server
make test     # Run unit tests
make e2e      # Run E2E tests
make fix      # Fix linting/formatting
make all      # Run fix, test, build
```
