# Task 09: Bats Tests

## Architectural Context

The repo uses bats-core for testing CLI scripts. Tests follow the pattern established in `tests/skill-manager.bats` and `tests/repo-ci.bats`: setup loads test_helper, tests verify --help, subcommand routing, and basic functionality. Tests run via `npx bats tests/`.

## File Ownership

**May modify:**
- `tests/git-workflow.bats`

**Must not touch:**
- `skills/git-workflow/scripts/git-workflow`
- Any other test files

**Read for context (do not modify):**
- `tests/repo-ci.bats` — example test patterns
- `tests/skill-manager.bats` — example test patterns
- `tests/test_helper.bash` — test helper setup

## Steps

### Step 1: Write test file

Write `tests/git-workflow.bats`:

```bash
#!/usr/bin/env bats

setup() {
    load 'test_helper'
    GIT_WORKFLOW="$REPO_ROOT/skills/git-workflow/scripts/git-workflow"
}

@test "git-workflow --help prints usage" {
    run "$GIT_WORKFLOW" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "git-workflow status runs in this repo" {
    cd "$REPO_ROOT"
    run "$GIT_WORKFLOW" status
    assert_success
    assert_output --partial "Tool:"
    assert_output --partial "Branch:"
}

@test "git-workflow status --json produces valid JSON" {
    cd "$REPO_ROOT"
    run "$GIT_WORKFLOW" status --json
    assert_success
    echo "$output" | python3 -m json.tool > /dev/null
}

@test "git-workflow commit --help prints usage" {
    run "$GIT_WORKFLOW" commit --help
    assert_success
    assert_output --partial "Usage:"
}

@test "git-workflow commit without message fails" {
    cd "$REPO_ROOT"
    run "$GIT_WORKFLOW" commit
    assert_failure
    assert_output --partial "commit message required"
}

@test "git-workflow split --help prints usage" {
    run "$GIT_WORKFLOW" split --help
    assert_success
    assert_output --partial "Usage:"
}

@test "git-workflow stack --help prints usage" {
    run "$GIT_WORKFLOW" stack --help
    assert_success
    assert_output --partial "Usage:"
}

@test "git-workflow stack shows branch info" {
    cd "$REPO_ROOT"
    run "$GIT_WORKFLOW" stack
    assert_success
}

@test "git-workflow worktree --help prints usage" {
    run "$GIT_WORKFLOW" worktree --help
    assert_success
    assert_output --partial "Usage:"
}

@test "git-workflow worktree without branch fails" {
    run "$GIT_WORKFLOW" worktree
    assert_failure
    assert_output --partial "branch name required"
}

@test "git-workflow clean --help prints usage" {
    run "$GIT_WORKFLOW" clean --help
    assert_success
    assert_output --partial "Usage:"
}

@test "git-workflow clean --dry-run runs without error" {
    cd "$REPO_ROOT"
    run "$GIT_WORKFLOW" clean --dry-run
    assert_success
}

@test "git-workflow with unknown command fails" {
    run "$GIT_WORKFLOW" nonexistent-command
    assert_failure
}

@test "git-workflow status defaults when no command given" {
    cd "$REPO_ROOT"
    run "$GIT_WORKFLOW"
    assert_success
    assert_output --partial "Tool:"
}
```

### Step 2: Verify tests pass

```bash
cd /Users/hjewkes/Documents/projects/agents-skills
npx bats tests/git-workflow.bats
```

Expected: all tests pass.

### Step 3: Run full test suite

```bash
npx bats tests/
```

Expected: all tests pass (including existing tests).

### Step 4: Commit

```bash
git add tests/git-workflow.bats
git commit -m "Add bats tests for git-workflow CLI"
```

## Success Criteria

- [ ] `npx bats tests/git-workflow.bats` — all tests pass
- [ ] `npx bats tests/` — full suite passes (no regressions)
- [ ] Tests cover: --help for all subcommands, status output, error cases, default behavior

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
- Do NOT modify the CLI script to make tests pass — report failures
