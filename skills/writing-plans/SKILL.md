---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write implementation plans as a **plan directory** — a tight orchestration plan plus per-task briefing files for agents. Assume agents have zero codebase context. Document everything they need: which files to touch, complete code, testing, validation criteria. DRY. YAGNI. TDD. Frequent commits.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** Can be invoked standalone or as a handoff from brainstorming. Works in the current directory or a dedicated worktree.

**Save plans to:** `.claude/plans/YYYY-MM-DD-<feature-name>/`

See [references/plan-lifecycle.md](references/plan-lifecycle.md) for directory lifecycle (creation, execution, cleanup, stale detection).

## Plan Directory Structure

```
.claude/plans/YYYY-MM-DD-<feature-name>/
  plan.md              # Orchestration plan (<200 lines)
  manifest.json        # Machine-readable task/wave metadata
  briefings/
    task-01.md         # Per-task agent briefing
    task-02.md
    ...
```

## Format Specifications

See [references/formats.md](references/formats.md) for plan.md template, manifest.json schema, and briefing authoring rules.

Briefing file template: [references/briefing-template.md](references/briefing-template.md).

## Execution Handoff

After saving the plan directory, offer execution:

**"Plan complete and saved to `.claude/plans/<plan-id>/`. How would you like to execute it?"**

**Options:**
1. **Execute now** — I'll dispatch agents per task with review between each (stays in this session)
2. **Execute in separate session** — Open a new session and invoke plan-execution for batch execution

**REQUIRED SUB-SKILL:** Use plan-execution for either option.
