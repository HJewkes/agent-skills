#!/usr/bin/env bats

setup() {
    load 'test_helper'
    REPO_CI="$REPO_ROOT/skills/repo-ci/scripts/repo-ci"
    if [ ! -f "$REPO_CI" ]; then
        skip "repo-ci script not present (feat/repo-ci-skill not merged)"
    fi
}

@test "repo-ci --help prints usage" {
    run "$REPO_CI" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "repo-ci audit --json produces valid JSON" {
    cd "$REPO_ROOT"
    run "$REPO_CI" audit --json
    # exit 0 = pass, exit 2 = warnings; both acceptable smoke outcomes
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
    # Verify output is valid JSON
    echo "$output" | python3 -m json.tool > /dev/null
}

@test "repo-ci audit does not crash" {
    cd "$REPO_ROOT"
    run "$REPO_CI" audit
    # Should never exit 1 (error) on a valid repo
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
}

@test "repo-ci with unknown command fails" {
    run "$REPO_CI" nonexistent-command
    assert_failure
}
