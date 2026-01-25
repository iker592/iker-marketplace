#!/bin/bash
#
# Setup Claude Code global permissions and hooks
# This script merges the repository's Claude Code settings with your existing global settings.
#
# Usage: ./scripts/setup-permissions.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CLAUDE_DIR="$HOME/.claude"
GLOBAL_SETTINGS="$CLAUDE_DIR/settings.json"
GLOBAL_HOOKS_DIR="$CLAUDE_DIR/hooks"
REPO_SETTINGS="$REPO_DIR/.claude/settings.json"
REPO_HOOK="$REPO_DIR/.claude/hooks/block_commit_on_main.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}  Claude Code Global Permissions Setup${NC}"
echo -e "${BLUE}==========================================${NC}"
echo

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed.${NC}"
    echo "Install it with:"
    echo "  macOS:  brew install jq"
    echo "  Ubuntu: sudo apt-get install jq"
    exit 1
fi

# Check repo settings exist
if [ ! -f "$REPO_SETTINGS" ]; then
    echo -e "${RED}Error: Repository settings not found at $REPO_SETTINGS${NC}"
    exit 1
fi

# Create directories
mkdir -p "$CLAUDE_DIR"
mkdir -p "$GLOBAL_HOOKS_DIR"

# Backup existing settings if they exist
if [ -f "$GLOBAL_SETTINGS" ]; then
    BACKUP="$GLOBAL_SETTINGS.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$GLOBAL_SETTINGS" "$BACKUP"
    echo -e "${YELLOW}Backed up existing settings to:${NC}"
    echo "  $BACKUP"
    echo
fi

# Copy hook script
if [ -f "$REPO_HOOK" ]; then
    cp "$REPO_HOOK" "$GLOBAL_HOOKS_DIR/"
    chmod +x "$GLOBAL_HOOKS_DIR/block_commit_on_main.sh"
    echo -e "${GREEN}✓${NC} Installed hook script"
    echo "  $GLOBAL_HOOKS_DIR/block_commit_on_main.sh"
    echo
fi

# Create the hook config that uses the global path
HOOK_CONFIG='{
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "~/.claude/hooks/block_commit_on_main.sh",
          "statusMessage": "Checking branch for commit"
        }
      ]
    }
  ]
}'

# Extract permissions from repo settings
REPO_ALLOW=$(jq '.permissions.allow // []' "$REPO_SETTINGS")
REPO_DENY=$(jq '.permissions.deny // []' "$REPO_SETTINGS")
REPO_DEFAULT_MODE=$(jq -r '.permissions.defaultMode // "acceptEdits"' "$REPO_SETTINGS")

# Merge settings
if [ -f "$GLOBAL_SETTINGS" ]; then
    echo "Merging with existing settings..."

    # Read existing settings
    EXISTING=$(cat "$GLOBAL_SETTINGS")

    # Get existing permissions (if any)
    EXISTING_ALLOW=$(echo "$EXISTING" | jq '.permissions.allow // []')
    EXISTING_DENY=$(echo "$EXISTING" | jq '.permissions.deny // []')

    # Get existing hooks (if any)
    EXISTING_HOOKS=$(echo "$EXISTING" | jq '.hooks // {}')

    # Merge allow arrays (unique values)
    MERGED_ALLOW=$(jq -n --argjson a "$EXISTING_ALLOW" --argjson b "$REPO_ALLOW" '$a + $b | unique')

    # Merge deny arrays (unique values)
    MERGED_DENY=$(jq -n --argjson a "$EXISTING_DENY" --argjson b "$REPO_DENY" '$a + $b | unique')

    # Merge hooks (repo hooks take precedence for PreToolUse)
    MERGED_HOOKS=$(jq -n --argjson existing "$EXISTING_HOOKS" --argjson new "$HOOK_CONFIG" '$existing * $new')

    # Build final settings: start with existing, override hooks and permissions
    FINAL=$(echo "$EXISTING" | jq \
        --argjson hooks "$MERGED_HOOKS" \
        --argjson allow "$MERGED_ALLOW" \
        --argjson deny "$MERGED_DENY" \
        --arg defaultMode "$REPO_DEFAULT_MODE" \
        '. + {hooks: $hooks, permissions: {defaultMode: $defaultMode, allow: $allow, deny: $deny}}')
else
    echo "Creating new settings file..."

    # Create new settings with hooks and permissions
    FINAL=$(jq -n \
        --argjson hooks "$HOOK_CONFIG" \
        --argjson allow "$REPO_ALLOW" \
        --argjson deny "$REPO_DENY" \
        --arg defaultMode "$REPO_DEFAULT_MODE" \
        '{hooks: $hooks, permissions: {defaultMode: $defaultMode, allow: $allow, deny: $deny}}')
fi

# Write final settings
echo "$FINAL" | jq '.' > "$GLOBAL_SETTINGS"

echo -e "${GREEN}✓${NC} Settings written to:"
echo "  $GLOBAL_SETTINGS"
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
echo "  • Cannot commit on main/master (hook)"
echo "  • Cannot merge PRs via CLI"
echo "  • Cannot force push"
echo "  • Cannot run destructive commands (rm, reset, etc.)"
echo
echo -e "${GREEN}Convenience settings:${NC}"
echo "  • Auto-accept file edits (no confirmation prompts)"
echo
echo -e "${YELLOW}⚠ Restart Claude Code for changes to take effect.${NC}"
echo
echo "Done!"
