# Task 07: CLI Split + Stack Subcommands

## Architectural Context

Adding `split` and `stack` subcommands to the existing `git-workflow` CLI. The `split` subcommand analyzes a diff and provides actionable guidance for decomposing it. The `stack` subcommand shows stack state and provides operations. Both adapt behavior based on whether Graphite or plain Git is available.

## File Ownership

**May modify:**
- `skills/git-workflow/scripts/git-workflow`

**Must not touch:**
- `skills/git-workflow/SKILL.md`
- Any reference files

**Read for context (do not modify):**
- Existing `git-workflow` script (has detect_tool, detect_trunk, color helpers, and commit/clean/status implementations)

## Steps

### Step 1: Add split subcommand

Add the `cmd_split` function before the subcommand routing section:

```bash
usage_split() {
  cat <<'EOF'
Usage: git-workflow split [options]

Analyze current changes and suggest how to decompose them.

Options:
  --by-file           Group changes by file/directory for splitting
  --by-commit         Show commit boundaries (for splitting existing commits)
  --dry-run           Analyze only, don't execute any split operations
  --help              Show this help message

Behavior:
  - Analyzes staged + unstaged changes (or commit history)
  - Groups files by directory/type and suggests split boundaries
  - Graphite: guides through gt split or gt create per unit
  - Git: guides through git add -p + git stash workflow
EOF
}

cmd_split() {
  local by_file=false by_commit=false dry_run=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --by-file) by_file=true; shift ;;
      --by-commit) by_commit=true; shift ;;
      --dry-run) dry_run=true; shift ;;
      --help) usage_split; exit 0 ;;
      *) die "Unknown option for split: $1" ;;
    esac
  done

  git rev-parse --git-dir &>/dev/null || die "not a git repository"

  local tool
  tool=$(detect_tool)
  local trunk
  trunk=$(detect_trunk)

  if [[ "$by_commit" == true ]]; then
    # Show commits on current branch relative to trunk
    echo "${BOLD}Commits on current branch:${RESET}"
    echo ""
    git log --oneline "$trunk..HEAD" 2>/dev/null
    local commit_count
    commit_count=$(git rev-list --count "$trunk..HEAD" 2>/dev/null || echo 0)
    echo ""
    echo "Found $commit_count commits."

    if [[ "$commit_count" -gt 1 && "$tool" == "graphite" ]]; then
      echo ""
      echo "${CYAN}Suggestion:${RESET} Run 'gt split --by-commit' to promote each commit to its own branch."
    elif [[ "$commit_count" -gt 1 ]]; then
      echo ""
      echo "${CYAN}Suggestion:${RESET} Use 'git rebase -i $trunk' to reorder/split commits into separate branches."
    fi

    if [[ "$dry_run" == true ]]; then
      echo "(dry run — no changes made)"
    fi
    return
  fi

  # Analyze changes (staged + unstaged + untracked)
  local changed_files
  changed_files=$(git diff --name-only HEAD 2>/dev/null; git diff --cached --name-only 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)
  changed_files=$(echo "$changed_files" | sort -u)

  if [[ -z "$changed_files" ]]; then
    echo "No local changes to split."
    return
  fi

  local file_count
  file_count=$(echo "$changed_files" | wc -l | tr -d ' ')

  # Get total lines changed
  local lines_changed
  lines_changed=$(git diff --stat HEAD 2>/dev/null | tail -1 | grep -oE '[0-9]+ insertion|[0-9]+ deletion' | awk '{s+=$1}END{print s+0}')

  echo "${BOLD}Change Analysis:${RESET}"
  echo ""
  echo "  Files changed:  $file_count"
  echo "  Lines changed:  ${lines_changed:-0}"
  echo ""

  if [[ "$by_file" == true ]] || [[ "$file_count" -gt 5 ]]; then
    # Group by top-level directory
    echo "${BOLD}Changes by directory:${RESET}"
    echo ""
    echo "$changed_files" | awk -F/ '{print $1}' | sort | uniq -c | sort -rn | while read -r count dir; do
      echo "  $count files  $dir/"
    done
    echo ""

    echo "${BOLD}File list:${RESET}"
    echo "$changed_files" | sed 's/^/  /'
    echo ""
  fi

  # Suggestions
  if [[ "$lines_changed" -gt 400 ]] || [[ "$file_count" -gt 25 ]]; then
    warn "This change is large (>400 lines or >25 files). Consider splitting."
    echo ""
  fi

  if [[ "$tool" == "graphite" ]]; then
    echo "${CYAN}Split options (Graphite):${RESET}"
    echo "  gt split --by-hunk     Interactive hunk-level split"
    echo "  gt split --by-file     Extract files into parent branch"
    echo "  gt create -m 'msg'     Start building a stack manually"
  else
    echo "${CYAN}Split options (Git):${RESET}"
    echo "  git add --patch        Stage related hunks interactively"
    echo "  git stash              Stash remaining changes after partial commit"
    echo "  git rebase -i $trunk   Reorder/split existing commits"
  fi

  if [[ "$dry_run" == true ]]; then
    echo ""
    echo "(dry run — no changes made)"
  fi
}
```

