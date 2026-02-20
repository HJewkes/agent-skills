---
name: plan-execution
description: "Execute implementation plans and coordinate parallel agents. Handles in-session subagent dispatch, batch execution, parallel task coordination, and team orchestration."
---

# Plan Execution

Execute plans by detecting the right mode from context, dispatching agents, and verifying results.

## Mode Detection

| Mode | When to Use | Details |
|------|-------------|---------|
| **Subagent** (default) | Plan directory with manifest.json, independent tasks, current session | Fresh agent per task, two-stage review. See [references/execution-modes.md](references/execution-modes.md#subagent-mode) |
| **Batch** | User wants separate session, or plan has 10+ tasks | Checkpoint-based execution, 3 tasks per batch. See [references/execution-modes.md](references/execution-modes.md#batch-mode) |
| **Parallel dispatch** | 2+ independent tasks, no formal plan needed (e.g., multiple unrelated test failures) | One agent per problem domain, no plan required. See [references/execution-modes.md](references/execution-modes.md#parallel-dispatch-mode) |
| **Team** | User says "team", tasks need ongoing collaboration | Named agents, wave-based coordination. See [references/execution-modes.md](references/execution-modes.md#team-mode) |

## Model Selection

| Tier | Model | Use For |
|------|-------|---------|
| Heavy | Opus | Implementation, complex debugging, architecture |
| Medium | Sonnet | Code review, analysis, planning |
| Light | Haiku | Formatting, simple lookups, validation checks |

## Universal Rules

- **Max 4 concurrent agents** to avoid resource contention
- **Explicit file ownership** per agent -- no two agents modify the same file
- **Agents read briefing files from disk** -- never paste full briefing content inline
- **Re-read manifest.json at wave boundaries** to recover state after context compaction
- **Include return format constraint** in every spawn prompt (token budget + structure)
- **Stop and ask** when blocked -- don't guess. See [references/guardrails.md](references/guardrails.md)

## Prompt Templates

- [prompts/implementer.md](prompts/implementer.md) -- dispatch template for implementation agents
- [prompts/spec-reviewer.md](prompts/spec-reviewer.md) -- spec compliance review template
- [prompts/code-quality-reviewer.md](prompts/code-quality-reviewer.md) -- code quality review template

## References

- [references/execution-modes.md](references/execution-modes.md) -- detailed process for each mode
- [references/orchestration-patterns.md](references/orchestration-patterns.md) -- agent spawn rules, templates, common mistakes
- [references/guardrails.md](references/guardrails.md) -- stop conditions, cleanup, stale plan detection

## Integration

**Required skills:** git-workflow (worktrees, stack), writing-plans (creates plans this skill executes)
