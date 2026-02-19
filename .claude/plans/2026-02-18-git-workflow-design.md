# Git Workflow Skill Design

**Date:** 2026-02-18
**Status:** Approved

## Problem

Multiple git-adjacent skills exist (commit-commands, finishing-a-development-branch, using-git-worktrees) with overlapping concerns. Agents lack unified guidance for git best practices, Graphite integration, and splitting large changes into reviewable units. Current approach puts too much procedural knowledge into reference docs, consuming context window unnecessarily.

## Solution

A unified `git-workflow` skill that:
1. Detects Graphite (`gt`) or plain Git and prefers Graphite when available
2. Provides a CLI with subcommands for deterministic workflows (minimizes context)
3. Includes reference docs for decision-making context (loaded only when needed)
4. Replaces: `commit-commands`, `finishing-a-development-branch`, `using-git-worktrees`

## Audience

Agent-only. The skill guides Claude Code agents through git workflows.

## File Structure

```
skills/git-workflow/
├── SKILL.md                        # Router: detect phase, point to subcommand or reference
├── scripts/
│   └── git-workflow                # CLI with subcommands
└── references/
    ├── graphite-guide.md           # GT commands, stacking patterns, Graphite workflows
    ├── git-best-practices.md       # Conventions: commits, branches, safety guardrails
    └── splitting-changes.md        # Decomposing large diffs into reviewable units
```

## SKILL.md

Acts as a **router**:
1. Instructs agent to run `git-workflow status` first
2. Based on output, routes to appropriate subcommand or reference
3. Quick-reference table mapping situations → actions

Trigger phrases: "commit", "branch", "split", "stack", "PR", "push", "worktree", "git workflow"

## CLI: `git-workflow`

### `status` (default subcommand)

- Detects `gt` vs `git` (prefers Graphite)
- Reports: current branch, tool version, dirty files count, stack state (if gt), ahead/behind
- Structured text output for agent parsing
- Exit 0 = ready, exit 1 = no git found

### `commit`

- Guided commit flow: validates staged files, suggests conventional commit format
- Graphite: uses `gt create` or `gt modify` as appropriate
- Git: uses `git commit` with conventional format
- Flags: `--message`, `--all`, `--amend`

### `split`

- Analyzes current diff or commit range
- Suggests split points based on file boundaries and change types
- Graphite: walks through `gt split` or `gt create` per logical unit
- Git: walks through `git add -p` + `git stash` workflow
- Flags: `--by-file`, `--by-commit`, `--dry-run`

### `stack`

- Shows stack state (gt: `gt log short`, git: branch tree relative to main)
- Offers: create new branch on stack, restack, sync
- Graphite: delegates to gt commands
- Git: manages branch chain manually

### `worktree`

- Creates isolated worktrees for parallel work
- Smart directory detection (inherits logic from using-git-worktrees)
- Auto-detects project type and runs dependency install
- Flags: `--branch`, `--base`, `--dir`

### `clean`

- Removes branches merged to main (replaces clean_gone)
- Graphite: `gt sync` handles this
- Git: finds gone branches and removes them + associated worktrees

## Reference Docs

### `graphite-guide.md` (~150 lines)

- Command cheat sheet (create, modify, submit, sync, split, absorb)
- Stacking patterns and best practices
- GitHub settings recommendations
- When to use gt vs raw git
- Pitfalls (raw rebase breaking metadata)

### `git-best-practices.md` (~100 lines)

- Conventional commits format + type table
- Branch naming conventions (feat/, fix/, refactor/, etc.)
- Safety guardrails (never force-push main, never `git add .`)
- Trunk-based development principles
- PR size targets (200-400 lines)

### `splitting-changes.md` (~120 lines)

- Strategies: layered architecture, feature-flag, file/subsystem, refactor-then-feature
- Step-by-step procedures for both gt and git
- When to split (>400 lines, >25 files, multiple concerns)
- Stack depth guidance (2-7 branches)

## Skills Replaced

| Skill | Replacement |
|---|---|
| `commit-commands:commit` | `git-workflow commit` |
| `commit-commands:commit-push-pr` | `git-workflow commit` + `github-pr` |
| `commit-commands:clean_gone` | `git-workflow clean` |
| `finishing-a-development-branch` | `git-workflow stack` + references |
| `using-git-worktrees` | `git-workflow worktree` |

## Skills NOT Replaced

- `github-pr` — GitHub-specific, not git-specific
- `managing-github-issues` — Issue management, separate concern

## Implementation Phases

### Phase 1: Scaffolding + References
- Create skill directory structure via skill-manager
- Write SKILL.md (router)
- Write all three reference docs from research

### Phase 2: CLI — Detection + Status
- `git-workflow status` subcommand
- Tool detection (gt vs git)
- Repo state gathering

### Phase 3: CLI — Commit + Clean
- `git-workflow commit` subcommand
- `git-workflow clean` subcommand

### Phase 4: CLI — Split + Stack
- `git-workflow split` subcommand
- `git-workflow stack` subcommand

### Phase 5: CLI — Worktree
- `git-workflow worktree` subcommand (port from using-git-worktrees)

### Phase 6: Audit + Cleanup
- Audit all flows end-to-end
- Move deterministic steps from references into CLI
- Write bats tests
- Remove replaced skills
- Update skill-manifest.json

## Research Sources

- Graphite CLI docs (graphite.dev)
- Conventional Commits spec (conventionalcommits.org)
- Trunk-based development (Atlassian, Graphite guides)
- Existing skills: using-git-worktrees, commit-commands, finishing-a-development-branch
