# Guardrails

## Stop Conditions

**STOP executing immediately when:**
- Hit a blocker mid-batch (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to plan review when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** -- stop and ask.

## Branch Safety

Never start implementation on main/master branch without explicit user consent.

## Plan Directory Cleanup

After all tasks complete and verification passes:
1. Optionally write `.claude/plans/<plan-id>/summary.md` with execution notes
2. Delete the plan directory: `rm -rf .claude/plans/<plan-id>/`
3. If deletion fails, warn but do not block

## Stale Plan Detection

A plan is stale when:
- Plan directory is 7+ days old AND has incomplete tasks
- Check file modification timestamps on `manifest.json`

When a stale plan is detected, surface it to the user before proceeding. Do not silently resume stale plans.

## Execution Checklist

- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Read briefing files per-batch, not all at once
- Reference skills when plan says to
- Between batches: just report and wait
- Stop when blocked, don't guess
- Never start implementation on main/master without explicit consent
- Re-read manifest.json at wave boundaries
- Clean up plan directory after completion
