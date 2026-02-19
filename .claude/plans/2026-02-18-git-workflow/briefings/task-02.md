# Task 02: Write graphite-guide.md

## Architectural Context

This reference doc provides Graphite-specific command knowledge for the agent. It's loaded only when the agent needs to perform Graphite operations. The SKILL.md router links here. This is a reference doc — no scripts, no executable code. Target ~150 lines.

## File Ownership

**May modify:**
- `skills/git-workflow/references/graphite-guide.md`

**Must not touch:**
- `skills/git-workflow/SKILL.md`
- Any script files

## Steps

### Step 1: Create references directory

```bash
mkdir -p /Users/hjewkes/Documents/projects/agents-skills/skills/git-workflow/references
```

### Step 2: Write graphite-guide.md

Write the file at `skills/git-workflow/references/graphite-guide.md` with this content:

```markdown
# Graphite CLI Guide

Quick reference for Graphite (`gt`) stacked-PR workflows. Graphite layers on top of Git — any unknown `gt` command falls through to `git`.

## Detection

```bash
command -v gt &>/dev/null && gt --version
```

## Prerequisites

- Git >= 2.38.0
- `gt init` in repo (creates `.git/.graphite_repo_config`)
- `gt auth --token <token>` for PR operations

## Core Commands

### Branch Creation

| Command | Description |
|---------|-------------|
| `gt create -m "message"` | New branch atop current, commit staged changes |
| `gt create -a -m "message"` | Same but auto-stage all modified files |
| `gt create --insert` | Insert branch between current and parent |

### Modification

| Command | Description |
|---------|-------------|
| `gt modify -a` | Amend current branch commit, auto-restack upstack |
| `gt modify -c` | New commit on current branch (no amend) |
| `gt absorb` | Auto-distribute staged changes into correct downstack commits |
| `gt squash` | Squash all commits on current branch into one |

### Navigation

| Command | Description |
|---------|-------------|
| `gt up` / `gt down` | Move up/down the stack |
| `gt top` / `gt bottom` | Jump to top/bottom of stack |
| `gt checkout` | Interactive fuzzy-picker |

### Stack Operations

| Command | Description |
|---------|-------------|
| `gt restack` | Rebase all branches onto their parents |
| `gt move --onto <branch>` | Rebase current + descendants onto different base |
| `gt fold` | Merge current branch into parent |
| `gt split --by-commit` | Split branch at commit boundaries |
| `gt split --by-hunk` | Interactive hunk-level split |
| `gt split --by-file <path>` | Extract matching files into new parent branch |

### Remote / PR

| Command | Description |
|---------|-------------|
| `gt submit` | Push current branch, create/update PR |
| `gt submit --stack` | Push entire stack, create/update all PRs |
| `gt submit --draft` | Create PRs as drafts |
| `gt submit --merge-when-ready` | Enable auto-merge on approval |
| `gt sync` | Pull trunk, restack open branches, prompt to delete merged |

### Visualization

| Command | Description |
|---------|-------------|
| `gt log short` | Condensed stack tree (alias: `gt ls`) |
| `gt log long` | Verbose view (alias: `gt ll`) |
| `gt log --stack` | Show only current stack |
| `gt info` | Branch metadata, PR status, diff stats |

### Utilities

| Command | Description |
|---------|-------------|
| `gt undo` | Revert last Graphite mutation |
| `gt continue` | Resume halted rebase after conflict resolution |
| `gt abort` | Cancel halted rebase |
| `gt track` | Register existing branch with Graphite metadata |

## Stacking Best Practices

- Each branch = one logical, independently-reviewable change
- Target 50-200 lines changed per branch
- Submit early as drafts: `gt submit --draft`
- Use `gt submit --stack` to keep GitHub in sync
- Address feedback with `gt modify -a`, never raw `git commit --amend`
- Run `gt sync` regularly to absorb trunk changes
- Typical stack depth: 2-7 branches

## Recommended GitHub Settings

Disable these (they break stacked merging):
- "Require approval of most recent reviewable push"
- "Dismiss stale approvals when new commits are pushed"

Enable:
- "Allow auto-merge"

## Recommended Git Config

```bash
git config rerere.enabled true        # Remember conflict resolutions
git config rerere.autoupdate true     # Auto-stage rerere-resolved files
git config pull.rebase true           # Always rebase on pull
git config rebase.autoStash true      # Stash before rebase
```

## Pitfalls

- **Raw `git rebase` breaks metadata.** If you must, use `gt track --parent <branch>` afterward to re-register.
- **Force-pushing a gt branch** without `gt submit` will desync Graphite's tracking. Always use `gt submit`.
- **Deleting a mid-stack branch** orphans upstack branches. Use `gt fold` to merge into parent instead.
```

### Step 3: Commit

```bash
git add skills/git-workflow/references/graphite-guide.md
git commit -m "Add Graphite CLI reference guide"
```

## Success Criteria

- [ ] `skills/git-workflow/references/graphite-guide.md` exists
- [ ] Covers: detection, core commands, stacking best practices, pitfalls
- [ ] ~150 lines, well-organized with tables

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
