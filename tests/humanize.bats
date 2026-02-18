#!/usr/bin/env bats

setup() {
    load 'test_helper'
    HUMANIZE="$REPO_ROOT/skills/humanizer/scripts/humanize"
    if [ ! -x "$HUMANIZE" ]; then
        skip "humanize script not executable or not present"
    fi
}

@test "humanize --help prints usage" {
    run "$HUMANIZE" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "humanize replaces em dashes" {
    input=$'word\xe2\x80\x94word'
    run bash -c "echo '$input' | '$HUMANIZE'"
    assert_output --partial "word - word"
}

@test "humanize replaces smart double quotes" {
    input=$'\xe2\x80\x9chello\xe2\x80\x9d'
    run bash -c "echo '$input' | '$HUMANIZE'"
    assert_output --partial '"hello"'
}

@test "humanize replaces smart single quotes" {
    input=$'it\xe2\x80\x99s'
    run bash -c "echo '$input' | '$HUMANIZE'"
    assert_output --partial "it's"
}

@test "humanize replaces ellipsis character" {
    input=$'wait\xe2\x80\xa6'
    run bash -c "echo '$input' | '$HUMANIZE'"
    assert_output --partial "wait..."
}

@test "humanize removes non-breaking spaces" {
    input=$'hello\xc2\xa0world'
    run bash -c "echo '$input' | '$HUMANIZE'"
    assert_output --partial "hello world"
}

@test "humanize flags AI-overused phrases and exits 2" {
    run bash -c "echo 'We must delve into this robust framework' | '$HUMANIZE' 2>&1"
    [[ "$status" -eq 2 ]]
    assert_output --partial "delve"
    assert_output --partial "robust"
}

@test "humanize exits 0 when no phrases flagged" {
    run bash -c "echo 'A simple clear sentence.' | '$HUMANIZE'"
    assert_success
}

@test "humanize reads from file argument" {
    local tmpfile
    tmpfile=$(mktemp)
    printf 'hello\xe2\x80\x94world' > "$tmpfile"
    run "$HUMANIZE" "$tmpfile"
    assert_output --partial "hello - world"
    rm -f "$tmpfile"
}

@test "humanize --report includes character replacement counts" {
    input=$'word\xe2\x80\x94word'
    run bash -c "echo '$input' | '$HUMANIZE' --report 2>&1"
    assert_output --partial "em dashes"
    assert_output --partial "Character Replacements"
}

@test "humanize fails on nonexistent file" {
    run "$HUMANIZE" /tmp/nonexistent-humanize-test-file
    assert_failure
    assert_output --partial "file not found"
}

@test "humanize rejects unknown options" {
    run "$HUMANIZE" --foobar
    assert_failure
    assert_output --partial "Unknown option"
}
