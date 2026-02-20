# Task 02: repo-ci scorecard and verify

## Architectural Context

The `repo-ci` script at `skills/repo-ci/scripts/repo-ci` has two subcommands: `audit` and `setup`. The `audit` command outputs raw JSON (with `--json`) or colored text. The reference files `audit-existing.md` and `setup-new.md` describe manual post-processing steps: parsing JSON into a scorecard table, comparing two audit runs to verify fixes, and checking for required npm scripts. These are deterministic and belong in the script.

## File Ownership

**May modify:**
- `skills/repo-ci/scripts/repo-ci`
- `skills/repo-ci/references/audit-existing.md`
- `skills/repo-ci/references/setup-new.md`
- `tests/repo-ci.bats`

**Must not touch:**
- `skills/repo-ci/SKILL.md`
- `skills/repo-ci/references/standards.md`
- Any other skill's files

**Read for context (do not modify):**
- `skills/repo-ci/references/audit-existing.md` — contains the procedural steps to replace
- `skills/repo-ci/references/setup-new.md` — contains post-setup verification steps
- `skills/repo-ci/references/standards.md` — the standards the audit checks against

## Steps

### Step 1: Read the existing repo-ci script

Read `skills/repo-ci/scripts/repo-ci` fully. Understand the `audit` subcommand's output format, the JSON structure of its `--json` output (especially the `areas` array with `name`, `status`, `message` fields), and the argument parsing pattern.

### Step 2: Add `--scorecard` flag to audit

Add a `--scorecard` flag to `repo-ci audit` that formats the JSON output as a markdown scorecard table:

```
## CI Health Scorecard

| Area | Status | Details |
|------|--------|---------|
| CI Workflow | PASS | All required jobs present |
| Release Workflow | WARN | Missing github-release job |
| Formatter | PASS | Prettier configured |
| Coverage | FAIL | No coverage thresholds set |
| Branch Protection | PASS | Rulesets configured |
| Security Scanning | PASS | Gitleaks + audit present |

**Result: 4 PASS, 1 WARN, 1 FAIL**
```

Implementation: run the existing audit logic, format output as table. Use unicode indicators if stdout is TTY (checkmark/warning/cross), plain text otherwise.

### Step 3: Add `verify` subcommand

Add `repo-ci verify --baseline <file>` subcommand:
- Takes a baseline JSON file (output of a previous `repo-ci audit --json`)
- Runs a fresh `repo-ci audit --json`
- Compares area statuses between baseline and current
- Reports what improved, what regressed, what stayed the same
- Exit code: 0 if no regressions, 1 if any area regressed, 2 if unchanged gaps remain

Output format:
```
## Verification Report

| Area | Before | After | Change |
|------|--------|-------|--------|
| Coverage | FAIL | PASS | FIXED |
| Release Workflow | WARN | WARN | — |

**1 fixed, 0 regressed, 1 remaining**
```

### Step 4: Add post-setup npm script check

In the `setup` subcommand's post-generation output, add automatic verification of required npm scripts. After generating workflow files, check `package.json` for scripts referenced by the generated CI (e.g., `format:check`, `test:coverage`). Warn if missing:

```
Generated: .github/workflows/ci.yml

Post-setup check:
  ✓ npm script 'test' found
  ✗ npm script 'format:check' not found — CI will fail without it
  ✗ npm script 'test:coverage' not found — coverage job will fail
```

Use `jq` to read `package.json` and check for script keys.

### Step 5: Update audit-existing.md

Replace the step-by-step JSON parsing and scorecard building prose with:
- "Run `repo-ci audit --scorecard` to see a formatted health report"
- "After making fixes, verify improvements: save baseline with `repo-ci audit --json > baseline.json`, make fixes, then run `repo-ci verify --baseline baseline.json`"
- Keep the guidance on interpreting results, deciding what to fix, and the custom CI caveat

### Step 6: Update setup-new.md

Replace the manual post-setup npm script verification steps with a note that `repo-ci setup` now checks automatically. Keep the CODECOV_TOKEN and branch ruleset instructions (those are GitHub UI actions, not scriptable).

### Step 7: Extend bats tests

Add to `tests/repo-ci.bats`:

```bash
@test "repo-ci audit --scorecard produces table" {
    cd "$REPO_ROOT"
    run "$REPO_CI" audit --scorecard
    if [[ "$status" -ne 0 && "$status" -ne 2 ]]; then
        fail "unexpected exit status $status"
    fi
    assert_output --partial "| Area"
}

@test "repo-ci verify --baseline with missing file fails" {
    run "$REPO_CI" verify --baseline /nonexistent/baseline.json
    assert_failure
}

@test "repo-ci verify --help prints usage" {
    run "$REPO_CI" verify --help
    assert_success
    assert_output --partial "Usage:"
}
```

### Step 8: Verify

Run: `shellcheck skills/repo-ci/scripts/repo-ci`
Expected: No errors

Run: `npx bats tests/repo-ci.bats`
Expected: All tests pass

### Step 9: Commit

```bash
git add skills/repo-ci/scripts/repo-ci skills/repo-ci/references/audit-existing.md skills/repo-ci/references/setup-new.md tests/repo-ci.bats
git commit -m "Add scorecard, verify, and post-setup checks to repo-ci

Add --scorecard flag for formatted audit output, verify subcommand
for diffing audit runs, and automatic npm script validation after
setup. Update reference docs to use script instead of manual steps."
```

## Success Criteria

- [ ] `shellcheck skills/repo-ci/scripts/repo-ci` passes
- [ ] `npx bats tests/repo-ci.bats` all pass
- [ ] `repo-ci audit --scorecard` produces a formatted table
- [ ] `repo-ci verify --baseline file.json` compares and reports changes
- [ ] `repo-ci setup` warns about missing npm scripts after generation
- [ ] `audit-existing.md` no longer describes manual JSON parsing steps

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
- Do NOT change the existing audit output format — `--scorecard` is additive
