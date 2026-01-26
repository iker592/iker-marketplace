#!/bin/bash
#
# Setup Claude Code local project permissions
# Creates .claude/settings.local.json in the current project directory.
# This file is gitignored and applies only to this project for you.
#
# Usage: ./scripts/setup-local.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IKER_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_DIR="$(pwd)"
CLAUDE_DIR="$PROJECT_DIR/.claude"
LOCAL_SETTINGS="$CLAUDE_DIR/settings.local.json"
IKER_SETTINGS="$IKER_DIR/.claude/settings.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}  Claude Code Local Project Setup${NC}"
echo -e "${BLUE}==========================================${NC}"
echo
echo -e "Project: ${GREEN}$PROJECT_DIR${NC}"
echo

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed.${NC}"
    echo "Install it with:"
    echo "  macOS:  brew install jq"
    echo "  Ubuntu: sudo apt-get install jq"
    exit 1
fi

# Check iker settings exist (source of permissions)
if [ ! -f "$IKER_SETTINGS" ]; then
    echo -e "${RED}Error: iker settings not found at $IKER_SETTINGS${NC}"
    exit 1
fi

# Create .claude directory if it doesn't exist
mkdir -p "$CLAUDE_DIR"

# Add settings.local.json to .gitignore if not already there
GITIGNORE="$PROJECT_DIR/.gitignore"
if [ -f "$GITIGNORE" ]; then
    if ! grep -q "^\.claude/settings\.local\.json$" "$GITIGNORE" 2>/dev/null; then
        echo "" >> "$GITIGNORE"
        echo "# Claude Code local settings (personal, not shared)" >> "$GITIGNORE"
        echo ".claude/settings.local.json" >> "$GITIGNORE"
        echo -e "${GREEN}✓${NC} Added settings.local.json to .gitignore"
    fi
else
    echo "# Claude Code local settings (personal, not shared)" > "$GITIGNORE"
    echo ".claude/settings.local.json" >> "$GITIGNORE"
    echo -e "${GREEN}✓${NC} Created .gitignore with settings.local.json"
fi

# Backup existing local settings if they exist
if [ -f "$LOCAL_SETTINGS" ]; then
    BACKUP="$LOCAL_SETTINGS.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$LOCAL_SETTINGS" "$BACKUP"
    echo -e "${YELLOW}Backed up existing local settings to:${NC}"
    echo "  $BACKUP"
    echo
fi

# Extract permissions from iker settings
IKER_ALLOW=$(jq '.permissions.allow // []' "$IKER_SETTINGS")
IKER_DENY=$(jq '.permissions.deny // []' "$IKER_SETTINGS")
IKER_DEFAULT_MODE=$(jq -r '.permissions.defaultMode // "acceptEdits"' "$IKER_SETTINGS")

# Create hook config with relative path (for project-local use)
HOOK_CONFIG='{
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": ".claude/hooks/block_commit_on_main.sh",
          "statusMessage": "Checking branch for commit"
        }
      ]
    }
  ]
}'

# Merge or create settings
if [ -f "$LOCAL_SETTINGS" ]; then
    echo "Merging with existing local settings..."

    EXISTING=$(cat "$LOCAL_SETTINGS")
    EXISTING_ALLOW=$(echo "$EXISTING" | jq '.permissions.allow // []')
    EXISTING_DENY=$(echo "$EXISTING" | jq '.permissions.deny // []')

    # Merge arrays (unique values)
    MERGED_ALLOW=$(jq -n --argjson a "$EXISTING_ALLOW" --argjson b "$IKER_ALLOW" '$a + $b | unique')
    MERGED_DENY=$(jq -n --argjson a "$EXISTING_DENY" --argjson b "$IKER_DENY" '$a + $b | unique')

    # Build final settings
    FINAL=$(echo "$EXISTING" | jq \
        --argjson allow "$MERGED_ALLOW" \
        --argjson deny "$MERGED_DENY" \
        --arg defaultMode "$IKER_DEFAULT_MODE" \
        '. + {permissions: {defaultMode: $defaultMode, allow: $allow, deny: $deny}}')
else
    echo "Creating new local settings file..."

    # Create new settings (no hooks in local - they come from shared settings.json)
    FINAL=$(jq -n \
        --argjson allow "$IKER_ALLOW" \
        --argjson deny "$IKER_DENY" \
        --arg defaultMode "$IKER_DEFAULT_MODE" \
        '{permissions: {defaultMode: $defaultMode, allow: $allow, deny: $deny}}')
fi

# Write final settings
echo "$FINAL" | jq '.' > "$LOCAL_SETTINGS"

echo -e "${GREEN}✓${NC} Local settings written to:"
echo "  $LOCAL_SETTINGS"
echo

# Show summary
echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}==========================================${NC}"
echo
echo -e "${GREEN}Permissions configured:${NC}"
echo "  Allow list: $(echo "$FINAL" | jq '.permissions.allow | length') rules"
echo "  Deny list:  $(echo "$FINAL" | jq '.permissions.deny | length') rules"
echo
echo -e "${GREEN}Key protections enabled:${NC}"
echo "  • Cannot push to main/master branches"
echo "  • Cannot merge PRs via CLI"
echo "  • Cannot force push"
echo "  • Cannot run destructive commands (rm, reset, etc.)"
echo
echo -e "${GREEN}Convenience settings:${NC}"
echo "  • Auto-accept file edits (no confirmation prompts)"
echo
echo -e "${YELLOW}Note:${NC} This file is gitignored and only applies to YOU in this project."
echo -e "      For shared team settings, edit ${BLUE}.claude/settings.json${NC}"
echo
echo -e "${YELLOW}⚠ Restart Claude Code for changes to take effect.${NC}"
echo
echo "Done!"
