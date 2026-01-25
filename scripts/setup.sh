#!/bin/bash
#
# Iker Marketplace - Cross-Platform Setup Script
# Installs skills for Claude Code and Cursor IDE
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

# Detect target directory (project or global)
detect_target() {
    local tool=$1
    local scope=$2

    if [[ "$scope" == "global" ]]; then
        if [[ "$tool" == "claude" ]]; then
            echo "$HOME/.claude/skills"
        else
            echo "$HOME/.cursor/skills"
        fi
    else
        # Project-level (current directory)
        if [[ "$tool" == "claude" ]]; then
            echo ".claude/skills"
        else
            echo ".cursor/skills"
        fi
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

# Install for Claude Code
install_claude() {
    local scope=${1:-"project"}
    local target_dir=$(detect_target "claude" "$scope")

    print_info "Installing for Claude Code ($scope)..."
    mkdir -p "$target_dir"

    for plugin_dir in "$MARKETPLACE_ROOT/plugins"/*/; do
        if [[ -d "$plugin_dir" ]]; then
            plugin_name=$(basename "$plugin_dir")
            copy_plugin_skills "$plugin_name" "$target_dir"
        fi
    done

    print_success "Claude Code installation complete: $target_dir"
}

# Install for Cursor
install_cursor() {
    local scope=${1:-"project"}
    local target_dir=$(detect_target "cursor" "$scope")

    print_info "Installing for Cursor IDE ($scope)..."
    print_warning "Note: Cursor symlinks have known issues. Using copy method."
    mkdir -p "$target_dir"

    for plugin_dir in "$MARKETPLACE_ROOT/plugins"/*/; do
        if [[ -d "$plugin_dir" ]]; then
            plugin_name=$(basename "$plugin_dir")
            copy_plugin_skills "$plugin_name" "$target_dir"
        fi
    done

    print_success "Cursor installation complete: $target_dir"
}

# Install for both tools
install_both() {
    local scope=${1:-"project"}
    install_claude "$scope"
    echo ""
    install_cursor "$scope"
}

# List available plugins
list_plugins() {
    print_info "Available plugins:"
    for plugin_dir in "$MARKETPLACE_ROOT/plugins"/*/; do
        if [[ -d "$plugin_dir" ]]; then
            plugin_name=$(basename "$plugin_dir")
            # Read description from plugin.json if available
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
    local tool=$1
    local scope=${2:-"project"}
    local target_dir=$(detect_target "$tool" "$scope")

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
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  claude [scope]    Install skills for Claude Code"
    echo "  cursor [scope]    Install skills for Cursor IDE"
    echo "  both [scope]      Install for both tools (default)"
    echo "  list              List available plugins"
    echo "  uninstall <tool> [scope]  Remove installed skills"
    echo "  help              Show this help message"
    echo ""
    echo "Scope options:"
    echo "  project           Install to current directory (default)"
    echo "  global            Install to user home directory"
    echo ""
    echo "Examples:"
    echo "  $0                        # Install both, project scope"
    echo "  $0 claude global          # Install Claude Code globally"
    echo "  $0 cursor project         # Install Cursor in project"
    echo "  $0 uninstall cursor       # Remove Cursor skills"
}

# Main
print_header

case "${1:-both}" in
    claude)
        install_claude "${2:-project}"
        ;;
    cursor)
        install_cursor "${2:-project}"
        ;;
    both)
        install_both "${2:-project}"
        ;;
    list)
        list_plugins
        ;;
    uninstall)
        if [[ -z "$2" ]]; then
            print_error "Please specify tool: claude or cursor"
            exit 1
        fi
        uninstall "$2" "${3:-project}"
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
print_info "Done! Restart your IDE to load the new skills."
