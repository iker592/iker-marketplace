#!/bin/bash
#
# Iker Marketplace - Claude Code Setup Script
# Installs skills for Claude Code
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKETPLACE_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}  Iker Marketplace Setup${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

# Detect target directory
detect_target() {
    local scope=$1

    if [[ "$scope" == "global" ]]; then
        echo "$HOME/.claude/skills"
    else
        echo ".claude/skills"
    fi
}

# Copy skills from a plugin to target directory
copy_plugin_skills() {
    local plugin_name=$1
    local target_dir=$2
    local plugin_skills_dir="$MARKETPLACE_ROOT/plugins/$plugin_name/skills"

    if [[ ! -d "$plugin_skills_dir" ]]; then
        print_warning "No skills found for plugin: $plugin_name"
        return 1
    fi

    # Copy each skill directory
    for skill_dir in "$plugin_skills_dir"/*/; do
        if [[ -d "$skill_dir" ]]; then
            skill_name=$(basename "$skill_dir")
            mkdir -p "$target_dir/$skill_name"
            cp -R "$skill_dir"* "$target_dir/$skill_name/"
            print_success "Copied skill: $skill_name"
        fi
    done
}

# Install skills
install_skills() {
    local scope=${1:-"project"}
    local target_dir=$(detect_target "$scope")

    print_info "Installing skills ($scope)..."
    mkdir -p "$target_dir"

    for plugin_dir in "$MARKETPLACE_ROOT/plugins"/*/; do
        if [[ -d "$plugin_dir" ]]; then
            plugin_name=$(basename "$plugin_dir")
            copy_plugin_skills "$plugin_name" "$target_dir"
        fi
    done

    print_success "Installation complete: $target_dir"
}

# List available plugins
list_plugins() {
    print_info "Available plugins:"
    for plugin_dir in "$MARKETPLACE_ROOT/plugins"/*/; do
        if [[ -d "$plugin_dir" ]]; then
            plugin_name=$(basename "$plugin_dir")
            plugin_json="$plugin_dir/.claude-plugin/plugin.json"
            if [[ -f "$plugin_json" ]]; then
                desc=$(grep -o '"description"[[:space:]]*:[[:space:]]*"[^"]*"' "$plugin_json" | sed 's/"description"[[:space:]]*:[[:space:]]*"\([^"]*\)"/\1/')
                echo "  • $plugin_name - $desc"
            else
                echo "  • $plugin_name"
            fi
        fi
    done
}

# Uninstall skills
uninstall() {
    local scope=${1:-"project"}
    local target_dir=$(detect_target "$scope")

    if [[ -d "$target_dir" ]]; then
        print_info "Removing skills from: $target_dir"
        for plugin_dir in "$MARKETPLACE_ROOT/plugins"/*/; do
            if [[ -d "$plugin_dir" ]]; then
                plugin_skills_dir="$plugin_dir/skills"
                for skill_dir in "$plugin_skills_dir"/*/; do
                    if [[ -d "$skill_dir" ]]; then
                        skill_name=$(basename "$skill_dir")
                        if [[ -d "$target_dir/$skill_name" ]]; then
                            rm -rf "$target_dir/$skill_name"
                            print_success "Removed: $skill_name"
                        fi
                    fi
                done
            fi
        done
    else
        print_warning "Directory not found: $target_dir"
    fi
}

# Show help
show_help() {
    echo "Usage: $0 [command] [scope]"
    echo ""
    echo "Commands:"
    echo "  install [scope]   Install skills (default command)"
    echo "  list              List available plugins"
    echo "  uninstall [scope] Remove installed skills"
    echo "  help              Show this help message"
    echo ""
    echo "Scope options:"
    echo "  project           Install to current directory (default)"
    echo "  global            Install to ~/.claude/skills/"
    echo ""
    echo "Examples:"
    echo "  $0                # Install to project"
    echo "  $0 global         # Install globally"
    echo "  $0 install global # Same as above"
    echo "  $0 uninstall      # Remove from project"
    echo "  $0 list           # List available plugins"
}

# Main
print_header

case "${1:-install}" in
    install|project|global)
        # Handle both "./setup.sh global" and "./setup.sh install global"
        if [[ "$1" == "project" || "$1" == "global" ]]; then
            install_skills "$1"
        else
            install_skills "${2:-project}"
        fi
        ;;
    list)
        list_plugins
        ;;
    uninstall)
        uninstall "${2:-project}"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac

echo ""
print_info "Done! Restart Claude Code to load the skills."
