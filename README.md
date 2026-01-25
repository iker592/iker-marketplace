# Iker Marketplace

Claude Code configuration CLI and productivity plugins.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/iker592/iker-marketplace/main/install.sh | bash
iker setup
```

Then restart Claude Code.

---

## What You Get

### Protections

| Protection | How |
|------------|-----|
| Can't commit on main/master | Hook blocks it |
| Can't push to main/master | Permission denied |
| Can't merge PRs | Permission denied |
| Can't force push | Permission denied |
| Can't run destructive commands | `rm`, `reset`, `restore`, etc. denied |

### Convenience

| Feature | Description |
|---------|-------------|
| Auto-accept edits | No Shift+Tab needed for file changes |
| Status line | Shows model, progress bar, token usage |
| Auto-allowed commands | No permission prompts for read-only commands |

**Status line example:**
```
Claude Opus 4.5 | [████████░░░░░░░░░░░░] 40% | 80K/200K
```

### Auto-Allowed Commands

These commands run without permission prompts:

| Category | Commands |
|----------|----------|
| **System** | `ls`, `cat`, `head`, `tail`, `find`, `tree`, `which`, `pwd`, `wc`, `file`, `stat`, `du`, `df`, `echo`, `jq`, `date`, `uname`, `whoami`, `hostname` |
| **Git (read)** | `git status`, `git log`, `git diff`, `git branch`, `git fetch`, `git show`, `git remote`, `git tag`, `git describe`, `git stash list`, `git rev-parse`, `git config` |
| **Git (write)** | `git add`, `git commit`, `git push`, `git checkout`, `git switch` |
| **GitHub CLI** | `gh pr list/view/create/edit/status/checks/diff`, `gh issue list/view/status`, `gh run list/view`, `gh release list/view`, `gh repo view` |
| **Other** | `mkdir` |

---

## CLI Commands

| Command | Description |
|---------|-------------|
| `iker setup` | Configure Claude Code permissions & hooks |
| `iker update` | Update iker to latest version |
| `iker <number>` | Merge PR by number (e.g., `iker 14`) |
| `iker uninstall` | Remove iker from your system |
| `iker help` | Show help |

---

## Installed Files

| File | Purpose |
|------|---------|
| `~/.iker/` | iker installation directory |
| `~/.local/bin/iker` | CLI symlink |
| `~/.claude/hooks/block_commit_on_main.sh` | Blocks commits on main |
| `~/.claude/statusline.sh` | Status line script |
| `~/.claude/settings.json` | Merged permissions & config |

---

## Updating

When new features are added:

```bash
iker update    # Pull latest changes
iker setup     # Re-run setup to apply updates
```

---

## Plugins

This marketplace also includes productivity plugins for Claude Code.

### Installation

```bash
/plugin marketplace add iker592/iker-marketplace
```

### Available Plugins

| Plugin | Description | Install |
|--------|-------------|---------|
| **second-brain** | Capture, organize, and retrieve knowledge | `/plugin install second-brain@iker-marketplace` |
| **daily-todos** | Manage daily tasks and to-do lists | `/plugin install daily-todos@iker-marketplace` |

### Usage

After installation, use the slash commands:

- `/second-brain` - Knowledge management
- `/daily-todos` - Task management

### Managing Plugins

```bash
/plugin disable plugin-name   # Disable (keeps installed)
/plugin enable plugin-name    # Enable again
/plugin uninstall plugin-name # Remove completely
/plugin list                  # List all plugins
```

---

## Requirements

- **jq** - Required for `iker setup` (`brew install jq` on macOS)
- **git** - Required for installation

---

## Uninstalling

```bash
iker uninstall
```

This removes `~/.iker/` and the CLI symlink. Your Claude Code settings are preserved.

---

## Versioning

Versions are automatically created when PRs merge to main:
- Patch increments: v1.0.0 → v1.0.1 → ... → v1.0.9
- Minor bump at 10 patches: v1.0.9 → v1.1.0
- Major versions are manual (breaking changes)

Check your version with `iker version`.

---

## Repository Structure

```
iker-marketplace/
├── bin/
│   └── iker                    # CLI tool
├── install.sh                  # Curl installer
├── scripts/
│   ├── setup.sh                # Skills installer
│   └── setup-permissions.sh    # Permissions setup
├── .claude/
│   ├── settings.json           # Default permissions
│   ├── statusline.sh           # Status line script
│   └── hooks/
│       └── block_commit_on_main.sh
├── .github/
│   └── workflows/
│       └── release.yml         # Auto-versioning action
├── plugins/
│   ├── second-brain/
│   └── daily-todos/
└── README.md
```

---

## License

MIT
