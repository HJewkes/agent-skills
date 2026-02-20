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
