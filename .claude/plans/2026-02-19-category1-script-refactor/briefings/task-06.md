# Task 06: buildkite triage subcommand

## Architectural Context

The `buildkite` script at `skills/buildkite/scripts/buildkite` is currently a thin wrapper that sources credentials from `~/.buildkite-env` and passes all arguments through to the `bk` CLI. The reference file `build-debugging.md` describes a triage workflow — fetching failed builds, downloading logs, and categorizing failures by regex patterns — that is fully deterministic. This should be a `triage` subcommand in the wrapper, intercepted before passthrough.

## File Ownership

**May modify:**
- `skills/buildkite/scripts/buildkite`
- `skills/buildkite/references/build-debugging.md`
- `tests/buildkite.bats` (new file)

**Must not touch:**
- `skills/buildkite/SKILL.md`
- Any other skill's files

**Read for context (do not modify):**
- `skills/buildkite/references/build-debugging.md` — contains the triage workflow and failure patterns
- `skills/buildkite/scripts/buildkite` — current wrapper to extend

## Steps

### Step 1: Read the existing buildkite wrapper and build-debugging reference

Read both files fully. Understand:
- How the wrapper sources credentials and passes through to `bk`
- The triage workflow steps (list failed builds, get logs, categorize)
- The 7 failure categories with their grep patterns

### Step 2: Add triage subcommand

Modify `skills/buildkite/scripts/buildkite` to intercept `triage` before the passthrough. The subcommand should:

**`buildkite triage <pipeline-slug> [--build <number>] [--last <N>]`**

1. If `--build` specified, triage that specific build. Otherwise, fetch the last N failed builds (default 1, configurable via `--last`).
2. For each failed build:
   a. Get the build details via `bk build view`
   b. List failed jobs via `bk job list`
   c. For each failed job, get the log via `bk job log`
   d. Categorize the failure by running grep patterns against the log:

| Category | Pattern |
|----------|---------|
| Test Failure | `FAIL\|FAILED\|AssertionError\|Expected.*got` |
| Dependency | `ERR!\|could not resolve\|not found` |
| Timeout | `timed out\|exceeded.*time\|terminated` |
| OOM | `Killed\|OOMKilled\|signal.*killed` |
| Auth/Permission | `403\|401\|forbidden\|unauthorized\|permission denied` |
| Infrastructure | `docker.*pull.*failed\|agent disconnected\|network` |
| Unknown | (no pattern matched) |

3. Output a report:

```
## Build Triage: pipeline-slug #123

| Job | Category | Key Line |
|-----|----------|----------|
| tests (ubuntu) | Test Failure | FAIL src/auth.test.ts: Expected 200, got 401 |
| deploy | Auth/Permission | 403 Forbidden: push access denied |

**Summary: 1 test failure, 1 auth issue**
```

The wrapper structure should be:
- Check if `$1` is `triage` → intercept and run triage logic
- Check if `$1` is `--help` and no other args → show extended help including triage
- Otherwise → passthrough to `bk` as before

### Step 3: Update build-debugging.md

Replace the step-by-step triage workflow (the numbered "find failed build → inspect → get log → categorize" sequence) with:
```
Run `buildkite triage <pipeline-slug>` to automatically fetch failed builds, analyze logs, and categorize failures.
```

Keep the failure category descriptions and their remediation guidance (what to do about each type of failure). The LLM still needs to decide the fix — the script just does the diagnosis.

### Step 4: Write bats tests

Create `tests/buildkite.bats`. Since the real `bk` CLI may not be installed in CI, tests should focus on argument parsing and help output:

```bash
#!/usr/bin/env bats

setup() {
    load 'test_helper'
    BUILDKITE="$REPO_ROOT/skills/buildkite/scripts/buildkite"
}

@test "buildkite --help prints usage" {
    # Mock bk to avoid requiring real CLI
    bk() { echo "bk help"; }
    export -f bk
    run "$BUILDKITE" --help
    # Should succeed (either wrapper help or passthrough)
    assert_success
}

@test "buildkite triage with no pipeline fails" {
    run "$BUILDKITE" triage
    assert_failure
    assert_output --partial "pipeline"
}

@test "buildkite triage --help prints triage usage" {
    run "$BUILDKITE" triage --help
    assert_success
    assert_output --partial "Usage:"
}
```

### Step 5: Verify

Run: `shellcheck skills/buildkite/scripts/buildkite`
Expected: No errors

Run: `npx bats tests/buildkite.bats`
Expected: All tests pass

### Step 6: Commit

```bash
git add skills/buildkite/scripts/buildkite skills/buildkite/references/build-debugging.md tests/buildkite.bats
git commit -m "Add triage subcommand to buildkite wrapper

Intercepts 'buildkite triage <pipeline>' to fetch failed builds,
analyze logs, and categorize failures by pattern. Update build
debugging reference to invoke script instead of manual triage steps."
```

## Success Criteria

- [ ] `shellcheck skills/buildkite/scripts/buildkite` passes
- [ ] `npx bats tests/buildkite.bats` all pass
- [ ] `buildkite triage --help` prints triage-specific usage
- [ ] `buildkite triage` with no args shows error about missing pipeline
- [ ] `build-debugging.md` references the triage subcommand instead of manual steps

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
- Do NOT break the existing passthrough behavior — `buildkite <anything except triage>` must still pass through to `bk`
- Do NOT hardcode credentials — continue using the existing `~/.buildkite-env` sourcing pattern
