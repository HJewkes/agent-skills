# Task 10: Cleanup Replaced Skills + Manifest Update

## Architectural Context

Now that `git-workflow` is complete and tested, remove the skills it replaces and update `skill-manifest.json`. The replaced skills are: `finishing-a-development-branch` and `using-git-worktrees`. Note: `commit-commands` is a plugin (not in this repo), so we don't remove it here.

Other skills reference the replaced skills (e.g., `subagent-driven-development`, `executing-plans`, `brainstorming` reference `using-git-worktrees` and `finishing-a-development-branch`). Update those references to point to `git-workflow`.

## File Ownership

**May modify:**
- `skill-manifest.json`
- `skills/finishing-a-development-branch/` (remove entire directory)
- `skills/using-git-worktrees/` (remove entire directory)
- Any SKILL.md files that reference the removed skills (update references only)

**Must not touch:**
- `skills/git-workflow/` (already complete)
- Test files

## Steps

### Step 1: Find all references to removed skills

Search for references to `finishing-a-development-branch` and `using-git-worktrees` across all SKILL.md and reference files:

```bash
cd /Users/hjewkes/Documents/projects/agents-skills
grep -r "finishing-a-development-branch\|using-git-worktrees" skills/ --include="*.md" -l
```

### Step 2: Update references in other skills

For each file found in step 1 (excluding files in the skills being removed), update references:
- Replace `finishing-a-development-branch` with `git-workflow` (specifically `git-workflow stack` or the skill name)
- Replace `using-git-worktrees` with `git-workflow` (specifically `git-workflow worktree`)
- Update any "Pairs with:" or "Called by:" sections

### Step 3: Remove replaced skills

```bash
cd /Users/hjewkes/Documents/projects/agents-skills
rm -rf skills/finishing-a-development-branch
rm -rf skills/using-git-worktrees
```

### Step 4: Update skill-manifest.json

Read `skill-manifest.json`, then:
1. Remove the `finishing-a-development-branch` entry
2. Remove the `using-git-worktrees` entry
3. Add a `git-workflow` entry:

```json
"git-workflow": {
  "type": "original",
  "description": "Unified git workflow skill with CLI for commits, splits, stacks, worktrees, and cleanup",
  "consolidatedFrom": ["finishing-a-development-branch", "using-git-worktrees"]
}
```

### Step 5: Validate

```bash
cd /Users/hjewkes/Documents/projects/agents-skills

# Validate all skills
skills/skills-management/scripts/skill-manager validate

# Verify removed skills are gone
ls skills/finishing-a-development-branch 2>&1 || echo "removed ✓"
ls skills/using-git-worktrees 2>&1 || echo "removed ✓"

# Verify manifest is valid JSON
python3 -m json.tool skill-manifest.json > /dev/null

# Run full test suite to check for regressions
npx bats tests/
```

### Step 6: Commit

```bash
git add -A
git commit -m "Remove replaced skills and update manifest for git-workflow"
```

Note: Using `git add -A` here is intentional since we're removing entire directories and updating multiple files.

## Success Criteria

- [ ] `skills/finishing-a-development-branch/` does not exist
- [ ] `skills/using-git-worktrees/` does not exist
- [ ] `skill-manifest.json` has `git-workflow` entry, no entries for removed skills
- [ ] `skill-manifest.json` is valid JSON
- [ ] `skill-manager validate` passes (exit 0 or 2)
- [ ] No broken references to removed skills in remaining SKILL.md files
- [ ] `npx bats tests/` passes (no regressions)

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT remove `github-pr` or `managing-github-issues` — they're not being replaced
- Do NOT remove the `commit-commands` plugin — it's external to this repo
