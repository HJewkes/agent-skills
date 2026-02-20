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
    if [[ "$status" -ne 0 && "$status" -ne 2 ]]; then
        fail "unexpected exit status $status"
    fi
    # Verify output is valid JSON
    echo "$output" | python3 -m json.tool > /dev/null
}

@test "repo-ci audit does not crash" {
    cd "$REPO_ROOT"
    run "$REPO_CI" audit
    # Should never exit 1 (error) on a valid repo
    if [[ "$status" -ne 0 && "$status" -ne 2 ]]; then
        fail "unexpected exit status $status"
    fi
}

@test "repo-ci with unknown command fails" {
    run "$REPO_CI" nonexistent-command
    assert_failure
}

@test "repo-ci audit --scorecard produces table" {
    cd "$REPO_ROOT"
    run "$REPO_CI" audit --scorecard
    if [[ "$status" -ne 0 && "$status" -ne 2 ]]; then
        fail "unexpected exit status $status"
    fi
    assert_output --partial "| Area"
    assert_output --partial "CI Health Scorecard"
    assert_output --partial "**Result:"
}

@test "repo-ci audit rejects --json and --scorecard together" {
    cd "$REPO_ROOT"
    run "$REPO_CI" audit --json --scorecard
    assert_failure
    assert_output --partial "mutually exclusive"
}

@test "repo-ci verify --baseline with missing file fails" {
    run "$REPO_CI" verify --baseline /nonexistent/baseline.json
    assert_failure
    assert_output --partial "not found"
}

@test "repo-ci verify --help prints usage" {
    run "$REPO_CI" verify --help
    assert_success
    assert_output --partial "Usage:"
}

@test "repo-ci verify without --baseline fails" {
    run "$REPO_CI" verify
    assert_failure
    assert_output --partial "Missing required"
}

@test "repo-ci verify --baseline with valid file produces report" {
    cd "$REPO_ROOT"
    # Generate a baseline
    local baseline
    baseline=$(mktemp)
    "$REPO_CI" audit --json > "$baseline" 2>/dev/null || true
    run "$REPO_CI" verify --baseline "$baseline"
    # exit 0 = no regressions, exit 2 = remaining gaps; both acceptable
    if [[ "$status" -ne 0 && "$status" -ne 2 ]]; then
        fail "unexpected exit status $status"
    fi
    assert_output --partial "Verification Report"
    rm -f "$baseline"
}
