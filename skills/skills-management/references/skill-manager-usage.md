# skill-manager CLI Reference

The `skill-manager` script manages skill lifecycle operations: scaffolding, installation, removal, validation, and symlink synchronization.

**Location:** `scripts/skill-manager`

## Commands

### create

Scaffold a new skill with all required files and symlinks.

```bash
scripts/skill-manager create <name> [--no-cursor] [--bin <script>] [--dry-run]
```

| Option | Effect |
|--------|--------|
| `--no-cursor` | Skip Cursor symlink creation |
| `--bin <name>` | Also scaffold a bin script with standard template |
| `--dry-run` | Show what would be created without writing |

Creates: `SKILL.md` with frontmatter template, Claude symlink, Cursor symlink (unless `--no-cursor`).

### install

Install a skill from a GitHub repository.

```bash
scripts/skill-manager install <owner/repo> [skill-path] [--no-cursor] [--dry-run]
```

| Argument | Effect |
|----------|--------|
| `owner/repo` | GitHub repository (e.g., `anthropics/skills`) |
| `skill-path` | Path to skill dir within repo (auto-detected if omitted) |
| `--no-cursor` | Skip Cursor symlink |
| `--dry-run` | Show what would be installed without writing |

Auto-detects skills: checks repo root for `SKILL.md`, then `skills/*/SKILL.md`. Validates before installing. Updates skill-lock.json with source metadata.

### remove

Remove a skill and all its symlinks.

```bash
scripts/skill-manager remove <name> [--dry-run] [--keep-lock]
```

| Option | Effect |
|--------|--------|
| `--dry-run` | Show what would be removed without deleting |
| `--keep-lock` | Preserve the skill-lock.json entry |

Removes: skill directory, Claude symlink, Cursor symlink, bin symlinks pointing into the skill.

### list

List all skills with status information.

```bash
scripts/skill-manager list [--json]
```

Shows: skill name, Claude symlink status, Cursor symlink status, bin script presence, source (local or GitHub repo).

### validate

Check skills against conventions.

```bash
scripts/skill-manager validate [<name>]
```

**Checks performed:**
- Directory name is kebab-case
- SKILL.md exists with valid YAML frontmatter
- `name` field matches directory name
- `description` starts with "Use when"
- Frontmatter under 1024 characters
- No unexpected frontmatter fields (only `name` and `description`)
- Claude/Cursor symlink files exist
- Bin scripts have discovery symlinks

Validates all skills if no name given. Validates one skill if name provided.

### sync

Re-derive all symlinks from source. Fixes drift, adds missing symlinks, removes orphaned ones.

```bash
scripts/skill-manager sync [--dry-run]
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error (missing files, validation failures) |
| 2 | Warnings only (validate command) |

## Examples

```bash
# Scaffold a new skill
scripts/skill-manager create my-new-skill

# Scaffold with a bin script
scripts/skill-manager create my-tool --bin my-script

# Install from GitHub
scripts/skill-manager install anthropics/skills

# Install specific skill from a multi-skill repo
scripts/skill-manager install anthropics/skills skills/code-review

# Validate all skills
scripts/skill-manager validate

# Fix symlink drift
scripts/skill-manager sync

# Preview changes before acting
scripts/skill-manager create my-skill --dry-run
scripts/skill-manager install owner/repo --dry-run
scripts/skill-manager remove old-skill --dry-run
```
