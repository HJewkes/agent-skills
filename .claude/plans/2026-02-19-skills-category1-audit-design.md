# Skills Audit: Category 1 — Deterministic Operations to Scripts

## Overview

Review all skills for "Category 1" patterns — places where markdown instructs the LLM to perform deterministic, programmable operations that should be shell scripts instead. Script execution is faster, more reliable, and frees context for actual reasoning.

## Design Principle

If a skill's markdown says "run X, check output for Y, if Z then do W" — and no human judgment or LLM reasoning is required — that belongs in a script. The markdown should say "run `script-name subcommand`" and describe what to do with the results.

## Audit Framework

Each skill evaluated on:

- **Category 1 Score**: How much deterministic work lives in prose (High/Medium/Low/None)
- **Impact**: Context savings + reliability gain + speed improvement
- **Effort**: Extend existing script vs new simple script vs new complex script

## Findings & Priority Ranking

### Phase 1: Extend Existing Scripts (High Impact / Low Effort)

#### PR 1: context-audit — session analysis subcommand

**Current state**: `audit-context` script exists but `audit-procedures.md` (lines ~59-115) describes manual JSONL parsing: extract token usage with jq, calculate deltas between turns, sort descending, take top 5 spikes, correlate with preceding tool calls. All deterministic.

**Proposed state**: New `audit-context session [jsonl-path]` subcommand that:
- Auto-discovers most recent session JSONL if no path given
- Parses token usage per turn
- Calculates input token deltas between consecutive turns
- Identifies top 5 spikes
- Correlates each spike with the preceding tool call
- Outputs formatted report (default) or `--json`

**Markdown changes**: Replace ~60 lines of procedural steps in `audit-procedures.md` with script invocation and guidance on interpreting results.

**Tests**: bats tests for session subcommand (mock JSONL input, verify output format).

#### PR 2: repo-ci — scorecard and verification

**Current state**: `repo-ci audit` outputs raw JSON. Reference files (`audit-existing.md`, `setup-new.md`) describe manual steps: parse JSON into scorecard table, categorize PASS/WARN/FAIL, compare against baseline after fixes, check package.json for required npm scripts.

**Proposed state**:
- `repo-ci audit --scorecard` — formatted markdown table grouped by area with status indicators
- `repo-ci verify --baseline <file>` — diff two audit JSON outputs, report what was fixed vs remaining gaps
- Post-setup validation integrated into `repo-ci audit` (check for required npm scripts, GitHub rulesets)

**Markdown changes**: Remove procedural parsing prose from `audit-existing.md` and `setup-new.md`. Keep guidance on interpreting results and deciding what to fix.

**Tests**: bats tests for `--scorecard` output format and `verify` diff logic.

### Phase 2: New Simple Scripts (High Impact / Medium Effort)

#### PR 3: writing-plans — verify-criteria utility

**Current state**: Briefing templates describe "run test, check exit code, run lint, check exit code" as prose. Every briefing repeats this pattern. LLM must manually run each command and interpret exit codes.

**Proposed state**: New `writing-plans/scripts/verify-criteria` that:
- Takes N commands as arguments
- Runs each sequentially
- Reports pass/fail per command with captured output on failure
- Supports `--json` for structured output
- Exit code: 0 if all pass, 1 if any fail

**Usage in briefings**:
```bash
verify-criteria "npm test -- path/to/test.ts" "npm run lint -- --quiet" "npm run typecheck"
```

**Markdown changes**: Update briefing template to reference script instead of listing manual verification steps.

**Tests**: bats tests with mock commands (true/false) to verify reporting.

#### PR 4: systematic-debugging — diagnostic harness

**Current state**: `four-phases-detailed.md` describes multi-layer diagnostic sequences as prose (check env vars, check keychain, check signing — report where data flow breaks). Also describes test pollution detection (run with debug output, grep stack traces, correlate with test execution).

**Proposed state**: New `systematic-debugging/scripts/diagnose` with subcommands:
- `diagnose layers "cmd1" "cmd2" "cmd3"` — runs each command sequentially, reports output and exit code, identifies first failure point in the chain
- `diagnose test-isolation "test-cmd" "grep-pattern"` — runs test command, greps output for pattern, reports which test files/lines produce matches

**Markdown changes**: Replace diagnostic sequences in `four-phases-detailed.md` with script invocation. Keep the reasoning framework (what to look for, how to interpret).

**Tests**: bats tests with mock commands.

### Phase 3: Remaining Extensions (Medium Impact / Low Effort)

#### PR 5: skills-management — validation completeness

**Current state**: `skill-manager validate` exists but some rules from `agent-skills-spec.md` are still only described in reference prose (body under 500 lines, description prefix "Use when").

**Proposed state**: Audit all rules in `agent-skills-spec.md`, ensure each is checked by `skill-manager validate`. Add any missing checks. Remove redundant validation prose from references.

**Tests**: Extend existing bats tests to cover new validation rules.

#### PR 6: buildkite — triage subcommand

**Current state**: Buildkite wrapper script exists. `build-debugging.md` describes triage workflow as prose: fetch failed builds, download logs, grep for failure patterns (test failures, dependency errors, timeouts, OOM).

**Proposed state**: New `buildkite triage <pipeline>` subcommand that:
- Fetches recent failed builds via Buildkite API/CLI
- Downloads logs for failed jobs
- Categorizes failures by regex patterns (test, dependency, timeout, permission, OOM)
- Outputs categorized report

**Markdown changes**: Replace triage workflow prose in `build-debugging.md` with script invocation. Keep guidance on escalation and fix strategies.

**Tests**: bats tests with mock API responses.

## Execution Plan

- Per-PR workflow: branch (`refactor/<skill>-<description>`) → implement → shellcheck clean → bats tests → PR
- Phases are sequential but PRs within a phase can be parallelized
- Each PR updates both the script and the corresponding markdown files

## Out of Scope

- **Category 2** (multi-workflow context surfacing via CLI vs reference files) — see backlog doc
- **Category 3** (linear human-dialog steps with compaction resilience) — see backlog doc
- Skills with no Category 1 patterns: brainstorming, executing-plans, TDD, code-review, finishing-a-development-branch, frontend-design, coordinator
