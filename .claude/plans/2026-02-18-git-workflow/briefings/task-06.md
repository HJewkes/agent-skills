# Task 06: CLI Commit + Clean Subcommands

## Architectural Context

Adding `commit` and `clean` subcommands to the existing `git-workflow` CLI. The `commit` subcommand guides an agent through a proper commit using conventional format, preferring Graphite when available. The `clean` subcommand removes stale branches (merged/gone) and their worktrees. Both replace functionality from the `commit-commands` plugin.

## File Ownership

**May modify:**
- `skills/git-workflow/scripts/git-workflow`

**Must not touch:**
- `skills/git-workflow/SKILL.md`
- Any reference files

**Read for context (do not modify):**
- Existing `git-workflow` script from task-05 (it has `detect_tool`, `detect_trunk`, color helpers, and stub cases for commit/clean)

## Steps

### Step 1: Add commit subcommand

In `skills/git-workflow/scripts/git-workflow`, replace the `commit` stub in the case statement and add the `cmd_commit` function. Insert the function before the subcommand routing section:

```bash
usage_commit() {
  cat <<'EOF'
Usage: git-workflow commit [options]

Guided commit with conventional format.

Options:
  -m, --message <msg>  Commit message (conventional format: "type: description")
  -a, --all            Stage all modified files before committing
  --amend              Amend the current branch commit (gt modify or git commit --amend)
  --help               Show this help message

Behavior:
  - Graphite: uses 'gt create' for new branch+commit, 'gt modify' for amend
  - Git: uses 'git commit', 'git commit --amend' for amend
  - Validates message matches conventional format before committing
  - Shows staged files summary before executing
EOF
}

cmd_commit() {
  local message="" stage_all=false amend=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -m|--message) message="$2"; shift 2 ;;
      -a|--all) stage_all=true; shift ;;
      --amend) amend=true; shift ;;
      --help) usage_commit; exit 0 ;;
      *) die "Unknown option for commit: $1" ;;
    esac
  done

  git rev-parse --git-dir &>/dev/null || die "not a git repository"

  local tool
  tool=$(detect_tool)

  # Stage all if requested
  if [[ "$stage_all" == true ]]; then
    git add -u
    info "Staged all modified tracked files"
  fi

  # Check for staged changes
  local staged_count
  staged_count=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$staged_count" -eq 0 && "$amend" == false ]]; then
    die "no staged changes. Stage files first with 'git add <file>'"
  fi

  # Require message
  [[ -z "$message" ]] && die "commit message required. Use -m 'type: description'"

  # Validate conventional commit format
  if ! echo "$message" | grep -qE '^(feat|fix|docs|refactor|perf|test|chore|ci|style)(\(.+\))?!?: .+'; then
    warn "message does not match conventional format: type[(scope)][!]: description"
    warn "valid types: feat, fix, docs, refactor, perf, test, chore, ci, style"
  fi

  # Show what will be committed
  echo "${BOLD}Staged changes:${RESET}"
  git diff --cached --stat
  echo ""

  local tool
  tool=$(detect_tool)

  if [[ "$amend" == true ]]; then
    if [[ "$tool" == "graphite" ]]; then
      info "Amending with: gt modify"
      gt modify -m "$message"
    else
      info "Amending with: git commit --amend"
      git commit --amend -m "$message"
    fi
  else
    if [[ "$tool" == "graphite" ]]; then
      # gt create makes a new branch + commit
      # Extract branch name from message
      local branch_name
      branch_name=$(echo "$message" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]' | cut -c1-50)
      info "Creating with: gt create -m '$message'"
      gt create -m "$message"
    else
      info "Committing with: git commit"
      git commit -m "$message"
    fi
  fi

  echo ""
  echo "${GREEN}Done.${RESET}"
}
```

Then update the routing case:

```bash
  commit)   cmd_commit "$@" ;;
```

### Step 2: Add clean subcommand

Add the `cmd_clean` function before the subcommand routing:

```bash
usage_clean() {
  cat <<'EOF'
Usage: git-workflow clean [options]

Remove branches that have been merged or deleted on the remote.

Options:
  --dry-run    Show what would be removed without doing it
  --help       Show this help message

Behavior:
  - Graphite: runs 'gt sync' which handles cleanup
  - Git: finds [gone] branches, removes associated worktrees, deletes branches
EOF
}

cmd_clean() {
  local dry_run=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) dry_run=true; shift ;;
      --help) usage_clean; exit 0 ;;
      *) die "Unknown option for clean: $1" ;;
    esac
  done

  git rev-parse --git-dir &>/dev/null || die "not a git repository"

  local tool
  tool=$(detect_tool)

  # Fetch latest remote state
  info "Fetching remote..."
  git fetch --prune 2>/dev/null

  if [[ "$tool" == "graphite" ]]; then
    if [[ "$dry_run" == true ]]; then
      info "Dry run: would run 'gt sync' to clean up merged branches"
      gt log short 2>/dev/null || true
    else
      info "Running: gt sync"
      gt sync
    fi
    return
  fi

  # Git: find gone branches
  local gone_branches
  gone_branches=$(git branch -v 2>/dev/null | grep '\[gone\]' | sed 's/^[+* ]*//' | awk '{print $1}')

  if [[ -z "$gone_branches" ]]; then
    echo "No stale branches found."
    return
  fi

  echo "${BOLD}Stale branches:${RESET}"
  echo "$gone_branches" | while read -r branch; do
    echo "  - $branch"
  done

  if [[ "$dry_run" == true ]]; then
    echo ""
    echo "(dry run — no changes made)"
    return
  fi

  echo ""
  echo "$gone_branches" | while read -r branch; do
    # Remove associated worktree if exists
    local worktree_path
    worktree_path=$(git worktree list 2>/dev/null | grep "\\[$branch\\]" | awk '{print $1}')
    if [[ -n "$worktree_path" && "$worktree_path" != "$(git rev-parse --show-toplevel)" ]]; then
      info "Removing worktree: $worktree_path"
      git worktree remove --force "$worktree_path" 2>/dev/null || warn "failed to remove worktree $worktree_path"
    fi

    info "Deleting branch: $branch"
    git branch -D "$branch" 2>/dev/null || warn "failed to delete branch $branch"
  done

  echo ""
  echo "${GREEN}Cleanup complete.${RESET}"
}
```

Then update the routing case:

```bash
  clean)    cmd_clean "$@" ;;
```

### Step 3: Verify

```bash
cd /Users/hjewkes/Documents/projects/agents-skills

# Help works for both subcommands
skills/git-workflow/scripts/git-workflow commit --help
skills/git-workflow/scripts/git-workflow clean --help

# Clean dry run
skills/git-workflow/scripts/git-workflow clean --dry-run

# Shellcheck
shellcheck skills/git-workflow/scripts/git-workflow
```

### Step 4: Commit

```bash
git add skills/git-workflow/scripts/git-workflow
git commit -m "Add commit and clean subcommands to git-workflow CLI"
```

## Success Criteria

- [ ] `git-workflow commit --help` prints usage
- [ ] `git-workflow clean --help` prints usage
- [ ] `git-workflow clean --dry-run` runs without error
- [ ] `shellcheck` passes clean

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
- Do NOT implement split/stack/worktree yet
