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

@test "git-workflow commit without staged changes fails" {
    cd "$REPO_ROOT"
    run "$GIT_WORKFLOW" commit
    assert_failure
    assert_output --partial "no staged changes"
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
