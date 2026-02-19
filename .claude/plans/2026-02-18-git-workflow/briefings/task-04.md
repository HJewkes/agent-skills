# Task 04: Write splitting-changes.md

## Architectural Context

This reference doc teaches the agent how to decompose large diffs into smaller, reviewable units. Read before using `git-workflow split`. Covers strategies for both Graphite and plain Git. Target ~120 lines.

## File Ownership

**May modify:**
- `skills/git-workflow/references/splitting-changes.md`

**Must not touch:**
- `skills/git-workflow/SKILL.md`
- Any script files

## Steps

### Step 1: Create references directory (if not exists)

```bash
mkdir -p /Users/hjewkes/Documents/projects/agents-skills/skills/git-workflow/references
```

### Step 2: Write splitting-changes.md

Write the file at `skills/git-workflow/references/splitting-changes.md`:

```markdown
# Splitting Large Changes

When to split and how to decompose large diffs into reviewable stacked branches.

## When to Split

Split when any of these apply:
- Diff exceeds 400 lines changed
- Changes touch more than 25 files
- Multiple unrelated concerns in one branch
- Reviewer would need heavy context to understand the PR
- Mix of refactoring and new behavior

## Splitting Strategies

### Layered Architecture

Build bottom-up: schema → models → services → API endpoints → UI. Each layer is one branch. Reviewers approve foundations before upper layers.

**Best for:** Full-stack features, database migrations, API additions.

### Refactor-Then-Feature

Branch 1: pure refactor (no behavior change, easy to review). Branch 2: build feature on clean code.

**Best for:** Adding features to messy code, any change that needs cleanup first.

### Feature-Flag Split

Branch 1: implement new behavior behind a flag. Branch 2: enable the flag.

**Best for:** Risky changes, gradual rollouts, changes that need testing in production.

### File/Subsystem Split

Group changes by file or module boundary. Each branch touches a distinct set of files.

**Best for:** Cross-cutting changes, dependency updates, multi-module refactors.

### Incremental Migration

Branch 1: compatibility shim. Branches 2-N: migrate call sites. Final branch: delete old implementation.

**Best for:** API migrations, library upgrades, deprecation removals.

## How to Split with Graphite

### From a single branch with clean commits

```bash
gt split --by-commit    # Each commit becomes its own branch
```

### From a messy branch

```bash
gt split --by-hunk      # Interactive: pick hunks per branch
```

### Extract files into a parent branch

```bash
gt split --by-file "src/models/**"   # Matching files become parent branch
```

### Build a stack from scratch

```bash
# Start on trunk
gt create -m "refactor: extract auth module"
# ... make changes, commit ...

gt create -m "feat: add OAuth provider"
# ... builds on top of previous branch ...

gt submit --stack       # Push entire stack
```

## How to Split with Plain Git

### Using interactive staging

```bash
# Stage only related hunks
git add --patch

# Commit the first logical unit
git commit -m "refactor: extract auth module"

# Stash remaining changes
git stash

# Create next branch from current
git checkout -b feat/oauth-provider

# Pop stash and continue
git stash pop
git add --patch
git commit -m "feat: add OAuth provider"
```

### From existing commits (interactive rebase)

```bash
# Rebase interactively to reorder/split commits
git rebase -i main

# Use 'edit' to pause at a commit and split it
# Use 'squash'/'fixup' to combine over-granular commits
```

## Stack Depth Guidance

- 2-3 branches: manageable, review in any order
- 4-5 branches: manageable with discipline, review bottom-up
- 6-7 branches: maximum practical depth, rebase conflicts become frequent
- 8+ branches: split into independent stacks or reconsider approach

## Review Order

Always review stacked PRs from bottom up (closest to trunk first). Each PR should be independently understandable.
```

### Step 3: Commit

```bash
git add skills/git-workflow/references/splitting-changes.md
git commit -m "Add splitting changes reference guide"
```

## Success Criteria

- [ ] `skills/git-workflow/references/splitting-changes.md` exists
- [ ] Covers: when to split, 5 strategies, Graphite workflow, Git workflow, stack depth
- [ ] ~120 lines

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
