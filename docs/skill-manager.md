# skill-manager

Create, validate, and manage skills in this repository.

## Install

```bash
npx skills add hjewkes/agent-skills --skill='skills-management'
```

## Prerequisites

- Bash 4+
- `jq` (optional — needed for manifest management)

## Usage

```bash
skill-manager create my-skill              # Scaffold a new skill
skill-manager validate                     # Validate all skills against conventions
skill-manager validate --skill my-skill    # Validate a specific skill
skill-manager list                         # List all skills in the repo
skill-manager --help                       # Full usage
```

## What It Validates

- SKILL.md exists with valid frontmatter (`name`, `description`)
- Description starts with "Use when" (convention)
- Scripts are executable
- Directory structure follows conventions
- Manifest entries are consistent

## Skill Structure

Skills created by the manager follow this layout:

```
skills/my-skill/
├── SKILL.md              # Agent instructions (required)
├── scripts/              # Executable scripts (optional)
│   └── my-script
├── references/           # Detailed docs loaded on-demand (optional)
│   └── guide.md
└── templates/            # Templates for output generation (optional)
```
