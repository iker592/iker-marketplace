# Setup Guide

This guide explains how to install Iker Marketplace plugins for **Claude Code**.

## Quick Start

```bash
# Clone the marketplace
git clone https://github.com/iker592/iker-marketplace.git
cd iker-marketplace

# Install skills (project-level)
./scripts/setup.sh

# Or install globally
./scripts/setup.sh global
```

---

## Installation Options

### Option 1: Using Plugin System (Recommended)

```bash
# Add the marketplace
/plugin marketplace add iker592/iker-marketplace

# Install specific plugins
/plugin install second-brain@iker-marketplace
/plugin install daily-todos@iker-marketplace

# List installed plugins
/plugin list
```

### Option 2: Using Setup Script

```bash
# Project-level (in your repo's .claude/skills/)
./scripts/setup.sh project

# Global (in ~/.claude/skills/)
./scripts/setup.sh global
```

### Option 3: Manual Installation

1. Create the skills directory:
   ```bash
   mkdir -p .claude/skills
   ```

2. Copy the skill folders:
   ```bash
   cp -R plugins/second-brain/skills/* .claude/skills/
   cp -R plugins/daily-todos/skills/* .claude/skills/
   ```

3. Verify installation:
   ```bash
   /skills  # Should show second-brain and daily-todos
   ```

---

## Global Permissions Setup

To install the recommended Claude Code permissions and hooks globally:

```bash
./scripts/setup-permissions.sh
```

This will:
- Merge permissions with your existing `~/.claude/settings.json`
- Install the `block_commit_on_main.sh` hook
- Back up your existing settings

**Requires:** `jq` (`brew install jq` on macOS)

---

## Managing Plugins

```bash
# Disable a plugin (keeps it installed)
/plugin disable second-brain@iker-marketplace

# Enable it again
/plugin enable second-brain@iker-marketplace

# Uninstall completely
/plugin uninstall second-brain@iker-marketplace
```

---

## Troubleshooting

### Skills not showing

1. Check the directory exists: `ls -la .claude/skills/`
2. Verify SKILL.md files: `cat .claude/skills/second-brain/SKILL.md`
3. Restart Claude Code session
4. Run `/skills` to list available skills

### Permission denied running setup script

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Uninstalling

```bash
# Using script
./scripts/setup.sh uninstall

# Or manually
rm -rf .claude/skills/second-brain .claude/skills/daily-todos
```

---

## Plugin Structure Reference

Each plugin follows this structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── skills/
│   └── skill-name/
│       └── SKILL.md         # Skill definition
├── agents/                   # Optional: custom agents
├── hooks/                    # Optional: event handlers
└── README.md                 # Documentation
```

The `SKILL.md` file format:

```yaml
---
description: When to use this skill
---

# Skill Name

Instructions for the AI agent...
```

---

## Support

- **Issues:** [GitHub Issues](https://github.com/iker592/iker-marketplace/issues)
- **Claude Code Docs:** [code.claude.com/docs](https://code.claude.com/docs)
