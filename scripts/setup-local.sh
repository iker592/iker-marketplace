#!/bin/bash
#
# Setup Claude Code local project settings
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
LOCAL_HOOKS_DIR="$CLAUDE_DIR/hooks"
IKER_SETTINGS="$IKER_DIR/.claude/settings.json"
IKER_HOOKS_DIR="$IKER_DIR/.claude/hooks"
IKER_STATUSLINE="$IKER_DIR/.claude/statusline.sh"

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

# Create directories
mkdir -p "$CLAUDE_DIR"
mkdir -p "$LOCAL_HOOKS_DIR"

# Add local files to .gitignore if not already there
GITIGNORE="$PROJECT_DIR/.gitignore"
GITIGNORE_ENTRIES=(
    ".claude/settings.local.json"
    ".claude/hooks/"
    ".claude/statusline.sh"
)

if [ -f "$GITIGNORE" ]; then
    NEEDS_HEADER=true
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        if ! grep -qF "$entry" "$GITIGNORE" 2>/dev/null; then
            if $NEEDS_HEADER; then
                echo "" >> "$GITIGNORE"
                echo "# Claude Code local settings (personal, not shared)" >> "$GITIGNORE"
                NEEDS_HEADER=false
            fi
            echo "$entry" >> "$GITIGNORE"
        fi
    done
    if ! $NEEDS_HEADER; then
        echo -e "${GREEN}✓${NC} Updated .gitignore with local Claude Code files"
    fi
else
    echo "# Claude Code local settings (personal, not shared)" > "$GITIGNORE"
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        echo "$entry" >> "$GITIGNORE"
    done
    echo -e "${GREEN}✓${NC} Created .gitignore with local Claude Code files"
fi

# Copy hook scripts
if [ -d "$IKER_HOOKS_DIR" ]; then
    for hook_file in "$IKER_HOOKS_DIR"/*.sh; do
        if [ -f "$hook_file" ]; then
            hook_name=$(basename "$hook_file")
            cp "$hook_file" "$LOCAL_HOOKS_DIR/"
            chmod +x "$LOCAL_HOOKS_DIR/$hook_name"
            echo -e "${GREEN}✓${NC} Installed hook: $hook_name"
        fi
    done
fi

# Copy statusline script
if [ -f "$IKER_STATUSLINE" ]; then
    cp "$IKER_STATUSLINE" "$CLAUDE_DIR/statusline.sh"
    chmod +x "$CLAUDE_DIR/statusline.sh"
    echo -e "${GREEN}✓${NC} Installed statusline script"
    echo "  $CLAUDE_DIR/statusline.sh"
fi
echo

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
        },
        {
          "type": "command",
          "command": ".claude/hooks/suggest_makefile.sh",
          "statusMessage": "Checking for Makefile targets"
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
    EXISTING_HOOKS=$(echo "$EXISTING" | jq '.hooks // {}')

    # Merge arrays (unique values)
    MERGED_ALLOW=$(jq -n --argjson a "$EXISTING_ALLOW" --argjson b "$IKER_ALLOW" '$a + $b | unique')
    MERGED_DENY=$(jq -n --argjson a "$EXISTING_DENY" --argjson b "$IKER_DENY" '$a + $b | unique')
    MERGED_HOOKS=$(jq -n --argjson existing "$EXISTING_HOOKS" --argjson new "$HOOK_CONFIG" '$existing * $new')

    # Build final settings
    FINAL=$(echo "$EXISTING" | jq \
        --argjson hooks "$MERGED_HOOKS" \
        --argjson allow "$MERGED_ALLOW" \
        --argjson deny "$MERGED_DENY" \
        --arg defaultMode "$IKER_DEFAULT_MODE" \
        '. + {hooks: $hooks, statusLine: {type: "command", command: ".claude/statusline.sh"}, permissions: {defaultMode: $defaultMode, allow: $allow, deny: $deny}}')
else
    echo "Creating new local settings file..."

    # Create new settings with hooks and permissions
    FINAL=$(jq -n \
        --argjson hooks "$HOOK_CONFIG" \
        --argjson allow "$IKER_ALLOW" \
        --argjson deny "$IKER_DENY" \
        --arg defaultMode "$IKER_DEFAULT_MODE" \
        '{hooks: $hooks, statusLine: {type: "command", command: ".claude/statusline.sh"}, permissions: {defaultMode: $defaultMode, allow: $allow, deny: $deny}}')
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
echo "  • Cannot commit on main/master branches (hook)"
echo "  • Cannot use uv/npm/pnpm/bun directly - use Makefile (hook)"
echo "  • Cannot push to main/master branches"
echo "  • Cannot merge PRs via CLI"
echo "  • Cannot force push"
echo "  • Cannot run destructive commands (rm, reset, etc.)"
echo
echo -e "${GREEN}Convenience settings:${NC}"
echo "  • Auto-accept file edits (no confirmation prompts)"
echo "  • Status line showing model, context usage, and progress bar"
echo
echo -e "${YELLOW}Note:${NC} These files are gitignored and only apply to YOU in this project."
echo -e "      For shared team settings, edit ${BLUE}.claude/settings.json${NC}"
echo
echo -e "${YELLOW}⚠ Restart Claude Code for changes to take effect.${NC}"
echo
echo "Done!"
