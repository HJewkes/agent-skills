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
    if [[ "$status" -ne 0 && "$status" -ne 1 && "$status" -ne 2 ]]; then
        fail "unexpected exit status $status"
    fi
}

@test "skill-manager with unknown command fails" {
    run "$SKILL_MANAGER" nonexistent-command
    assert_failure
}

# ── validate: consecutive hyphens ──

@test "skill-manager validate catches consecutive hyphens in name" {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/bad--name"
    cat > "$tmp_dir/bad--name/SKILL.md" <<'EOF'
---
name: bad--name
description: Use when testing
---
# Test
EOF
    run "$SKILL_MANAGER" validate "$tmp_dir/bad--name"
    assert_failure
    assert_output --partial "ERROR"
    assert_output --partial "consecutive hyphens"
    rm -rf "$tmp_dir"
}

# ── validate: name too long ──

@test "skill-manager validate catches name exceeding 64 characters" {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    local long_name
    long_name=$(printf 'a%.0s' {1..65})
    mkdir -p "$tmp_dir/$long_name"
    cat > "$tmp_dir/$long_name/SKILL.md" <<EOF
---
name: $long_name
description: Use when testing
---
# Test
EOF
    run "$SKILL_MANAGER" validate "$tmp_dir/$long_name"
    assert_failure
    assert_output --partial "ERROR"
    assert_output --partial "64 characters"
    rm -rf "$tmp_dir"
}

# ── validate: description too long ──

@test "skill-manager validate warns on description exceeding 1024 characters" {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/long-desc"
    local long_desc
    long_desc="Use when $(printf 'x%.0s' {1..1020})"
    cat > "$tmp_dir/long-desc/SKILL.md" <<EOF
---
name: long-desc
description: $long_desc
---
# Test
EOF
    run "$SKILL_MANAGER" validate "$tmp_dir/long-desc"
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
    assert_output --partial "WARN"
    assert_output --partial "description exceeds 1024"
    rm -rf "$tmp_dir"
}

# ── validate: body too long ──

@test "skill-manager validate warns on long body" {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/long-body"
    {
        printf -- '---\nname: long-body\ndescription: Use when testing\n---\n# Test\n'
        for i in $(seq 1 501); do printf 'Line %d\n' "$i"; done
    } > "$tmp_dir/long-body/SKILL.md"
    run "$SKILL_MANAGER" validate "$tmp_dir/long-body"
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
    assert_output --partial "WARN"
    assert_output --partial "body is"
    rm -rf "$tmp_dir"
}

# ── validate: script shebang ──

@test "skill-manager validate warns on wrong shebang" {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/bad-shebang/scripts"
    cat > "$tmp_dir/bad-shebang/SKILL.md" <<'EOF'
---
name: bad-shebang
description: Use when testing
---
# Test
EOF
    printf '#!/bin/bash\necho hi\n' > "$tmp_dir/bad-shebang/scripts/my-script"
    chmod +x "$tmp_dir/bad-shebang/scripts/my-script"
    run "$SKILL_MANAGER" validate "$tmp_dir/bad-shebang"
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
    assert_output --partial "WARN"
    assert_output --partial "shebang"
    rm -rf "$tmp_dir"
}

# ── validate: valid skill passes clean ──

@test "skill-manager validate passes a valid skill" {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/good-skill/scripts"
    cat > "$tmp_dir/good-skill/SKILL.md" <<'EOF'
---
name: good-skill
description: Use when testing validation
---
# Good Skill
EOF
    cat > "$tmp_dir/good-skill/scripts/helper" <<'SCRIPT'
#!/usr/bin/env bash
case "$1" in --help) echo "Usage: helper"; exit 0 ;; esac
SCRIPT
    chmod +x "$tmp_dir/good-skill/scripts/helper"
    run "$SKILL_MANAGER" validate "$tmp_dir/good-skill"
    assert_success
    rm -rf "$tmp_dir"
}
