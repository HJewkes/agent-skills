# git-workflow

Unified git CLI — status, commit, split, stack, worktree, clean. Detects Graphite (`gt`) or plain Git and adapts automatically.

## Install

```bash
npx skills add hjewkes/agent-skills --skill='git-workflow'
```

## Prerequisites

- Git
- Graphite CLI (`gt`) — optional, preferred when available

## Usage

```bash
git-workflow status                          # Detect environment, show branch/stack state
git-workflow commit --message "feat: ..."    # Guided commit (conventional format)
git-workflow split                           # Analyze diff, suggest split points
git-workflow stack                           # Show/create/restack branch stack
git-workflow worktree --branch feat/name     # Create isolated worktree with dep install
git-workflow clean                           # Remove merged/gone branches + worktrees
git-workflow --help                          # Full usage
```

## Subcommands

| Command | Description |
|---------|-------------|
| `status` | Detect gt/git, report branch, dirty files, stack state |
| `commit` | Conventional commit with optional Graphite integration |
| `split` | Decompose large diffs into logical commits |
| `stack` | View and manage branch stacks |
| `worktree` | Create isolated worktree with dependency install + test baseline |
| `clean` | Remove merged/gone branches and associated worktrees |

## Graphite Integration

When `gt` is available, the skill uses it for stacking workflows (`gt create`, `gt stack`). When not available, falls back to plain git branching. Run `git-workflow status` to see which tool is active.
