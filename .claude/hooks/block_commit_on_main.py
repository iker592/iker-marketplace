#!/usr/bin/env python3
"""
Claude Code PreToolUse hook to block git commits on main/master branch.
"""

import json
import os
import subprocess
import sys


def get_current_branch() -> str | None:
    """Get the current git branch name."""
    try:
        result = subprocess.run(
            ["git", "branch", "--show-current"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        return result.stdout.strip() if result.returncode == 0 else None
    except Exception:
        return None


def is_git_commit_command(arguments: dict) -> bool:
    """Check if the command is a git commit."""
    tool_input = arguments.get("tool_input", {})
    command = tool_input.get("command", "")
    return "git commit" in command


def main() -> int:
    # Try to get arguments from stdin (Claude Code passes hook input via stdin)
    try:
        arguments_json = sys.stdin.read()
    except Exception:
        arguments_json = "{}"


    try:
        arguments = json.loads(arguments_json)
    except json.JSONDecodeError:
        return 0  # Allow if we can't parse

    if not is_git_commit_command(arguments):
        return 0  # Not a git commit, allow

    current_branch = get_current_branch()

    if current_branch in ("main", "master"):
        print(f"Blocked: Cannot commit directly to {current_branch} branch")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
