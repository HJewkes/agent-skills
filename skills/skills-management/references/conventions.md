# Skill & Agent Conventions

## Directory Structure

**Plugin structure** (canonical location):
```
skills/<skill-name>/
  SKILL.md              # Required — frontmatter + skill content
  references/           # Optional — deep-dive docs, examples, templates
    *.md
  scripts/              # Optional — executable scripts
```

Claude Code discovers skills via `~/.claude/skills/`. Skills can also be installed to `~/.cursor/skills/` for Cursor support.

## Management

Use `scripts/skill-manager` for all skill lifecycle operations. It handles directory creation, symlink management, and convention enforcement automatically.

## Creating a New Skill

```bash
scripts/skill-manager create <skill-name>
# Edit the SKILL.md at the printed path
# Add references/ files as needed
```

With a script: `scripts/skill-manager create <skill-name> --bin <script-name>`

## Installing a Skill from GitHub

```bash
scripts/skill-manager install <owner/repo>           # auto-detect skills in repo
scripts/skill-manager install <owner/repo> skills/x  # specific skill path
```

## Removing a Skill

```bash
scripts/skill-manager remove <skill-name>
```

## Validating & Syncing

```bash
scripts/skill-manager validate              # check all skills against conventions
scripts/skill-manager validate <skill-name> # check one skill
scripts/skill-manager sync                  # fix missing/orphaned symlinks
```

## Skill Directory Layout

```
skills/<skill-name>/
  SKILL.md              # Required — frontmatter + skill content
  references/           # Optional — deep-dive docs, examples, templates
    *.md
  scripts/              # Optional — co-located executable scripts
```

## Naming Conventions

- **Skills**: lowercase kebab-case directories (`plan-execution`, `code-review`)
- **Agents**: lowercase kebab-case files with `.md` extension (`security-reviewer.md`)
- **SKILL.md**: always uppercase filename, contains YAML frontmatter with `name` and `description`

## Agent Prompts

Agent prompts (system prompts for Task tool agents) live as reference files inside skills:

```
skills/<skill-name>/
  SKILL.md                       # Skill entry point
  references/
    <agent-name>.md              # Agent system prompt
```

**Principles:**
- The skill is the unit of composition — workflows reference skills, not agent files directly
- One canonical location per agent prompt — other skills cross-reference, never duplicate
- A skill wrapping a single agent prompt is the correct pattern, not a "thin wrapper"

## Migrating a Plugin to a Skill

1. Extract the plugin's command file(s) as reference material in the new skill
2. Move plugin frontmatter constraints (`allowed-tools`, etc.) into documented constraints in the prompt body
3. Delete the plugin install manifest
4. Create the skill per standard conventions

## Shell Scripts (scripts/)

Scripts extract deterministic command sequences from skills into standalone executables.
Skills remain the "when and why"; scripts handle the "how".

**Location:** `skills/<skill-name>/scripts/<script-name>`

**Conventions:**
- `#!/usr/bin/env bash`, POSIX-compatible
- Every script supports `--help`
- Output to stdout, progress/errors to stderr
- Exit codes: 0 success, 1 failure, 2 partial/warning
- No interactive prompts — skills handle interaction, scripts are non-interactive

## Rules

1. **Never** create skills without valid YAML frontmatter containing `name` and `description`
2. Directory name must match the `name` field in frontmatter
3. Description must start with "Use when..." to optimize for Claude's skill discovery
4. See the writing-skills reference for content guidelines, testing methodology, and quality standards
