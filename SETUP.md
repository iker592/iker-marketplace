# Setup Guide

This guide explains how to install Iker Marketplace plugins for **Claude Code** and **Cursor IDE**.

## Quick Start

```bash
# Clone the marketplace
git clone https://github.com/iker592/iker-marketplace.git
cd iker-marketplace

# Install for both Claude Code and Cursor (project-level)
./scripts/setup.sh

# Or install globally
./scripts/setup.sh both global
```

---

## Claude Code Installation

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
./scripts/setup.sh claude project

# Global (in ~/.claude/skills/)
./scripts/setup.sh claude global
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

### Managing Plugins

```bash
# Disable a plugin (keeps it installed)
/plugin disable second-brain@iker-marketplace

# Enable it again
/plugin enable second-brain@iker-marketplace

# Uninstall completely
/plugin uninstall second-brain@iker-marketplace
```

---

## Cursor IDE Installation

> **Note:** Cursor has native support for `.claude/skills/` but symlinks don't work reliably. Use the copy method below.

### Option 1: Using Setup Script (Recommended)

```bash
# Project-level (in your repo's .cursor/skills/)
./scripts/setup.sh cursor project

# Global (in ~/.cursor/skills/)
./scripts/setup.sh cursor global
```

### Option 2: Manual Installation

1. Create the skills directory:
   ```bash
   mkdir -p .cursor/skills
   ```

2. Copy the skill folders:
   ```bash
   cp -R plugins/second-brain/skills/* .cursor/skills/
   cp -R plugins/daily-todos/skills/* .cursor/skills/
   ```

3. Restart Cursor to load skills

### Option 3: Cursor Reads `.claude/skills/`

Cursor can read from `.claude/skills/` for compatibility. If you've already installed for Claude Code, Cursor may detect the skills automatically.

```bash
# Install for Claude Code
./scripts/setup.sh claude project

# Cursor should also see these skills (restart Cursor)
```

### Verifying Installation in Cursor

1. Open Cursor Settings → Skills
2. Skills should appear in the list
3. Or use `/skills` command in Cursor Agent

---

## Cross-Platform Installation

To support both tools in a project:

```bash
# Install for both (creates .claude/skills/ and .cursor/skills/)
./scripts/setup.sh both project
```

This creates identical copies in both directories, ensuring compatibility regardless of which tool team members use.

### Directory Structure After Installation

```
your-project/
├── .claude/
│   └── skills/
│       ├── second-brain/
│       │   └── SKILL.md
│       └── daily-todos/
│           └── SKILL.md
├── .cursor/
│   └── skills/
│       ├── second-brain/
│       │   └── SKILL.md
│       └── daily-todos/
│           └── SKILL.md
└── ...
```

---

## Alternative: OpenSkills (Universal)

[OpenSkills](https://github.com/numman-ali/openskills) is a universal skills loader that works with Claude Code, Cursor, Windsurf, Aider, and more.

```bash
# Install OpenSkills globally
npm i -g openskills

# Install skills universally (creates .agent/skills/)
openskills install second-brain
openskills install daily-todos
```

---

## Troubleshooting

### Skills not showing in Claude Code

1. Check the directory exists: `ls -la .claude/skills/`
2. Verify SKILL.md files: `cat .claude/skills/second-brain/SKILL.md`
3. Restart Claude Code session
4. Run `/skills` to list available skills

### Skills not showing in Cursor

1. Cursor requires **nightly build** for full skills support
2. Check Settings → Beta → Update channel → "Nightly"
3. Restart Cursor after changing settings
4. Symlinks don't work - use copies instead

### Permission denied running setup script

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Uninstalling

```bash
# Remove from Claude Code
./scripts/setup.sh uninstall claude project

# Remove from Cursor
./scripts/setup.sh uninstall cursor project

# Or manually
rm -rf .claude/skills/second-brain .claude/skills/daily-todos
rm -rf .cursor/skills/second-brain .cursor/skills/daily-todos
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
- **Cursor Docs:** [cursor.com/docs](https://cursor.com/docs)
