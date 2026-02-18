#!/usr/bin/env bats

setup() {
    load 'test_helper'
    HUMANIZE="$REPO_ROOT/skills/humanizer/scripts/humanize"
    SKILL_DIR="$REPO_ROOT/skills/humanizer"
    if [ ! -x "$HUMANIZE" ]; then
        skip "humanize script not executable or not present"
    fi
}

# ============================================================
# CLI interface
# ============================================================

@test "humanize --help prints usage" {
    run "$HUMANIZE" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "humanize --help documents exit codes" {
    run "$HUMANIZE" --help
    assert_success
    assert_output --partial "Exit codes:"
    assert_output --partial "0"
    assert_output --partial "1"
    assert_output --partial "2"
}

@test "humanize rejects unknown options" {
    run "$HUMANIZE" --foobar
    assert_failure
    assert_output --partial "Unknown option"
}

@test "humanize fails on nonexistent file" {
    run "$HUMANIZE" /tmp/nonexistent-humanize-test-file
    assert_failure
    assert_output --partial "file not found"
}

# ============================================================
# Input modes
# ============================================================

@test "humanize reads from stdin pipe" {
    run bash -c "echo 'hello world' | '$HUMANIZE'"
    assert_success
    assert_output --partial "hello world"
}

@test "humanize reads from file argument" {
    local tmpfile
    tmpfile=$(mktemp)
    printf 'hello\xe2\x80\x94world' > "$tmpfile"
    run "$HUMANIZE" "$tmpfile"
    assert_output --partial "hello - world"
    rm -f "$tmpfile"
}

@test "humanize --report works with file argument" {
    local tmpfile
    tmpfile=$(mktemp)
    printf 'word\xe2\x80\x94word' > "$tmpfile"
    run bash -c "'$HUMANIZE' --report '$tmpfile' 2>&1"
    assert_output --partial "word - word"
    assert_output --partial "Character Replacements"
    rm -f "$tmpfile"
}

# ============================================================
# Character replacements — typography
# ============================================================

@test "replaces em dashes with space-hyphen-space" {
    run bash -c "printf 'word\xe2\x80\x94word' | '$HUMANIZE'"
    assert_output --partial "word - word"
}

@test "replaces en dashes with hyphen" {
    run bash -c "printf 'pages 1\xe2\x80\x932' | '$HUMANIZE'"
    assert_output --partial "pages 1-2"
}

@test "replaces smart double quotes with straight" {
    run bash -c "printf '\xe2\x80\x9chello\xe2\x80\x9d' | '$HUMANIZE'"
    assert_output --partial '"hello"'
}

@test "replaces smart single quotes with straight" {
    run bash -c "printf 'it\xe2\x80\x99s' | '$HUMANIZE'"
    assert_output --partial "it's"
}

@test "replaces left smart single quote" {
    run bash -c "printf '\xe2\x80\x98quoted\xe2\x80\x99' | '$HUMANIZE'"
    assert_output --partial "'quoted'"
}

@test "replaces ellipsis character with three periods" {
    run bash -c "printf 'wait\xe2\x80\xa6' | '$HUMANIZE'"
    assert_output --partial "wait..."
}

@test "replaces bullet character with hyphen" {
    run bash -c "printf '\xe2\x80\xa2 item one' | '$HUMANIZE'"
    assert_output --partial "- item one"
}

# ============================================================
# Character replacements — invisible/whitespace
# ============================================================

@test "replaces non-breaking space with regular space" {
    run bash -c "printf 'hello\xc2\xa0world' | '$HUMANIZE'"
    assert_output --partial "hello world"
}

@test "replaces narrow no-break space with regular space" {
    run bash -c "printf 'hello\xe2\x80\xafworld' | '$HUMANIZE'"
    assert_output --partial "hello world"
}

@test "removes zero-width spaces" {
    run bash -c "printf 'hel\xe2\x80\x8blo' | '$HUMANIZE'"
    assert_output --partial "hello"
}

@test "removes zero-width non-joiners" {
    run bash -c "printf 'hel\xe2\x80\x8clo' | '$HUMANIZE'"
    assert_output --partial "hello"
}

@test "removes word joiners" {
    run bash -c "printf 'hel\xe2\x81\xa0lo' | '$HUMANIZE'"
    assert_output --partial "hello"
}

@test "removes soft hyphens" {
    run bash -c "printf 'hel\xc2\xadlo' | '$HUMANIZE'"
    assert_output --partial "hello"
}

# ============================================================
# Multiple replacements in one input
# ============================================================

@test "handles multiple replacement types in same input" {
    run bash -c "printf '\xe2\x80\x9cword\xe2\x80\x9d \xe2\x80\x94 wait\xe2\x80\xa6' | '$HUMANIZE'"
    assert_output --partial '"word"'
    assert_output --partial " - "
    assert_output --partial "wait..."
}

@test "clean text passes through unchanged" {
    run bash -c "echo 'Plain text with no special chars.' | '$HUMANIZE'"
    assert_output --partial "Plain text with no special chars."
}

@test "handles empty input" {
    run bash -c "echo '' | '$HUMANIZE'"
    assert_success
}

@test "handles multiline input" {
    run bash -c "printf 'line one\xe2\x80\x94here\nline two\xe2\x80\x94there' | '$HUMANIZE'"
    assert_output --partial "line one - here"
    assert_output --partial "line two - there"
}

# ============================================================
# Phrase flagging — by tier
# ============================================================

@test "flags tier 1 red-flag words" {
    run bash -c "echo 'We must delve into this robust framework' | '$HUMANIZE' 2>&1"
    [[ "$status" -eq 2 ]]
    assert_output --partial "delve"
    assert_output --partial "robust"
    assert_output --partial "[red-flag]"
}

@test "flags tier 2 hedging phrases" {
    run bash -c "echo \"It's important to note that this works\" | '$HUMANIZE' 2>&1"
    [[ "$status" -eq 2 ]]
    assert_output --partial "[hedging]"
}

@test "flags tier 3 filler phrases" {
    run bash -c "echo 'Please don'\''t hesitate to reach out' | '$HUMANIZE' 2>&1"
    [[ "$status" -eq 2 ]]
    assert_output --partial "[filler]"
}

@test "flags tier 4 formal transitions" {
    run bash -c "echo 'Furthermore, this is important' | '$HUMANIZE' 2>&1"
    [[ "$status" -eq 2 ]]
    assert_output --partial "[formality]"
}

@test "phrase flagging is case-insensitive" {
    run bash -c "echo 'DELVE into the ROBUST system' | '$HUMANIZE' 2>&1"
    [[ "$status" -eq 2 ]]
    assert_output --partial "DELVE"
    assert_output --partial "[red-flag]"
}

@test "flags regex patterns like seamlessly" {
    run bash -c "echo 'It seamlessly integrates' | '$HUMANIZE' 2>&1"
    [[ "$status" -eq 2 ]]
    assert_output --partial "[red-flag]"
}

@test "flags multi-word hedging phrases" {
    run bash -c "echo 'When it comes to testing, we need more' | '$HUMANIZE' 2>&1"
    [[ "$status" -eq 2 ]]
    assert_output --partial "[hedging]"
}

# ============================================================
# Exit codes
# ============================================================

@test "exits 0 when no phrases flagged" {
    run bash -c "echo 'A simple clear sentence.' | '$HUMANIZE'"
    assert_success
}

@test "exits 2 when phrases flagged" {
    run bash -c "echo 'This is a comprehensive tapestry' | '$HUMANIZE' 2>/dev/null"
    [[ "$status" -eq 2 ]]
}

@test "exits 1 on error (bad file)" {
    run "$HUMANIZE" /tmp/nonexistent-humanize-test-file
    [[ "$status" -eq 1 ]]
}

# ============================================================
# Output modes
# ============================================================

@test "default mode: cleaned text on stdout only" {
    run bash -c "printf 'word\xe2\x80\x94word' | '$HUMANIZE'"
    assert_success
    assert_output --partial "word - word"
    # no report sections in stdout
    refute_output --partial "Character Replacements"
}

@test "default mode: phrase flags go to stderr not stdout" {
    local stdout stderr
    tmpout=$(mktemp)
    tmperr=$(mktemp)
    bash -c "echo 'We must delve deeper' | '$HUMANIZE' > '$tmpout' 2> '$tmperr'" || true
    stdout=$(cat "$tmpout")
    stderr=$(cat "$tmperr")
    [[ "$stderr" == *"delve"* ]]
    [[ "$stdout" != *"[red-flag]"* ]]
    rm -f "$tmpout" "$tmperr"
}

@test "--report shows character replacement counts" {
    run bash -c "printf 'word\xe2\x80\x94word' | '$HUMANIZE' --report 2>&1"
    assert_output --partial "Character Replacements"
    assert_output --partial "em dashes"
    assert_output --partial "replaced"
}

@test "--report shows (none) when no replacements needed" {
    run bash -c "echo 'clean text here' | '$HUMANIZE' --report 2>&1"
    assert_output --partial "(none)"
}

@test "--report shows phrase flags section" {
    run bash -c "echo 'A comprehensive delve' | '$HUMANIZE' --report 2>&1"
    assert_output --partial "Phrase Flags"
    assert_output --partial "delve"
}

# ============================================================
# Skill structure validation
# ============================================================

@test "SKILL.md exists with valid frontmatter" {
    [ -f "$SKILL_DIR/SKILL.md" ]
    # Check frontmatter has name field
    run head -5 "$SKILL_DIR/SKILL.md"
    assert_output --partial "name: humanizer"
}

@test "SKILL.md description starts with 'Use when'" {
    run grep 'description:' "$SKILL_DIR/SKILL.md"
    assert_output --partial "Use when"
}

@test "all reference files exist" {
    [ -f "$SKILL_DIR/references/phrases.txt" ]
    [ -f "$SKILL_DIR/references/readme-guide.md" ]
    [ -f "$SKILL_DIR/references/email-guide.md" ]
    [ -f "$SKILL_DIR/references/slack-guide.md" ]
    [ -f "$SKILL_DIR/references/commit-guide.md" ]
}

@test "humanize script is executable" {
    [ -x "$SKILL_DIR/scripts/humanize" ]
}

# ============================================================
# phrases.txt validation
# ============================================================

@test "phrases.txt has no malformed lines" {
    # Every non-comment, non-empty line must have exactly 3 tab-separated fields
    run bash -c "grep -v '^#' '$SKILL_DIR/references/phrases.txt' | grep -v '^\$' | awk -F'\t' 'NF != 3 { found=1; print \"BAD: \" \$0 } END { exit (found ? 1 : 0) }'"
    assert_success
}

@test "all phrase patterns are valid grep regex" {
    local failed=0
    while IFS=$'\t' read -r pattern category note; do
        [[ -z "$pattern" || "$pattern" == \#* ]] && continue
        if ! echo "" | grep -iE "$pattern" >/dev/null 2>&1; then
            # grep returns 1 for no match (ok) but 2 for bad regex
            if [[ $? -eq 2 ]]; then
                echo "Invalid regex: $pattern"
                failed=1
            fi
        fi
    done < "$SKILL_DIR/references/phrases.txt"
    [[ $failed -eq 0 ]]
}
