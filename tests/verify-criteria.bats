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

@test "verify-criteria --json handles multiline output" {
    run "$VERIFY" --json 'printf "line1\nline2"'
    assert_success
    echo "$output" | python3 -m json.tool > /dev/null
}

@test "verify-criteria shows failure details in output" {
    run "$VERIFY" "echo 'expected error' && false"
    assert_failure
    assert_output --partial "expected error"
}

@test "verify-criteria --json reports failure" {
    run "$VERIFY" --json "false"
    assert_failure
    echo "$output" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d['failed']==1"
}
