# Task 04: systematic-debugging diagnose harness

## Architectural Context

The `systematic-debugging` skill has no scripts directory. Its reference file `four-phases-detailed.md` describes diagnostic sequences that are mostly LLM-judgment-heavy (form hypotheses, compare patterns), but two operations are deterministic: (1) multi-layer boundary checking — running a sequence of commands to identify where data flow breaks, and (2) test isolation — running tests with a grep filter to identify which test produces a specific output pattern. These belong in a script.

## File Ownership

**May modify:**
- `skills/systematic-debugging/scripts/diagnose` (new file)
- `skills/systematic-debugging/references/four-phases-detailed.md`
- `tests/diagnose.bats` (new file)

**Must not touch:**
- `skills/systematic-debugging/SKILL.md`
- `skills/systematic-debugging/references/debugging-signals.md`
- Any other skill's files

**Read for context (do not modify):**
- `skills/systematic-debugging/references/four-phases-detailed.md` — contains the diagnostic sequences to extract
- `tests/repo-ci.bats` — reference for bats test conventions

## Steps

### Step 1: Create the scripts directory

```bash
mkdir -p skills/systematic-debugging/scripts
```

### Step 2: Write the diagnose script

Create `skills/systematic-debugging/scripts/diagnose` with two subcommands:

**`diagnose layers "cmd1" "cmd2" "cmd3" ...`**
- Runs each command sequentially
- Captures stdout, stderr, and exit code for each
- Reports results as a numbered list showing where the chain first fails
- Useful for checking data flow across component boundaries (env → keychain → signing → codesign)

**`diagnose test-isolation "test-cmd" "grep-pattern"`**
- Runs the test command
- Greps combined output for the pattern
- Reports matching lines with context (file/line if parseable)
- Useful for finding which test produces unwanted side effects

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: diagnose <command> [args...]

Commands:
  layers "cmd1" "cmd2" ...    Run commands sequentially, report where chain breaks
  test-isolation "cmd" "pat"  Run test command, grep output for pattern

Options:
  --help    Show this help

Exit codes:
  0  All layers passed / pattern not found
  1  A layer failed / pattern found
  2  Usage error
EOF
}

