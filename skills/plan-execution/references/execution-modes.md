# Execution Modes

## Subagent Mode

Default mode when a plan directory exists with `manifest.json` and tasks are mostly independent.

### Process

1. **Load plan** -- Read `plan.md` + `manifest.json`. Note task IDs and waves. Do NOT read briefing files into your context.
2. **Dispatch per task** -- Send implementer a 2-3 sentence summary + briefing file path. Agent reads its own briefing from disk.
3. **Two-stage review** -- Spec compliance first (pass required), then code quality. Both must pass before marking complete.
4. **Wave boundaries** -- Re-read `manifest.json` from disk to recover task state after context compaction. Update task statuses as tasks complete.

### Per-Task Dispatch Cycle

1. **Questions** -- If subagent asks questions, answer before work begins
2. **Implement** -- Agent implements, tests, commits, self-reviews
3. **Spec review** -- Dispatch spec reviewer to verify spec compliance (nothing missing, nothing extra)
4. **Fix loop** -- If spec reviewer finds issues, implementer fixes, re-review until approved
5. **Code quality review** -- Dispatch code quality reviewer (only after spec compliance passes)
6. **Fix loop** -- If quality reviewer finds issues, implementer fixes, re-review until approved
7. **Mark complete** -- Update manifest.json with completed status

### Parallel Implementers

Parallel dispatch is encouraged when tasks have non-overlapping file ownership (determined by wave plan). Never dispatch parallel implementers to overlapping files.

### Cleanup

After all tasks complete and final review passes:
1. Optionally write `.claude/plans/<plan-id>/summary.md` with execution notes
2. Delete the plan directory: `rm -rf .claude/plans/<plan-id>/`
3. If deletion fails, warn but do not block
4. Use git-workflow stack to complete development

## Batch Mode

Use when the user explicitly wants a separate session or the plan has 10+ tasks.

### Process

1. **Load and review plan** -- Read `plan.md` + `manifest.json`, review critically, raise concerns before starting
2. **Execute batch** (default 3 tasks per batch):
   - Mark task as in_progress
   - Follow each step exactly (briefing files have bite-sized steps)
   - Run verifications as specified in the briefing's success criteria
   - Mark task as completed
3. **Report** -- Show what was implemented, verification output, say "Ready for feedback."
4. **Continue** -- Apply feedback, execute next batch (load next batch's briefing files), repeat

### Plan Format Detection

- **Plan directory format** (`.claude/plans/<plan-id>/`): Read `plan.md` and `manifest.json`, load briefing files per-batch from `briefings/task-NN.md`
- **Legacy monolithic format** (`docs/plans/*.md`): Read plan file directly, follow same batch process
- **Auto-detection**: Path contains `manifest.json` or points to a directory -> plan directory format. Points to `.md` file -> legacy format. No path given -> check `.claude/plans/` for most recent directory, fall back to `docs/plans/`

### Cleanup

After all tasks complete:
1. Optionally write `.claude/plans/<plan-id>/summary.md` with execution notes
2. Delete the plan directory: `rm -rf .claude/plans/<plan-id>/`
3. If deletion fails, warn but do not block
4. Use git-workflow stack to complete development

## Parallel Dispatch Mode

Use when facing 2+ independent tasks without shared state and no formal plan is needed.

### Decision Tree

Use when: 3+ failures with different root causes, multiple independent subsystems broken, no shared state between investigations.

Don't use when:
- **Related failures** -- fixing one might fix others, investigate together first
- **Need full context** -- understanding requires seeing entire system
- **Exploratory debugging** -- you don't know what's broken yet
- **Shared state** -- agents would interfere (consider git worktrees for isolation)

### Process

1. **Identify independent domains** -- Group failures by what's broken. Each domain is independent.
2. **Create focused agent tasks** -- Each agent gets: specific scope (one file/subsystem), clear goal, constraints (don't change other code), expected output format with token budget.
3. **Dispatch in parallel** -- One agent per problem domain.
4. **Review and integrate** -- Read each summary, verify fixes don't conflict, run full test suite, integrate all changes.

### Example

Scenario: 6 test failures across 3 files after major refactoring.

```
Agent 1 -> Fix agent-tool-abort.test.ts (timing issues)
Agent 2 -> Fix batch-completion-behavior.test.ts (event structure bug)
Agent 3 -> Fix tool-approval-race-conditions.test.ts (async execution)
```

Results: All fixes independent, no conflicts, full suite green. Three problems solved in parallel instead of sequentially.

## Team Mode

Use when the user says "team" or tasks require ongoing collaboration with named agents.

### Coordination Pattern

1. **DECOMPOSE** -- Break task into independent units with clear file ownership
2. **WAVE PLAN** -- Group units into waves (independent tasks in same wave, dependent tasks in later waves). When a plan manifest exists, use its `waves` array directly instead of manually grouping.
3. **DISPATCH WAVE** -- Spawn agents for current wave in parallel
4. **GATE** -- Wait for all agents in wave to complete, verify results, resolve conflicts
5. **NEXT WAVE** -- Feed outputs from completed wave into next wave's context
6. **VERIFY** -- Run full test suite on final merged result

### Plan-Driven Orchestration

At session start, read `plan.md` and `manifest.json`. The manifest defines waves and task dependencies. Use the manifest's wave grouping directly -- do not re-derive wave structure. Override only if runtime discoveries invalidate the grouping (e.g., unexpected file conflicts).

At each wave boundary, re-read `manifest.json` from disk. Update task statuses after each wave completes.

Point each agent at its briefing file -- do NOT paste briefing content inline. Include in dispatch prompt: plan-id, task-id, briefing path, working directory.

### Context Budget Management

- Estimate prompt size before spawning: system prompt + task context + expected file reads
- If task context exceeds ~30K tokens, split into sub-tasks or summarize inputs
- Return format constraints prevent output bloat from consuming coordinator context
- Monitor agent count -- each active agent consumes coordinator context for tracking
- Briefing files stay on disk -- include only task-id + 1-line summary + briefing path

### Cleanup

After final wave:
1. Optionally write `.claude/plans/<plan-id>/summary.md` with execution notes
2. Delete the plan directory: `rm -rf .claude/plans/<plan-id>/`
3. If deletion fails, warn but do not block
