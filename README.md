# Iker Marketplace

Personal productivity plugins for Claude Code.

## Installation

```bash
/plugin marketplace add iker592/iker-marketplace
```

## Available Plugins

| Plugin | Description | Install |
|--------|-------------|---------|
| **second-brain** | Capture, organize, and retrieve knowledge | `/plugin install second-brain@iker-marketplace` |
| **daily-todos** | Manage daily tasks and to-do lists | `/plugin install daily-todos@iker-marketplace` |

## Usage

After installation, use the slash commands:

- `/second-brain` - Knowledge management
- `/daily-todos` - Task management

## Structure

```
iker-marketplace/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── second-brain/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   │       └── second-brain/
│   │           └── SKILL.md
│   └── daily-todos/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
│           └── daily-todos/
│               └── SKILL.md
└── README.md
```