### Step 2: Add stack subcommand

Add the `cmd_stack` function:

```bash
usage_stack() {
  cat <<'EOF'
Usage: git-workflow stack [options]

View and manage the branch stack.

Options:
  --create <name>    Create a new branch on top of the current stack
  --sync             Sync with trunk and restack (gt sync or git pull --rebase)
  --help             Show this help message

Behavior:
  - Graphite: shows gt log, delegates to gt commands
  - Git: shows branch tree relative to trunk
EOF
}

cmd_stack() {
  local create_name="" do_sync=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --create) create_name="$2"; shift 2 ;;
      --sync) do_sync=true; shift ;;
      --help) usage_stack; exit 0 ;;
      *) die "Unknown option for stack: $1" ;;
    esac
  done

  git rev-parse --git-dir &>/dev/null || die "not a git repository"

  local tool
  tool=$(detect_tool)
  local trunk
  trunk=$(detect_trunk)

  # Sync operation
  if [[ "$do_sync" == true ]]; then
    if [[ "$tool" == "graphite" ]]; then
      info "Running: gt sync"
      gt sync
    else
      local branch
      branch=$(git branch --show-current)
      info "Pulling latest $trunk and rebasing..."
      git checkout "$trunk" && git pull && git checkout "$branch" && git rebase "$trunk"
    fi
    return
  fi

  # Create branch on stack
  if [[ -n "$create_name" ]]; then
    if [[ "$tool" == "graphite" ]]; then
      info "Creating stack branch: gt create '$create_name'"
      gt create "$create_name"
    else
      local current
      current=$(git branch --show-current)
      info "Creating branch: $create_name (based on $current)"
      git checkout -b "$create_name"
    fi
    return
  fi

  # Default: show stack state
  echo "${BOLD}Branch Stack:${RESET}"
  echo ""

  if [[ "$tool" == "graphite" ]]; then
    gt log short 2>/dev/null || echo "  (no Graphite stack)"
  else
    # Show branches with their relationship to trunk
    local current
    current=$(git branch --show-current 2>/dev/null || echo "detached")
    echo "  Trunk: $trunk"
    echo "  Current: $current"
    echo ""

    # Show local branches with commit counts ahead of trunk
    echo "  ${BOLD}Branches:${RESET}"
    git for-each-ref --format='%(refname:short)' refs/heads/ | while read -r branch; do
      [[ "$branch" == "$trunk" ]] && continue
      local ahead_count
      ahead_count=$(git rev-list --count "$trunk..$branch" 2>/dev/null || echo "?")
      local marker=""
      [[ "$branch" == "$current" ]] && marker=" ${GREEN}← current${RESET}"
      echo "    $branch ($ahead_count ahead)$marker"
    done
  fi
}
```

### Step 3: Update routing

Replace the stub cases:

```bash
  split)    cmd_split "$@" ;;
  stack)    cmd_stack "$@" ;;
```

### Step 4: Verify

```bash
cd /Users/hjewkes/Documents/projects/agents-skills

# Help works
skills/git-workflow/scripts/git-workflow split --help
skills/git-workflow/scripts/git-workflow stack --help

# Split analysis (dry run)
skills/git-workflow/scripts/git-workflow split --dry-run

# Stack state
skills/git-workflow/scripts/git-workflow stack

# Shellcheck
shellcheck skills/git-workflow/scripts/git-workflow
```

### Step 5: Commit

```bash
git add skills/git-workflow/scripts/git-workflow
git commit -m "Add split and stack subcommands to git-workflow CLI"
```

## Success Criteria

- [ ] `git-workflow split --help` prints usage
- [ ] `git-workflow stack --help` prints usage
- [ ] `git-workflow split --dry-run` analyzes changes
- [ ] `git-workflow stack` shows branch state
- [ ] `shellcheck` passes clean

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
- Do NOT implement worktree yet
