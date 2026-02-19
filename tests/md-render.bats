#!/usr/bin/env bats

setup() {
    load 'test_helper'
    MD_RENDER="$REPO_ROOT/skills/md-render/scripts/md-render"
    SKILL_DIR="$REPO_ROOT/skills/md-render"
    if [ ! -x "$MD_RENDER" ]; then
        skip "md-render script not executable or not present"
    fi
    TEST_TMPDIR="$(mktemp -d)"
    cat > "$TEST_TMPDIR/test.md" <<'MARKDOWN'
# Hello World

This is a **test**.

## Section Two

Some content here.
MARKDOWN
}

teardown() {
    rm -rf "$TEST_TMPDIR"
}

# ============================================================
# CLI interface
# ============================================================

@test "md-render --help exits 0 and shows usage" {
    run "$MD_RENDER" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "md-render -h exits 0 and shows usage" {
    run "$MD_RENDER" -h
    assert_success
    assert_output --partial "Usage:"
}

@test "md-render rejects unknown options" {
    run "$MD_RENDER" --foobar
    assert_failure
    assert_output --partial "Error:"
}

@test "md-render fails with no arguments" {
    run "$MD_RENDER"
    assert_failure
    assert_output --partial "Error:"
}

@test "md-render fails on missing file" {
    run "$MD_RENDER" "$TEST_TMPDIR/nonexistent.md"
    assert_failure
    assert_output --partial "Error:"
}

# ============================================================
# Rendering
# ============================================================

@test "md-render renders file to HTML output" {
    run "$MD_RENDER" "$TEST_TMPDIR/test.md" --no-open -o "$TEST_TMPDIR/out.html"
    assert_success
    [ -f "$TEST_TMPDIR/out.html" ]
    run grep "<h1 " "$TEST_TMPDIR/out.html"
    assert_success
}

@test "md-render output contains expected content" {
    run "$MD_RENDER" "$TEST_TMPDIR/test.md" --no-open -o "$TEST_TMPDIR/out.html"
    assert_success
    run grep "<strong>test</strong>" "$TEST_TMPDIR/out.html"
    assert_success
}

@test "md-render reads from stdin with -" {
    run bash -c "echo '# Stdin Test' | '$MD_RENDER' - --no-open -o '$TEST_TMPDIR/stdin-out.html'"
    assert_success
    [ -f "$TEST_TMPDIR/stdin-out.html" ]
    run grep "Stdin Test" "$TEST_TMPDIR/stdin-out.html"
    assert_success
}

@test "md-render output contains dark mode CSS" {
    run "$MD_RENDER" "$TEST_TMPDIR/test.md" --no-open -o "$TEST_TMPDIR/styled.html"
    assert_success
    run grep "bg-color" "$TEST_TMPDIR/styled.html"
    assert_success
    run grep "#0d1117" "$TEST_TMPDIR/styled.html"
    assert_success
}

@test "md-render generates TOC" {
    run "$MD_RENDER" "$TEST_TMPDIR/test.md" --no-open -o "$TEST_TMPDIR/toc.html"
    assert_success
    run grep "toc" "$TEST_TMPDIR/toc.html"
    assert_success
}

@test "md-render --no-open does not fail" {
    run "$MD_RENDER" "$TEST_TMPDIR/test.md" --no-open
    assert_success
}

# ============================================================
# Mermaid
# ============================================================

@test "md-render renders mermaid blocks as pre.mermaid" {
    cat > "$TEST_TMPDIR/mermaid.md" <<'MARKDOWN'
# Diagram

```mermaid
graph TD
    A --> B
```
MARKDOWN
    run "$MD_RENDER" "$TEST_TMPDIR/mermaid.md" --no-open -o "$TEST_TMPDIR/mermaid.html"
    assert_success
    run grep 'class="mermaid"' "$TEST_TMPDIR/mermaid.html"
    assert_success
}

@test "md-render includes mermaid CDN script" {
    run "$MD_RENDER" "$TEST_TMPDIR/test.md" --no-open -o "$TEST_TMPDIR/mermaid-cdn.html"
    assert_success
    run grep 'mermaid.min.js' "$TEST_TMPDIR/mermaid-cdn.html"
    assert_success
}

@test "md-render mermaid blocks are not syntax-highlighted" {
    cat > "$TEST_TMPDIR/mermaid2.md" <<'MARKDOWN'
```mermaid
graph TD
    A --> B
```
MARKDOWN
    run "$MD_RENDER" "$TEST_TMPDIR/mermaid2.md" --no-open -o "$TEST_TMPDIR/mermaid2.html"
    assert_success
    run grep 'hljs' "$TEST_TMPDIR/mermaid2.html"
    # hljs classes should only be in the CSS, not wrapping the mermaid content
    refute_output --partial 'language-mermaid'
}

# ============================================================
# Output file
# ============================================================

@test "md-render -o writes to specified file" {
    run "$MD_RENDER" "$TEST_TMPDIR/test.md" --no-open -o "$TEST_TMPDIR/custom.html"
    assert_success
    [ -f "$TEST_TMPDIR/custom.html" ]
}

# ============================================================
# Skill structure validation
# ============================================================

@test "SKILL.md exists with valid frontmatter" {
    [ -f "$SKILL_DIR/SKILL.md" ]
    run head -5 "$SKILL_DIR/SKILL.md"
    assert_output --partial "name: md-render"
}

@test "SKILL.md description starts with 'Use when'" {
    run grep 'description:' "$SKILL_DIR/SKILL.md"
    assert_output --partial "Use when"
}

@test "md-render script is executable" {
    [ -x "$SKILL_DIR/scripts/md-render" ]
}

@test "defaults config exists" {
    [ -f "$SKILL_DIR/defaults/config.json" ]
}

@test "page template exists" {
    [ -f "$SKILL_DIR/templates/page.html" ]
}

@test "render module exists" {
    [ -f "$SKILL_DIR/src/render.mjs" ]
}
