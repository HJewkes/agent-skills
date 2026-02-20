# Task 01: context-audit session subcommand

## Architectural Context

The `audit-context` script at `skills/context-audit/scripts/audit-context` already handles static inventory scanning (glob skills, measure sizes, flag issues). It accepts a `--session` flag but the session analysis logic is minimal. The reference file `audit-procedures.md` describes detailed JSONL parsing steps (extract token usage, calculate deltas, identify spikes, correlate with tool calls) that the LLM currently performs manually. These are fully deterministic and belong in the script.

## File Ownership

**May modify:**
- `skills/context-audit/scripts/audit-context`
- `skills/context-audit/references/audit-procedures.md`
- `tests/context-audit.bats` (new file)

**Must not touch:**
- `skills/context-audit/SKILL.md`
- Any other skill's files

**Read for context (do not modify):**
- `skills/context-audit/references/audit-procedures.md` — contains the procedural steps to implement
- `tests/repo-ci.bats` — reference for bats test conventions in this repo
- `tests/test_helper.bash` — test helper to load

## Steps

### Step 1: Read the existing audit-context script

Read `skills/context-audit/scripts/audit-context` fully. Understand the existing `--session` handling, the argument parsing pattern, and the output format (both text and `--json`).

### Step 2: Read the session analysis prose in audit-procedures.md

Read `skills/context-audit/references/audit-procedures.md` lines covering session token analysis. The deterministic operations to implement are:
- Find most recent JSONL session file if no path given
- Parse each assistant turn's `usage` object (input_tokens, cache_read_input_tokens, output_tokens)
- Calculate input token deltas between consecutive turns
- Sort deltas descending, take top N (default 5, configurable via `--top`)
- For each spike, find the preceding tool call (Read, Skill, MCP, etc.)
- Calculate aggregate stats: total turns, start tokens, current tokens, growth per turn, cache hit percentage

### Step 3: Implement session analysis in the script

Extend the `--session` handling in `audit-context` to perform the full analysis. Requirements:
- `audit-context --session` — auto-discover most recent JSONL from `~/.claude/projects/`
- `audit-context --session path/to/file.jsonl` — use specified file
- Use `jq` for JSON parsing (already a dependency pattern in this repo)
- Default output: formatted markdown report with stats table + top spikes table
- With `--json`: include `session` object in JSON output with `turns`, `start_tokens`, `current_tokens`, `growth_per_turn`, `cache_hit_pct`, `spikes` array
- Each spike entry: `{turn, delta, preceding_tool, tool_args_summary}`
- Respect existing `--top N` flag for spike count

### Step 4: Update audit-procedures.md

Replace the manual session analysis steps (the "Session Token Analysis" section) with:
- A brief description of what the analysis measures
- The command to run: `audit-context --session [path]`
- How to interpret the output (what spikes mean, what cache hit % indicates)
- Keep the scoring rubric and recommendations — those require LLM judgment

Remove the step-by-step jq commands and manual delta calculation prose.

### Step 5: Write bats tests

Create `tests/context-audit.bats` following the repo's test conventions:

```bash
#!/usr/bin/env bats

setup() {
    load 'test_helper'
    AUDIT_CONTEXT="$REPO_ROOT/skills/context-audit/scripts/audit-context"
}

@test "audit-context --help prints usage" {
    run "$AUDIT_CONTEXT" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "audit-context runs without error" {
    run "$AUDIT_CONTEXT"
    assert_success
}

@test "audit-context --json produces valid JSON" {
    run "$AUDIT_CONTEXT" --json
    assert_success
    echo "$output" | python3 -m json.tool > /dev/null
}

@test "audit-context --session with nonexistent file fails" {
    run "$AUDIT_CONTEXT" --session /nonexistent/path.jsonl
    assert_failure
}

@test "audit-context with unknown option fails" {
    run "$AUDIT_CONTEXT" --nonexistent
    assert_failure
}
```

### Step 6: Verify

Run: `shellcheck skills/context-audit/scripts/audit-context`
Expected: No errors

Run: `npx bats tests/context-audit.bats`
Expected: All tests pass

### Step 7: Commit

```bash
git add skills/context-audit/scripts/audit-context skills/context-audit/references/audit-procedures.md tests/context-audit.bats
git commit -m "Add session analysis subcommand to audit-context

Move deterministic JSONL parsing, token delta calculation, and spike
correlation from procedural prose into the script. Update reference
doc to invoke script instead of describing manual steps."
```

## Success Criteria

- [ ] `shellcheck skills/context-audit/scripts/audit-context` passes
- [ ] `npx bats tests/context-audit.bats` all pass
- [ ] `audit-context --session` with a real JSONL file produces formatted output
- [ ] `audit-context --session --json` includes `session` object with spikes
- [ ] `audit-procedures.md` no longer contains step-by-step jq commands

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
- Do NOT remove the scoring rubric or recommendation logic from audit-procedures.md — those require LLM judgment and stay as prose
