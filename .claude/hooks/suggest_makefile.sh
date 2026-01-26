#!/bin/bash
# Claude Code PreToolUse hook to block package manager commands
# and suggest using Makefile targets instead

# Read JSON from stdin
INPUT=$(cat)

# Extract the command being run
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Check if command starts with uv, npm, pnpm, or bun
if echo "$COMMAND" | grep -qE "^\s*(uv|npm|pnpm|bun)\s"; then
    echo "Blocked: Use Makefile targets instead of direct package manager commands." >&2
    echo "Run 'make help' or check the Makefile for available targets." >&2
    exit 2
fi

exit 0
