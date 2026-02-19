---
name: md-render
description: Use when asked to render, preview, or view a markdown file in the browser. Triggers on "render markdown", "preview this", "show me this document", "open in browser".
---

# Markdown Renderer

Render markdown files as beautiful dark-mode HTML and open them in the browser. Designed for viewing agent-generated documents (design docs, plans, reports).

## Quick Reference

| Situation | Action |
|-----------|--------|
| User asks to render/preview markdown | Run `md-render <file>` |
| User wants HTML output saved | Run `md-render <file> -o output.html` |
| User wants to customize styling | Edit `~/.config/agent-skills/md-render/config.json` |

## CLI Reference

| Command | Description |
|---------|-------------|
| `md-render file.md` | Render and open in browser |
| `md-render - < file.md` | Render from stdin |
| `md-render file.md -o out.html` | Save HTML to file |
| `md-render file.md --no-open` | Generate HTML without opening browser |
| `md-render --config path.json file.md` | Use alternate config |
| `md-render --help` | Show usage |

**Exit codes:** 0 = success, 1 = error

## Features

- Dark-mode aesthetic with configurable colors, fonts, and sizing
- Sticky table of contents sidebar with smooth scroll navigation
- Syntax-highlighted code blocks (highlight.js)
- Clickable heading anchors
- Responsive layout — TOC collapses on narrow viewports
- Self-contained HTML — no external requests

## Configuration

Config location: `~/.config/agent-skills/md-render/config.json`

Created automatically on first run from defaults. Edit to customize theme colors, fonts, sizing, and feature toggles.