cmd_layers() {
    if [[ $# -eq 0 ]]; then
        echo "Error: No commands specified" >&2
        echo "Usage: diagnose layers \"cmd1\" \"cmd2\" ..." >&2
        exit 2
    fi

    printf "## Layer Diagnosis\n\n"
    printf "| Layer | Command | Status | Exit Code |\n"
    printf "|-------|---------|--------|-----------|\n"

    layer=1
    first_failure=""
    for cmd in "$@"; do
        if output=$(eval "$cmd" 2>&1); then
            ec=0
            status="PASS"
        else
            ec=$?
            status="FAIL"
            [[ -z "$first_failure" ]] && first_failure=$layer
        fi
        printf "| %d | \`%s\` | %s | %d |\n" "$layer" "$cmd" "$status" "$ec"
        ((layer++))
    done

    printf "\n"
    if [[ -n "$first_failure" ]]; then
        printf "**First failure: Layer %d** — investigate this boundary.\n" "$first_failure"
        exit 1
    else
        printf "**All layers passed.**\n"
        exit 0
    fi
}

cmd_test_isolation() {
    if [[ $# -lt 2 ]]; then
        echo "Error: Requires test command and grep pattern" >&2
        echo "Usage: diagnose test-isolation \"test-cmd\" \"pattern\"" >&2
        exit 2
    fi

    local test_cmd="$1"
    local pattern="$2"

    printf "## Test Isolation\n\n"
    printf "Command: \`%s\`\n" "$test_cmd"
    printf "Pattern: \`%s\`\n\n" "$pattern"

    local output
    output=$(eval "$test_cmd" 2>&1) || true

    local matches
    matches=$(echo "$output" | grep -n "$pattern" 2>/dev/null) || true

    if [[ -z "$matches" ]]; then
        printf "**Pattern not found in output.** No isolation issue detected.\n"
        exit 0
    else
        local count
        count=$(echo "$matches" | wc -l | tr -d ' ')
        printf "**Found %s match(es):**\n\n" "$count"
        printf "\`\`\`\n%s\n\`\`\`\n" "$matches"
        exit 1
    fi
}

[[ $# -gt 0 ]] || { usage; exit 2; }

case "$1" in
    layers)         shift; cmd_layers "$@" ;;
    test-isolation) shift; cmd_test_isolation "$@" ;;
    --help)         usage; exit 0 ;;
    *)              echo "Unknown command: $1" >&2; usage >&2; exit 2 ;;
esac
```

Make it executable: `chmod +x skills/systematic-debugging/scripts/diagnose`

### Step 3: Update four-phases-detailed.md

In Phase 1 (Root Cause Investigation), replace the multi-layer diagnostic example with a reference to the script:

Replace the detailed bash commands showing layer-by-layer env/keychain/signing checks with:
```
For multi-component systems, use `diagnose layers` to systematically check each boundary:
    diagnose layers "echo IDENTITY: ${IDENTITY:+SET}" "env | grep IDENTITY" "security list-keychains" "codesign --sign ..."
```

In the test pollution section, add a reference:
```
To find which test produces unwanted side effects:
    diagnose test-isolation "npm test 2>&1" "DEBUG git init"
```

Keep all the reasoning guidance (how to interpret results, when to form hypotheses, the 3-fix rule). Only replace the deterministic command sequences.

### Step 4: Write bats tests

Create `tests/diagnose.bats`:

```bash
#!/usr/bin/env bats

setup() {
    load 'test_helper'
    DIAGNOSE="$REPO_ROOT/skills/systematic-debugging/scripts/diagnose"
}

@test "diagnose --help prints usage" {
    run "$DIAGNOSE" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "diagnose with no args shows usage" {
    run "$DIAGNOSE"
    assert_failure
}

@test "diagnose layers with all passing commands succeeds" {
    run "$DIAGNOSE" layers "true" "true" "true"
    assert_success
    assert_output --partial "All layers passed"
}

@test "diagnose layers identifies first failure" {
    run "$DIAGNOSE" layers "true" "false" "true"
    assert_failure
    assert_output --partial "First failure: Layer 2"
}

@test "diagnose layers with no commands fails" {
    run "$DIAGNOSE" layers
    assert_failure
}

@test "diagnose test-isolation finds pattern" {
    run "$DIAGNOSE" test-isolation "echo 'hello world'" "hello"
    assert_failure  # exit 1 = pattern found
    assert_output --partial "Found"
}

@test "diagnose test-isolation no match" {
    run "$DIAGNOSE" test-isolation "echo 'hello'" "nonexistent"
    assert_success
    assert_output --partial "Pattern not found"
}

@test "diagnose unknown command fails" {
    run "$DIAGNOSE" nonexistent
    assert_failure
}
```

### Step 5: Verify

Run: `shellcheck skills/systematic-debugging/scripts/diagnose`
Expected: No errors

Run: `npx bats tests/diagnose.bats`
Expected: All tests pass

### Step 6: Commit

```bash
git add skills/systematic-debugging/scripts/diagnose skills/systematic-debugging/references/four-phases-detailed.md tests/diagnose.bats
git commit -m "Add diagnose script for deterministic debugging operations

New script with layers (sequential boundary checking) and
test-isolation (grep test output for patterns) subcommands.
Update four-phases reference to invoke script instead of
describing manual diagnostic sequences."
```

## Success Criteria

- [ ] `shellcheck skills/systematic-debugging/scripts/diagnose` passes
- [ ] `npx bats tests/diagnose.bats` all pass
- [ ] `diagnose layers "true" "false"` identifies layer 2 as first failure
- [ ] `diagnose test-isolation "echo hello" "hello"` reports match
- [ ] `four-phases-detailed.md` references the script for deterministic operations

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
- Do NOT remove reasoning guidance from four-phases-detailed.md — only replace deterministic command sequences
