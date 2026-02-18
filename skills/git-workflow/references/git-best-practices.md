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
