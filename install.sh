#!/bin/bash
#
# iker installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/iker592/iker-marketplace/main/install.sh | bash
#

set -e

REPO_URL="https://github.com/iker592/iker-marketplace"
IKER_HOME="${IKER_HOME:-$HOME/.iker}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}→${NC} $1"; }

echo -e "${BLUE}"
echo "  _ _             "
echo " (_) | _____ _ __ "
echo " | | |/ / _ \\ '__|"
echo " | |   <  __/ |   "
echo " |_|_|\\_\\___|_|   "
echo -e "${NC}"
echo "  Claude Code Configuration CLI"
echo

# Check for git
if ! command -v git &> /dev/null; then
    print_error "git is required but not installed."
    exit 1
fi

# Clone or update repository
if [ -d "$IKER_HOME" ]; then
    print_info "Updating existing installation..."
    cd "$IKER_HOME"
    git pull --quiet origin main
    print_success "Updated iker"
else
    print_info "Installing iker..."
    git clone --quiet "$REPO_URL.git" "$IKER_HOME"
    print_success "Cloned repository to $IKER_HOME"
fi

# Make executable
chmod +x "$IKER_HOME/bin/iker"
chmod +x "$IKER_HOME/scripts/"*.sh 2>/dev/null || true
chmod +x "$IKER_HOME/.claude/hooks/"*.sh 2>/dev/null || true

# Create symlink
BIN_DIR=""
if [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then
    BIN_DIR="/usr/local/bin"
elif [ -d "$HOME/.local/bin" ]; then
    BIN_DIR="$HOME/.local/bin"
else
    mkdir -p "$HOME/.local/bin"
    BIN_DIR="$HOME/.local/bin"
fi

# Remove old symlink if exists
[ -L "$BIN_DIR/iker" ] && rm -f "$BIN_DIR/iker"

# Create symlink
ln -sf "$IKER_HOME/bin/iker" "$BIN_DIR/iker"
print_success "Linked iker to $BIN_DIR/iker"

# Check if bin dir is in PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo
    print_warning "$BIN_DIR is not in your PATH."
    echo
    echo "Add this to your shell config (~/.bashrc, ~/.zshrc, etc.):"
    echo
    echo "  export PATH=\"\$PATH:$BIN_DIR\""
    echo
    echo "Then restart your terminal or run: source ~/.zshrc"
    echo
fi

echo
print_success "Installation complete!"
echo
echo "Next steps:"
echo "  1. Run 'iker setup' to configure Claude Code"
echo "  2. Restart Claude Code for changes to take effect"
echo
