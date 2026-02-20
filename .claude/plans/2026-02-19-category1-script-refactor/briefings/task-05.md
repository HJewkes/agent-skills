# Task 05: skill-manager validate completeness

## Architectural Context

The `skill-manager` script at `skills/skills-management/scripts/skill-manager` has a `validate` subcommand that checks skill conventions. However, some rules from the agent-skills-spec (`agent-skills-spec.md`) are not yet enforced by the validator. The spec defines constraints like body under 500 lines, frontmatter field limits, naming rules (no leading/trailing/consecutive hyphens), and script conventions (`--help` support, shebang). Currently the validator checks some of these but not all. This task closes the gap.

## File Ownership

**May modify:**
- `skills/skills-management/scripts/skill-manager`
- `tests/skill-manager.bats`

**Must not touch:**
- `skills/skills-management/SKILL.md`
- `skills/skills-management/references/agent-skills-spec.md`
- Any other skill's files

**Read for context (do not modify):**
- `skills/skills-management/references/agent-skills-spec.md` — the authoritative spec to validate against
- `skills/skills-management/scripts/skill-manager` — current validate implementation

## Steps

### Step 1: Read the spec and current validator

Read `skills/skills-management/references/agent-skills-spec.md` to get the full list of rules. Read the `cmd_validate` function in `skill-manager` to see which rules are already implemented. Build a gap list.

### Step 2: Identify missing validation rules

Expected gaps based on the spec (verify by reading the code):

- **Name field**: No leading/trailing/consecutive hyphens (spec says this, validator may only check kebab-case regex)
- **Name length**: Max 64 characters
- **Description length**: Max 1024 characters
- **Body length**: SKILL.md body (below frontmatter) should be under 500 lines — warn if exceeded
- **Frontmatter size**: Under 1024 characters total
- **Script conventions**: If `scripts/` directory exists, check that each script has `#!/usr/bin/env bash` shebang and supports `--help` (exits 0)
- **No consecutive hyphens** in name: `--` should be rejected

### Step 3: Implement missing checks

Add each missing check to the `cmd_validate` function. Follow the existing pattern:
- `ERROR` prefix for hard failures (name violations, missing required fields)
- `WARN` prefix for soft issues (body too long, missing --help)
- Increment error/warning counters
- Exit 1 if errors, exit 2 if warnings only, exit 0 if clean

For each new check, add it in logical order within the function (name checks together, content checks together, script checks together).

### Step 4: Extend bats tests

Add to `tests/skill-manager.bats`. The existing tests cover basic validate behavior. Add tests for the new checks:

```bash
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
    rm -rf "$tmp_dir"
}

@test "skill-manager validate warns on long body" {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    mkdir -p "$tmp_dir/long-body"
    {
        printf -- '---\nname: long-body\ndescription: Use when testing\n---\n# Test\n'
        for i in $(seq 1 501); do printf 'Line %d\n' "$i"; done
    } > "$tmp_dir/long-body/SKILL.md"
    run "$SKILL_MANAGER" validate "$tmp_dir/long-body"
    # Should warn (exit 2) but not error
    [[ "$status" -eq 0 || "$status" -eq 2 ]]
    assert_output --partial "WARN"
    rm -rf "$tmp_dir"
}
```

### Step 5: Verify

Run: `shellcheck skills/skills-management/scripts/skill-manager`
Expected: No errors

Run: `npx bats tests/skill-manager.bats`
Expected: All tests pass

Also validate a known-good skill to confirm no false positives:
Run: `skills/skills-management/scripts/skill-manager validate skills/brainstorming`
Expected: Exit 0, no errors

### Step 6: Commit

```bash
git add skills/skills-management/scripts/skill-manager tests/skill-manager.bats
git commit -m "Complete skill-manager validate against full spec

Add missing validation rules: name length, consecutive hyphens,
description length, frontmatter size, body line count, and script
convention checks (shebang, --help support)."
```

## Success Criteria

- [ ] `shellcheck skills/skills-management/scripts/skill-manager` passes
- [ ] `npx bats tests/skill-manager.bats` all pass
- [ ] `skill-manager validate` on all existing skills produces no unexpected errors
- [ ] Consecutive hyphens in name correctly rejected
- [ ] Body over 500 lines produces a warning

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
- Do NOT change existing validation behavior — only add new checks
- Do NOT make existing valid skills fail validation — if current skills have long bodies, use WARN not ERROR for body length
