---
name: code-review
description: Unified code review system — dispatches the right review agents for the situation. Use when reviewing code for quality, bugs, compliance, or before merging.
---

# Code Review

Dispatch specialized review agents matched to the situation. Choose a mode or let context guide you.

## Review Modes

### Quick Review
**When:** Ad-hoc checks, quick sanity check, low-noise feedback
**Dispatch:** quick-reviewer agent (confidence scoring, reports only >= 80)
**Output:** High-confidence issues grouped by severity (Critical 90-100, Important 80-89)

### Deep Review
**When:** After completing a feature, before merge, in subagent-driven-development loop
**Dispatch:** deep-reviewer agent (full checklist with template placeholders)
**Placeholders:** {WHAT_WAS_IMPLEMENTED}, {PLAN_OR_REQUIREMENTS}, {BASE_SHA}, {HEAD_SHA}, {DESCRIPTION}
**Output:** Strengths, Issues (Critical/Important/Minor), Recommendations, Merge verdict

### Specialist Review
**When:** Targeted analysis of a specific quality dimension
**Dispatch:** One or more specialist agents:

| Agent | Focus |
|-------|-------|
| comment-analyzer | Comment accuracy, documentation quality, comment rot |
| test-analyzer | Test coverage quality, behavioral coverage gaps, test resilience |
| silent-failure-hunter | Error handling, silent failures, catch block specificity |
| type-design-analyzer | Type invariants, encapsulation, type usefulness |

### Comprehensive Review
**When:** Before merging to main, finishing a development branch
**Dispatch:** 4-pass structure (TDD compliance, diff-only quality, contextual quality, browser audit). See [references/comprehensive-review-procedure.md](references/comprehensive-review-procedure.md) for pass details and ordering.

## How to Request

1. Gather git context using `scripts/review-prep` (auto-detects base branch, outputs BASE_SHA, HEAD_SHA, diff stats, changed files, commit log). Use `--json` for structured output.
2. Read the reference file for your chosen agent(s)
3. Spawn `general-purpose` Task agent with the prompt + review-prep output
4. Act on feedback: fix Critical immediately, fix Important before proceeding

## Workflow Integration

| Workflow | Review Mode |
|----------|-------------|
| subagent-driven-development (per-task) | Deep Review |
| executing-plans (batch) | Deep Review |
| Before merge to main | Comprehensive Review |
| Ad-hoc / when stuck | Quick Review |
| Specific concern | Specialist Review |
| GitHub PR review + posting | github-pr skill (automated PR review orchestrator) |

## Simplification Mode

After review, optionally dispatch a simplification pass to improve clarity, consistency, and maintainability without changing functionality. Read [references/simplifier.md](references/simplifier.md) for the full agent prompt, then spawn a `general-purpose` Task agent with that prompt targeting the reviewed files.

## Handling Feedback

When receiving code review feedback (from humans or other agents), follow the structured 6-step response pattern: READ, UNDERSTAND, VERIFY, EVALUATE, RESPOND, IMPLEMENT. No performative agreement — verify before implementing, push back with technical reasoning when warranted. See [references/handling-feedback.md](references/handling-feedback.md) for the full pattern, push-back criteria, YAGNI checks, and source-specific handling.

## Red Flags

- Skipping review because "it's simple"
- Ignoring Critical issues
- Proceeding with unfixed Important issues
- Running Comprehensive passes all sequentially (1+2 are independent, parallelize)
- Not deduplicating between Pass 2 and Pass 3 in Comprehensive mode

## Reference Files

| Agent | Reference |
|-------|-----------|
| deep-reviewer | [references/deep-reviewer.md](references/deep-reviewer.md) |
| quick-reviewer | [references/quick-reviewer.md](references/quick-reviewer.md) |
| comment-analyzer | [references/comment-analyzer.md](references/comment-analyzer.md) |
| test-analyzer | [references/test-analyzer.md](references/test-analyzer.md) |
| silent-failure-hunter | [references/silent-failure-hunter.md](references/silent-failure-hunter.md) |
| type-design-analyzer | [references/type-design-analyzer.md](references/type-design-analyzer.md) |
| simplifier | [references/simplifier.md](references/simplifier.md) |
| handling-feedback | [references/handling-feedback.md](references/handling-feedback.md) |
