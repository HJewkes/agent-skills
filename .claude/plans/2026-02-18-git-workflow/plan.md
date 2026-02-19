# Git Workflow Skill Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Build a unified `git-workflow` skill with CLI and reference docs that replaces commit-commands, finishing-a-development-branch, and using-git-worktrees.

**Architecture:** Modular CLI (`git-workflow`) with subcommands (status, commit, split, stack, worktree, clean) backed by reference docs. CLI handles deterministic steps to minimize context window. References provide decision-making context loaded on demand. Prefers Graphite (`gt`) when available, falls back to plain git.

**Tech Stack:** Bash (set -euo pipefail), bats-core for tests, shellcheck for linting.

## Dependency Graph

```
Tasks 1-4 (Wave 1) ──→ Task 5 (Wave 2) ──→ Tasks 6-7 (Wave 3) ──→ Task 8 (Wave 4) ──→ Tasks 9-10 (Wave 5)
                                          ↗                                            ↗
```

Tasks 1-4 are independent (different files). Tasks 5-8 are sequential (same script file). Tasks 9-10 depend on all CLI work.

## Wave Plan

- **Wave 1** (parallel): Task 1, Task 2, Task 3, Task 4
- **Wave 2** (depends on Wave 1): Task 5
- **Wave 3** (depends on Wave 2): Task 6, Task 7 (sequential — same file)
- **Wave 4** (depends on Wave 3): Task 8
- **Wave 5** (depends on Wave 4): Task 9, Task 10 (parallel)

## Tasks

| # | Name | Files | Wave | Depends On |
|---|------|-------|------|------------|
| 1 | Scaffold skill + write SKILL.md | `skills/git-workflow/SKILL.md` | 1 | — |
| 2 | Write graphite-guide.md | `skills/git-workflow/references/graphite-guide.md` | 1 | — |
| 3 | Write git-best-practices.md | `skills/git-workflow/references/git-best-practices.md` | 1 | — |
| 4 | Write splitting-changes.md | `skills/git-workflow/references/splitting-changes.md` | 1 | — |
| 5 | CLI skeleton + status subcommand | `skills/git-workflow/scripts/git-workflow` | 2 | 1 |
| 6 | CLI commit + clean subcommands | `skills/git-workflow/scripts/git-workflow` | 3 | 5 |
| 7 | CLI split + stack subcommands | `skills/git-workflow/scripts/git-workflow` | 3 | 6 |
| 8 | CLI worktree subcommand | `skills/git-workflow/scripts/git-workflow` | 4 | 7 |
| 9 | Bats tests | `tests/git-workflow.bats` | 5 | 8 |
| 10 | Cleanup replaced skills + manifest | `skill-manifest.json`, removed skill dirs | 5 | 8 |

Detailed task specs: `./briefings/task-NN.md`
