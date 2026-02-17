# Config Examples

Reference configurations for Claude Code. These are NOT installed automatically — copy and adapt for your setup.

## settings.json

Example `~/.claude/settings.json` with:
- Safety hooks (rm -rf guard, sensitive file protection, lock file protection)
- Permission deny patterns for sensitive files
- macOS notification on agent completion
- Recommended plugins

To use: copy to `~/.claude/settings.json` and customize.

## What's NOT here

- `CLAUDE.md` — these are project-specific; see each project's repo
- Auto-memory — machine-specific, not portable
- Plugin installs — handled by `/plugin install` command
