# Iker Marketplace

Claude Code configuration CLI and productivity plugins.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/iker592/iker-marketplace/main/install.sh | bash
iker setup-local    # Setup for current project (gitignored)
# OR
iker setup-global   # Setup globally for all projects
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
| **AWS CLI** | `aws sts get-caller-identity`, `aws s3 ls`, `aws ec2/iam/lambda/logs/rds/dynamodb describe-*`, `aws iam/lambda list-*/get-*`, `aws ssm get-parameter` |
| **Other** | `mkdir` |

---

## CLI Commands

| Command | Description |
|---------|-------------|
| `iker setup-local` | Setup for current project (`.claude/settings.local.json`, gitignored) |
| `iker setup-global` | Setup globally for all projects (`~/.claude/settings.json`) |
| `iker update` | Update iker to latest version |
| `iker <number>` | Merge PR by number (e.g., `iker 14`) |
| `iker uninstall` | Remove iker from your system |
| `iker help` | Show help |

**Which should I use?**
- `iker setup-local` - Per-project settings (gitignored, includes hooks + statusline)
- `iker setup-global` - Global settings that apply to all projects

---

## Installed Files

| File | Purpose |
|------|---------|
| `~/.iker/` | iker installation directory |
| `~/.local/bin/iker` | CLI symlink |
| `~/.claude/hooks/block_commit_on_main.sh` | Blocks commits on main (global) |
| `~/.claude/statusline.sh` | Status line script (global) |
| `~/.claude/settings.json` | Global permissions & config |
| `.claude/settings.local.json` | Per-project permissions (gitignored) |

---

## Updating

When new features are added:

```bash
iker update         # Pull latest changes (offers to sync global settings)
iker setup-local    # Re-run to update current project settings
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
| **typescript-dev** | TypeScript/React development standards (Bun, Vite, React, Tailwind, shadcn/ui, Vitest, Biome) | `/plugin install typescript-dev@iker-marketplace` |
| **python-dev** | Python development standards (uv, FastAPI, FastMCP, pytest, ruff) | `/plugin install python-dev@iker-marketplace` |
| **apple-notes** | Apple Notes integration via AppleScript on macOS | `/plugin install apple-notes@iker-marketplace` |
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

## Chat UI

A web-based chat interface for exploring plugins, powered by the Claude Agent SDK and Amazon Bedrock.

### Running

```bash
cd ui
make setup              # Install dependencies (first time)
make ui                 # Start frontend (http://localhost:3000)
make server-bedrock     # Start chat server with Bedrock (http://localhost:3001)
```

Or start both at once:

```bash
cd ui
bun run dev:all         # Starts UI + server concurrently
```

### Bedrock Configuration

The chat server uses the [Claude Agent SDK](https://platform.claude.com/docs/en/agent-sdk/overview) with Amazon Bedrock:

1. Set `CLAUDE_CODE_USE_BEDROCK=1` (done automatically by `make server-bedrock`)
2. Configure AWS credentials (`aws configure` or environment variables)
3. Ensure Claude models are enabled in your Bedrock region

To use the Anthropic API instead, run `make server` (requires `ANTHROPIC_API_KEY`).

---

## Requirements

- **jq** - Required for setup commands (`brew install jq` on macOS)
- **git** - Required for installation
- **Bun** - Required for the chat UI (`curl -fsSL https://bun.sh/install | bash`)

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
│   ├── setup-permissions.sh    # Global permissions setup
│   └── setup-local.sh          # Local project setup
├── .claude/
│   └── settings.json           # Default permissions
├── .claude-plugin/
│   └── marketplace.json        # Plugin marketplace manifest
├── .github/
│   └── workflows/
│       └── release.yml         # Auto-versioning action
├── plugins/
│   ├── typescript-dev/         # TypeScript/React dev standards
│   ├── python-dev/             # Python dev standards
│   ├── apple-notes/            # Apple Notes integration
│   ├── second-brain/           # Knowledge management
│   └── daily-todos/            # Task management
├── ui/                         # Chat UI (React + Bun)
│   ├── server/                 # Chat API server (Claude Agent SDK)
│   ├── src/                    # React frontend
│   ├── Makefile
│   └── package.json
├── CLAUDE.md
├── SETUP.md
└── README.md
```

---

## License

MIT
