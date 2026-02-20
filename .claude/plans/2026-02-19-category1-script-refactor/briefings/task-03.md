# Task 03: writing-plans verify-criteria

## Architectural Context

The `writing-plans` skill generates task briefings that include success criteria like "run `npm test`, run `npm run lint`, run `npm run typecheck`". Currently these are described as prose in the briefing template, and the LLM manually runs each command and interprets results. A `verify-criteria` script can run all criteria commands, report pass/fail per command, and give a summary — making verification deterministic and reducing context overhead in agent briefings.

## File Ownership

**May modify:**
- `skills/writing-plans/scripts/verify-criteria` (new file)
- `skills/writing-plans/references/briefing-template.md`
- `tests/verify-criteria.bats` (new file)

**Must not touch:**
- `skills/writing-plans/SKILL.md`
- Any other skill's files

**Read for context (do not modify):**
- `skills/writing-plans/references/briefing-template.md` — the template to update
- `tests/repo-ci.bats` — reference for bats test conventions
- `tests/test_helper.bash` — test helper to load

## Steps

### Step 1: Create the scripts directory

```bash
mkdir -p skills/writing-plans/scripts
```

### Step 2: Write the verify-criteria script

Create `skills/writing-plans/scripts/verify-criteria`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# verify-criteria — Run a list of verification commands and report pass/fail
#
# Usage: verify-criteria "cmd1" "cmd2" "cmd3"
#        verify-criteria --json "cmd1" "cmd2"
#
# Exit codes: 0 = all pass, 1 = any fail

usage() {
    cat <<'EOF'
Usage: verify-criteria [--json] "command1" "command2" ...

Run each command and report pass/fail.

Options:
  --json    Output results as JSON
  --help    Show this help

Exit codes:
  0  All commands passed
  1  One or more commands failed
EOF
}

JSON_OUTPUT=false
COMMANDS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --json) JSON_OUTPUT=true; shift ;;
        --help) usage; exit 0 ;;
        --) shift; COMMANDS+=("$@"); break ;;
        -*) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
        *) COMMANDS+=("$1"); shift ;;
    esac
done

if [[ ${#COMMANDS[@]} -eq 0 ]]; then
    echo "Error: No commands specified" >&2
    usage >&2
    exit 1
fi

PASS=0
FAIL=0
RESULTS=()

for cmd in "${COMMANDS[@]}"; do
    if output=$(eval "$cmd" 2>&1); then
        status="pass"
        ((PASS++))
    else
        status="fail"
        ((FAIL++))
    fi
    RESULTS+=("$(printf '%s\t%s\t%s' "$status" "$cmd" "$output")")
done

if $JSON_OUTPUT; then
    printf '{"total":%d,"passed":%d,"failed":%d,"results":[' "${#COMMANDS[@]}" "$PASS" "$FAIL"
    first=true
    for r in "${RESULTS[@]}"; do
        status=$(echo "$r" | cut -f1)
        cmd=$(echo "$r" | cut -f2)
        output=$(echo "$r" | cut -f3-)
        $first || printf ','
        first=false
        printf '{"command":"%s","status":"%s","output":"%s"}' \
            "$(echo "$cmd" | sed 's/"/\\"/g')" \
            "$status" \
            "$(echo "$output" | head -5 | sed 's/"/\\"/g' | tr '\n' ' ')"
    done
    printf ']}\n'
else
    printf "\n## Verification Results\n\n"
    printf "| # | Status | Command |\n"
    printf "|---|--------|----------|\n"
    i=1
    for r in "${RESULTS[@]}"; do
        status=$(echo "$r" | cut -f1)
        cmd=$(echo "$r" | cut -f2)
        if [[ "$status" == "pass" ]]; then
            indicator="PASS"
        else
            indicator="FAIL"
        fi
        printf "| %d | %s | \`%s\` |\n" "$i" "$indicator" "$cmd"
        ((i++))
    done
    printf "\n**%d passed, %d failed**\n" "$PASS" "$FAIL"

    # Show failure output for failed commands
    if [[ $FAIL -gt 0 ]]; then
        printf "\n### Failures\n\n"
        for r in "${RESULTS[@]}"; do
            status=$(echo "$r" | cut -f1)
            cmd=$(echo "$r" | cut -f2)
            output=$(echo "$r" | cut -f3-)
            if [[ "$status" == "fail" ]]; then
                printf "**\`%s\`**:\n\`\`\`\n%s\n\`\`\`\n\n" "$cmd" "$(echo "$output" | head -20)"
            fi
        done
    fi
fi

[[ $FAIL -eq 0 ]]
```

Make it executable: `chmod +x skills/writing-plans/scripts/verify-criteria`

### Step 3: Update briefing-template.md

In the Success Criteria section of the template, add a note showing how to use verify-criteria alongside or instead of manual commands:

Replace the current success criteria example block with one that shows both approaches — the individual commands (for reference) and the verify-criteria invocation (for execution):

```markdown
## Success Criteria

Verify all at once: `verify-criteria "npm test -- path/to/test.ts" "npm run lint -- --quiet" "npm run typecheck"`

Or individually:
- [ ] Tests pass: `npm test -- path/to/test.ts`
- [ ] No new lint warnings: `npm run lint -- --quiet`
- [ ] Types check: `npm run typecheck`
- [ ] [Feature-specific acceptance criterion]
```

### Step 4: Write bats tests

Create `tests/verify-criteria.bats`:

```bash
#!/usr/bin/env bats

setup() {
    load 'test_helper'
    VERIFY="$REPO_ROOT/skills/writing-plans/scripts/verify-criteria"
}

@test "verify-criteria --help prints usage" {
    run "$VERIFY" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "verify-criteria with no args fails" {
    run "$VERIFY"
    assert_failure
}

@test "verify-criteria with passing commands succeeds" {
    run "$VERIFY" "true" "true"
    assert_success
    assert_output --partial "2 passed, 0 failed"
}

@test "verify-criteria with failing command fails" {
    run "$VERIFY" "true" "false"
    assert_failure
    assert_output --partial "1 passed, 1 failed"
}

@test "verify-criteria --json produces valid JSON" {
    run "$VERIFY" --json "true"
    assert_success
    echo "$output" | python3 -m json.tool > /dev/null
}

@test "verify-criteria --json reports failure" {
    run "$VERIFY" --json "false"
    assert_failure
    echo "$output" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d['failed']==1"
}
```

### Step 5: Verify

Run: `shellcheck skills/writing-plans/scripts/verify-criteria`
Expected: No errors

Run: `npx bats tests/verify-criteria.bats`
Expected: All tests pass

### Step 6: Commit

```bash
git add skills/writing-plans/scripts/verify-criteria skills/writing-plans/references/briefing-template.md tests/verify-criteria.bats
git commit -m "Add verify-criteria script for deterministic success checks

New utility that runs a list of verification commands and reports
pass/fail per command. Supports --json output. Update briefing
template to reference the script."
```

## Success Criteria

- [ ] `shellcheck skills/writing-plans/scripts/verify-criteria` passes
- [ ] `npx bats tests/verify-criteria.bats` all pass
- [ ] `verify-criteria "true" "true"` exits 0 with formatted table
- [ ] `verify-criteria "true" "false"` exits 1 with failure details
- [ ] `verify-criteria --json "true"` produces valid JSON

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
- Do NOT use `eval` unsafely — commands come from trusted briefing files, but still avoid injection risks where possible
