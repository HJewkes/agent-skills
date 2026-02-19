# md-render

Render markdown as styled dark-mode HTML and open in the browser.

## Install

```bash
npx skills add hjewkes/agent-skills --skill='md-render'
```

## Prerequisites

- Node.js (for markdown-it and plugins)
- npm dependencies are auto-installed on first run

## Usage

```bash
md-render docs/design.md              # Render and open in browser
md-render - < README.md               # Read from stdin
md-render plan.md -o plan.html        # Write to file instead of temp
md-render plan.md --no-open           # Generate HTML without opening
md-render doc.md -c ./my-config.json  # Use custom config
```

## Features

- Dark-mode styling with configurable theme
- Syntax highlighting (highlight.js)
- Mermaid diagram rendering
- Table of contents (collapsible inline + slide-out panel)
- Copy-to-clipboard (code blocks + full raw markdown)
- Heading anchors with hover links
- Extended markdown: footnotes, emoji, highlights, sub/superscript, task lists

## Configuration

On first run, defaults are copied to `~/.config/agent-skills/md-render/config.json`.

```json
{
  "theme": {
    "fontFamily": "'SF Pro Display', 'Inter', system-ui, sans-serif",
    "bgColor": "#0c0e14",
    "textColor": "#c9d1d9",
    "linkColor": "#7aa2f7",
    "maxWidth": "820px"
  },
  "features": {
    "toc": true,
    "syntaxHighlight": true,
    "mermaid": true
  }
}
```

Edit this file to customize colors, fonts, and feature toggles. Use `--config` to point to an alternate config file.
