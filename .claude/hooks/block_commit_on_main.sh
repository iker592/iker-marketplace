#!/bin/bash
# Claude Code PreToolUse hook to block git commits on main/master branch

# Read JSON from stdin
INPUT=$(cat)

# Check if command contains "git commit"
if echo "$INPUT" | grep -q '"command".*git commit'; then
    # Check current branch
    BRANCH=$(git branch --show-current 2>/dev/null)

    if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
        echo "Blocked: Cannot commit directly to $BRANCH branch" >&2
        exit 2
    fi
fi

exit 0
