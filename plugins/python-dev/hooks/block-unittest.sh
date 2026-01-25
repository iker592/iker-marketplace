#!/bin/bash
# Block unittest imports in Python files - enforce pytest

set -euo pipefail

input=$(cat)

# Get the file path and content being written
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.file // ""')
new_content=$(echo "$input" | jq -r '.tool_input.content // .tool_input.new_string // ""')

# Only check Python files
if [[ ! "$file_path" == *.py ]]; then
  exit 0
fi

# Check for unittest imports
if echo "$new_content" | grep -qE "^import unittest|^from unittest import"; then
  echo "Blocked: Use pytest instead of unittest. See python-skill for patterns." >&2
  exit 2
fi

exit 0
