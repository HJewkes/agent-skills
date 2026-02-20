# Category 1 Script Refactor — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Move deterministic procedural operations out of skill markdown into shell scripts, improving reliability and reducing context cost.

**Architecture:** Each task extends an existing script or creates a new one following the repo's established patterns (subcommand dispatch, `--help`, `--json`, exit codes 0/1/2). Corresponding reference markdown is updated to invoke the script instead of describing manual steps. Every script change gets bats tests.

**Tech Stack:** Bash, jq, bats-core (testing)

## Dependency Graph

No cross-task dependencies — each task modifies a different skill's files. All tasks can run in parallel.

## Wave Plan

- **Wave 1** (parallel): Tasks 1, 2, 3, 4, 5, 6

## Tasks

| # | Name | Files | Wave | Depends On |
|---|------|-------|------|------------|
| 1 | context-audit session subcommand | `skills/context-audit/scripts/audit-context`, `skills/context-audit/references/audit-procedures.md`, `tests/context-audit.bats` | 1 | — |
| 2 | repo-ci scorecard and verify | `skills/repo-ci/scripts/repo-ci`, `skills/repo-ci/references/audit-existing.md`, `skills/repo-ci/references/setup-new.md`, `tests/repo-ci.bats` | 1 | — |
| 3 | writing-plans verify-criteria | `skills/writing-plans/scripts/verify-criteria`, `skills/writing-plans/references/briefing-template.md`, `tests/verify-criteria.bats` | 1 | — |
| 4 | systematic-debugging diagnose | `skills/systematic-debugging/scripts/diagnose`, `skills/systematic-debugging/references/four-phases-detailed.md`, `tests/diagnose.bats` | 1 | — |
| 5 | skill-manager validate completeness | `skills/skills-management/scripts/skill-manager`, `tests/skill-manager.bats` | 1 | — |
| 6 | buildkite triage subcommand | `skills/buildkite/scripts/buildkite`, `skills/buildkite/references/build-debugging.md`, `tests/buildkite.bats` | 1 | — |

Detailed task specs: `./briefings/task-NN.md`
