# Task 03: Write git-best-practices.md

## Architectural Context

This reference doc provides general git conventions and safety rules for the agent. Loaded when the agent needs guidance on commit format, branch naming, or safety guardrails. Target ~100 lines.

## File Ownership

**May modify:**
- `skills/git-workflow/references/git-best-practices.md`

**Must not touch:**
- `skills/git-workflow/SKILL.md`
- Any script files

## Steps

### Step 1: Create references directory (if not exists)

```bash
mkdir -p /Users/hjewkes/Documents/projects/agents-skills/skills/git-workflow/references
```

### Step 2: Write git-best-practices.md

Write the file at `skills/git-workflow/references/git-best-practices.md`:

```markdown
# Git Best Practices

Conventions and safety rules for AI agent git workflows.

## Commit Format

Use Conventional Commits:

```
<type>[optional scope]: <description>

[optional body]
```

Subject: imperative mood ("Add feature" not "Added feature"), max 72 chars, no trailing period.
Body: wrap at 72 chars, explain "why" not "what".

### Types

| Type | Purpose | SemVer |
|------|---------|--------|
| `feat` | New feature | MINOR |
| `fix` | Bug fix | PATCH |
| `docs` | Documentation only | — |
| `refactor` | No behavior change | — |
| `perf` | Performance improvement | — |
| `test` | Adding/fixing tests | — |
| `chore` | Build/tooling/maintenance | — |
| `ci` | CI configuration | — |

Breaking changes: append `!` after type (`feat!: remove endpoint`) or use `BREAKING CHANGE:` footer.

## Branch Naming

```
<type>/<short-description>
<type>/<issue-id>-<short-description>
```

- All lowercase, hyphens as separators
- Keep short and descriptive
- Examples: `feat/oauth-login`, `fix/GH-42-null-pointer`, `refactor/auth-module`

Valid prefixes: `feat/`, `fix/`, `hotfix/`, `refactor/`, `docs/`, `chore/`, `test/`, `ci/`

## Trunk-Based Development

- One central integration branch (main), always stable
- Short-lived feature branches (hours to 1-2 days max)
- Merge frequently — long-lived branches are a liability
- Small, scoped branches that merge back quickly

## PR Size Targets

- Optimal: 200-400 lines changed
- Under 200 lines: reviewed fastest and most thoroughly
- Over 400 lines: split into stacked PRs (see splitting-changes.md)
- One PR = one logical concern

## Safety Guardrails (Hard Rules)

**Never:**
- `git push --force` to main/master or any protected branch
- `git add .` or `git add -A` (risks committing secrets)
- `git reset --hard` without explicit user instruction
- `git clean -f` without explicit user instruction
- Skip hooks with `--no-verify`
- Commit `.env`, credentials, or secret files

**Always:**
- Stage specific files by name
- Verify staged files with `git diff --staged` before committing
- One logical concern per commit
- Check current branch before destructive operations
- Require user approval before pushing

## Useful Git Config

```bash
git config rerere.enabled true        # Remember conflict resolutions
git config pull.rebase true           # Rebase on pull
git config rebase.autoStash true      # Auto-stash before rebase
git config init.defaultBranch main    # Default to main
```

## Version Requirements

| Min Version | Feature |
|-------------|---------|
| 2.5 | `git worktree` |
| 2.23 | `git switch`, `git restore` |
| 2.28 | `init.defaultBranch` |

Recommended minimum: Git 2.28+
```

### Step 3: Commit

```bash
git add skills/git-workflow/references/git-best-practices.md
git commit -m "Add git best practices reference"
```

## Success Criteria

- [ ] `skills/git-workflow/references/git-best-practices.md` exists
- [ ] Covers: conventional commits, branch naming, TBD, PR size, safety guardrails
- [ ] ~100 lines, clear tables

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
