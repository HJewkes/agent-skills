# Agent Skills Open Standard Reference

Condensed reference for the Agent Skills specification. Source: agentskills.io

## SKILL.md Format

Every skill is a single `SKILL.md` file containing YAML frontmatter followed by a markdown body.

```markdown
---
name: my-skill-name
description: Use when encountering specific situation or need
---

# My Skill Name

Markdown body with instructions, examples, and guidance.
```

## Required Frontmatter Fields

### name
- **Type:** string
- **Max length:** 64 characters
- **Format:** kebab-case — lowercase letters, numbers, and hyphens only
- **Rules:**
  - No leading or trailing hyphens
  - No consecutive hyphens (`--`)
  - Must match the containing directory name
- **Example:** `condition-based-waiting`

### description
- **Type:** string
- **Max length:** 1024 characters
- **Convention:** Start with "Use when..." to optimize for agent discovery
- **Purpose:** Agents read descriptions at startup to decide which skills to load
- **Example:** `Use when tests have race conditions, timing dependencies, or pass/fail inconsistently`

## Optional Frontmatter Fields

### license
- **Type:** string
- **Purpose:** SPDX license identifier for the skill

### compatibility
- **Type:** string
- **Max length:** 500 characters
- **Purpose:** Describe tool/platform compatibility requirements

### metadata
- **Type:** object
- **Purpose:** Arbitrary key-value pairs for custom metadata

## Claude Code Extensions

Claude Code supports additional frontmatter fields beyond the base spec:

| Field | Type | Purpose |
|-------|------|---------|
| `disable-model-invocation` | boolean | Prevent auto-invocation by Claude |
| `user-invocable` | boolean | Allow direct invocation via slash commands |
| `argument-hint` | string | Hint text shown on user invocation |
| `context` | array of strings | Additional files to load on invocation |
| `agent` | object | Configure the skill as an agent |
| `hooks` | object | Define lifecycle hooks (pre/post actions) |
| `model` | string | Preferred model for skill execution |

## Naming Rules

| Rule | Example | Invalid |
|------|---------|---------|
| Lowercase only | `code-review` | `Code-Review` |
| Letters, numbers, hyphens | `my-skill-2` | `my_skill` |
| No leading/trailing hyphens | `my-skill` | `-my-skill-` |
| No consecutive hyphens | `my-skill` | `my--skill` |
| Max 64 characters | `condition-based-waiting` | (65+ chars) |
| Dir name matches `name` field | `skills/my-skill/` + `name: my-skill` | Mismatch |

## Progressive Disclosure

Skills use a three-tier loading strategy to minimize context consumption:

1. **Frontmatter** — loaded at startup for all installed skills. Agents read `name` and `description` to build a skill index. Keep descriptions concise and trigger-focused.

2. **Body** (markdown below frontmatter) — loaded on invocation when the agent decides the skill is relevant. Contains the core instructions, workflows, and decision logic. Target under 500 lines.

3. **references/** — loaded on demand when the agent needs deeper detail. Store detailed procedures, examples, checklists, and heavy reference material here.

```
skills/my-skill/
  SKILL.md              # Frontmatter (tier 1) + body (tier 2)
  references/           # On-demand deep dives (tier 3)
    detailed-guide.md
    examples.md
```

## Scripts Convention

Executable scripts live in a `scripts/` subdirectory within the skill:

```
skills/my-skill/
  SKILL.md
  scripts/
    my-script           # Must be executable (chmod +x)
```

- Scripts must be `#!/usr/bin/env bash` and POSIX-compatible
- Every script supports `--help`
- Output to stdout, errors to stderr
- Exit codes: 0 success, 1 error, 2 warning

## Plugin Packaging

Skills can be packaged as plugins for distribution via `.claude-plugin/plugin.json`:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "skills": [
    {
      "name": "my-skill",
      "path": "skills/my-skill"
    }
  ]
}
```

Plugins wrap one or more skills into a distributable package. The `plugin.json` manifest declares which skills the plugin provides and their locations within the package.

### Plugin Discovery

- npm: `npx skills find "<query>"` searches the npm registry
- GitHub: Clone and install via `skill-manager install <owner/repo>`
- Marketplace: Browse skillsmp.com for community-contributed skills

## Key Principles

1. **One skill, one concern** — each skill addresses a single capability or technique
2. **Self-contained** — skills should not depend on other skills being installed
3. **Progressive disclosure** — minimize always-on context, load details on demand
4. **Trigger-focused descriptions** — descriptions say *when* to use, not *what* it does
5. **Test before deploy** — verify skills work with real agent pressure scenarios
