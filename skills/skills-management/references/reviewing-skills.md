# Reviewing Skills

How to audit skills for quality, portability, and compliance with the Agent Skills standard.

## Self-Containedness Check

Skills must be self-contained and portable. Search for these red flags:

```bash
# Cross-skill file references (skills should not reference siblings)
grep -r '\.\./\.\.' skills/<skill-name>/

# Hardcoded deployment paths
grep -r '~/\.agents/' skills/<skill-name>/
grep -r '\$HOME/\.agents' skills/<skill-name>/

# Namespace or ecosystem-specific references
grep -r 'superpowers:' skills/<skill-name>/

# Chezmoi-specific language
grep -ri 'chezmoi' skills/<skill-name>/
grep -r 'private_dot_' skills/<skill-name>/
```

**Any match is a portability issue.** Skills must work when installed standalone, not just within a specific dotfiles setup.

## Frontmatter Compliance

Check every SKILL.md against these rules:

| Check | Requirement |
|-------|-------------|
| `name` field present | Required, must match directory name |
| `name` format | Kebab-case: lowercase, numbers, hyphens only |
| `description` field present | Required, max 1024 characters |
| `description` starts with "Use when" | Convention for agent discovery optimization |
| No extra fields | Only `name` and `description` in base spec |
| Total frontmatter size | Under 1024 characters |

Run automated checks:
```bash
scripts/skill-manager validate <skill-name>
```

## Script Location

Scripts must live in the skill's own `scripts/` directory:

| Correct | Incorrect |
|---------|-----------|
| `skills/my-skill/scripts/my-script` | `skills/my-skill/bin/my-script` |
| `scripts/skill-manager` (repo-level shared) | `~/.agents/bin/skill-manager` |

Do not reference shared bin directories or external script paths. Every script the skill needs should be co-located or available at a documented repo-level path.

## Description Quality

The description field is the single most important line for skill discovery. Audit against:

- **Starts with "Use when..."** — triggers intent-based matching in Claude's skill selection
- **Describes the problem, not the workflow** — "Use when tests are flaky" not "Use when you need to run TDD cycle"
- **Keyword-rich** — includes terms Claude would search for (error names, symptoms, tool names)
- **No workflow summary** — descriptions that summarize the skill's process cause Claude to shortcut and skip reading the full body
- **Technology-agnostic** unless the skill itself is technology-specific
- **Third person** — descriptions are injected into system prompts

## Context Budget

Keep skills lean to minimize context consumption:

| Component | Target |
|-----------|--------|
| SKILL.md body | Under 500 lines |
| Frontmatter | Under 1024 characters |
| Heavy content | Move to `references/` |

If a SKILL.md exceeds 500 lines, extract detailed procedures, examples, and tables into reference files. The body should serve as a concise overview that points to references for depth.

## Using skill-manager validate

The `validate` command checks conventions automatically:

```bash
# Validate one skill
scripts/skill-manager validate my-skill

# Validate all skills
scripts/skill-manager validate
```

**What it checks:** kebab-case naming, SKILL.md presence, frontmatter fields, description format, symlink integrity, bin script discovery.

**What it does NOT check:** content quality, self-containedness, cross-skill references, hardcoded paths. These require manual review using the grep patterns above.

## Common Issues Found in Audits

Categories of issues discovered when auditing skill repositories:

### Hardcoded deployment paths
References to `~/.agents/bin/`, `~/.agents/skills/`, or `~/.agents/shared/` bake in a specific dotfiles layout. Replace with relative paths or `scripts/` references.

### Namespace references
References like `superpowers:skill-name` assume a specific skill ecosystem. Use plain skill names or cross-reference by file path within the repo.

### Cross-skill file references
Paths like `../../other-skill/references/file.md` create hidden dependencies between skills. Each skill must be independently installable. Duplicate small content or link to the other skill by name.

### Chezmoi-specific language
References to chezmoi source paths (`private_dot_agents/`), `chezmoi apply`, or symlink files assume a chezmoi-managed dotfiles setup. Replace with generic install instructions using `scripts/skill-manager`.

### Overly broad descriptions
Descriptions that try to cover everything the skill does instead of focusing on when to invoke it. Rewrite to focus on triggering conditions and symptoms.

### Missing "Use when" prefix
Descriptions that start with "Documents..." or "Provides..." instead of "Use when...". The "Use when" prefix is required for Claude's skill discovery to work effectively.
