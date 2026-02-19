# Task 01: Scaffold Skill + Write SKILL.md

## Architectural Context

The `git-workflow` skill is the unified entry point for all git operations an agent performs. SKILL.md acts as a router — it tells the agent to run `git-workflow status` first, then routes to the appropriate subcommand or reference based on what the agent needs. The skill follows the repo's standard pattern: YAML frontmatter with `name` and `description`, then markdown body.

## File Ownership

**May modify:**
- `skills/git-workflow/SKILL.md`

**Must not touch:**
- Any other skill directory
- `skill-manifest.json` (handled in task-10)

**Read for context (do not modify):**
- `skills/repo-ci/SKILL.md` — example of well-structured skill with CLI + references
- `skills/code-review/SKILL.md` — example of routing/dispatch pattern

## Steps

### Step 1: Create skill directory

```bash
cd /Users/hjewkes/Documents/projects/agents-skills
skills/skills-management/scripts/skill-manager create git-workflow --script git-workflow
```

This creates the directory structure with SKILL.md stub and scripts/git-workflow stub.

### Step 2: Write SKILL.md

Replace the stub SKILL.md with:

```markdown
---
name: git-workflow
description: Use when committing, branching, splitting changes, managing stacks, creating worktrees, or cleaning up branches — detects Graphite or Git and guides the agent through best-practice workflows via CLI.
---

# Git Workflow

Unified git workflow skill. Detects Graphite (`gt`) or plain Git, prefers Graphite when available.

**First step in any git operation:** Run `scripts/git-workflow status` to detect the environment.

## Quick Reference

| Situation | Action |
|-----------|--------|
| Need repo state / tool detection | `git-workflow status` |
| Ready to commit staged changes | `git-workflow commit --message "feat: ..."` |
| Large diff needs decomposition | Read [references/splitting-changes.md](references/splitting-changes.md), then `git-workflow split` |
| View or manage branch stack | `git-workflow stack` |
| Need isolated workspace | `git-workflow worktree --branch feat/name` |
| Stale local branches | `git-workflow clean` |
| Graphite command reference | [references/graphite-guide.md](references/graphite-guide.md) |
| Commit/branch conventions | [references/git-best-practices.md](references/git-best-practices.md) |

## CLI Reference

| Command | Description |
|---------|-------------|
| `git-workflow status` | Detect gt/git, report branch, dirty files, stack state |
| `git-workflow commit` | Guided commit (conventional format, gt create or git commit) |
| `git-workflow split` | Analyze diff, suggest split points, guide decomposition |
| `git-workflow stack` | Show stack state, create/restack/sync branches |
| `git-workflow worktree` | Create isolated worktree with dep install + test baseline |
| `git-workflow clean` | Remove merged/gone branches and associated worktrees |

## Workflow Integration

| Workflow | Usage |
|----------|-------|
| Feature development | `status` → work → `commit` → `stack` (if stacking) |
| Large change decomposition | `status` → read splitting-changes.md → `split` |
| Parallel agent work | `worktree` → work in isolation → finish |
| Post-merge cleanup | `clean` to remove stale branches |
| PR creation | Use `github-pr` skill after committing/pushing |

## Safety Guardrails

- Never `git push --force` to main/master
- Never `git add .` or `git add -A` (stage specific files)
- Never skip hooks with `--no-verify`
- Never `git reset --hard` without explicit user instruction
- Always verify staged files before committing

## Reference Files

| Reference | Purpose |
|-----------|---------|
| [references/graphite-guide.md](references/graphite-guide.md) | Graphite commands, stacking patterns, pitfalls |
| [references/git-best-practices.md](references/git-best-practices.md) | Commit format, branch naming, safety rules |
| [references/splitting-changes.md](references/splitting-changes.md) | Strategies for decomposing large diffs |
```

### Step 3: Verify

```bash
cd /Users/hjewkes/Documents/projects/agents-skills
skills/skills-management/scripts/skill-manager validate git-workflow
```

Expected: exit 0 or exit 2 (warnings OK, errors not OK).

### Step 4: Commit

```bash
git add skills/git-workflow/SKILL.md
git commit -m "Add git-workflow skill scaffolding and SKILL.md"
```

## Success Criteria

- [ ] `skills/git-workflow/SKILL.md` exists with valid frontmatter
- [ ] `skill-manager validate git-workflow` exits 0 or 2
- [ ] SKILL.md has routing table, CLI reference, workflow integration, safety guardrails

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
- Do NOT write the CLI script content (that's task-05)
