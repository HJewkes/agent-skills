#!/usr/bin/env bats

setup() {
    load 'test_helper'
    BUILDKITE="$REPO_ROOT/skills/buildkite/scripts/buildkite"

    # Create a fake env file so the script skips interactive setup
    export BUILDKITE_ENV_FILE="${BATS_TEST_TMPDIR}/buildkite-env"
    echo "# test env" > "$BUILDKITE_ENV_FILE"
}

@test "buildkite triage with no pipeline fails" {
    run "$BUILDKITE" triage
    assert_failure
    assert_output --partial "pipeline"
}

@test "buildkite triage --help prints triage usage" {
    run "$BUILDKITE" triage --help
    assert_success
    assert_output --partial "Usage:"
    assert_output --partial "pipeline-slug"
}

@test "buildkite triage -h prints triage usage" {
    run "$BUILDKITE" triage -h
    assert_success
    assert_output --partial "Usage:"
}

@test "buildkite triage unknown option fails" {
    run "$BUILDKITE" triage my-pipeline --bogus
    assert_failure
    assert_output --partial "unknown option"
}

@test "buildkite triage --build without value fails" {
    run "$BUILDKITE" triage my-pipeline --build
    assert_failure
    assert_output --partial "--build requires a value"
}

@test "buildkite triage --last without value fails" {
    run "$BUILDKITE" triage my-pipeline --last
    assert_failure
    assert_output --partial "--last requires a value"
}

@test "buildkite triage errors when bk not installed" {
    # Hide bk from PATH so the script cannot find it
    PATH="/usr/bin:/bin" run "$BUILDKITE" triage my-pipeline
    assert_failure
    assert_output --partial "bk"
    assert_output --partial "not installed"
}

@test "buildkite --help shows triage subcommand" {
    run "$BUILDKITE" --help
    assert_success
    assert_output --partial "triage"
}
