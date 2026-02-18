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
    [[ "$status" -eq 0 || "$status" -eq 1 || "$status" -eq 2 ]]
}

@test "skill-manager with unknown command fails" {
    run "$SKILL_MANAGER" nonexistent-command
    assert_failure
}
