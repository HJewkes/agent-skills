#!/usr/bin/env bats

setup() {
    load 'test_helper'
    SKILL_MANAGER="$REPO_ROOT/skills/skills-management/scripts/skill-manager"
}

@test "skill-manager --help prints usage" {
    run "$SKILL_MANAGER" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "skill-manager validate runs without crashing" {
    cd "$REPO_ROOT"
    run "$SKILL_MANAGER" validate
    # exit 0 = pass, exit 1 = errors, exit 2 = warnings; all are valid validate outcomes
    if [[ "$status" -ne 0 && "$status" -ne 1 && "$status" -ne 2 ]]; then
        fail "unexpected exit status $status"
    fi
}

@test "skill-manager with unknown command fails" {
    run "$SKILL_MANAGER" nonexistent-command
    assert_failure
}
