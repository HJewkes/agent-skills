#!/usr/bin/env bats

setup() {
    load 'test_helper'
    AUDIT_CONTEXT="$REPO_ROOT/skills/context-audit/scripts/audit-context"
    FIXTURE_JSONL="$REPO_ROOT/tests/fixtures/sample-session.jsonl"
}

@test "audit-context --help prints usage" {
    run "$AUDIT_CONTEXT" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "audit-context runs without error" {
    run "$AUDIT_CONTEXT"
    assert_success
}

@test "audit-context --json produces valid JSON" {
    run "$AUDIT_CONTEXT" --json
    assert_success
    echo "$output" | python3 -m json.tool > /dev/null
}

@test "audit-context --session with nonexistent file fails" {
    run "$AUDIT_CONTEXT" --session /nonexistent/path.jsonl
    assert_failure
}

@test "audit-context --session auto-detect fails when no JSONL exists" {
    local fake_home
    fake_home="$(mktemp -d)"
    mkdir -p "$fake_home/.claude/skills/placeholder"
    echo "# Placeholder" > "$fake_home/.claude/skills/placeholder/SKILL.md"
    HOME="$fake_home" run "$AUDIT_CONTEXT" --session
    assert_failure
    assert_output --partial "no session JSONL found"
}

@test "audit-context with unknown option fails" {
    run "$AUDIT_CONTEXT" --nonexistent
    assert_failure
}

@test "audit-context --session parses fixture JSONL" {
    run "$AUDIT_CONTEXT" --session "$FIXTURE_JSONL"
    assert_success
    assert_output --partial "Session Analysis:"
    assert_output --partial "Turns: 4"
    assert_output --partial "Growth rate:"
    assert_output --partial "Cache hit rate:"
}

@test "audit-context --session --json includes session object" {
    run "$AUDIT_CONTEXT" --session "$FIXTURE_JSONL" --json
    assert_success
    echo "$output" | python3 -m json.tool > /dev/null
    turns=$(echo "$output" | jq '.session.turns')
    [ "$turns" -eq 4 ]
}

@test "audit-context --session --json spikes contain preceding_tool" {
    run "$AUDIT_CONTEXT" --session "$FIXTURE_JSONL" --json
    assert_success
    tool=$(echo "$output" | jq -r '.session.spikes[0].preceding_tool')
    [ "$tool" != "null" ]
    [ -n "$tool" ]
}

@test "audit-context --session --top 2 limits spike count" {
    run "$AUDIT_CONTEXT" --session "$FIXTURE_JSONL" --top 2 --json
    assert_success
    spike_count=$(echo "$output" | jq '.session.spikes | length')
    [ "$spike_count" -le 2 ]
}

@test "audit-context --session handles top-level usage layout" {
    # Legacy JSONL has .usage at top level instead of .message.usage
    local legacy="$REPO_ROOT/tests/fixtures/sample-session-legacy.jsonl"
    run "$AUDIT_CONTEXT" --session "$legacy" --json
    assert_success
    turns=$(echo "$output" | jq '.session.turns')
    [ "$turns" -eq 2 ]
}
