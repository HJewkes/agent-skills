# Task 08: CLI Worktree Subcommand

## Architectural Context

Adding the `worktree` subcommand to `git-workflow`. This ports the core logic from the existing `using-git-worktrees` skill's `worktree-setup` script: directory detection, gitignore safety, dependency installation, and baseline test verification. The worktree subcommand replaces the standalone `worktree-setup` script.

## File Ownership

**May modify:**
- `skills/git-workflow/scripts/git-workflow`

**Must not touch:**
- `skills/git-workflow/SKILL.md`
- Any reference files
- `skills/using-git-worktrees/` (cleanup in task-10)

**Read for context (do not modify):**
- `skills/using-git-worktrees/scripts/worktree-setup` — the script being ported
- `skills/finishing-a-development-branch/scripts/run-tests` — test runner detection logic

## Steps

### Step 1: Add worktree subcommand

Add the `cmd_worktree` function before the subcommand routing:

```bash
usage_worktree() {
  cat <<'EOF'
Usage: git-workflow worktree [options]

Create an isolated git worktree with dependency installation and test baseline.

Options:
  --branch <name>    Branch name for the worktree (required)
  --base <branch>    Base branch to create from (default: current branch)
  --dir <path>       Worktree parent directory (overrides auto-detection)
  --no-install       Skip dependency installation
  --no-test          Skip baseline test verification
  --help             Show this help message

Directory auto-detection priority:
  1. .worktrees/  (if exists)
  2. worktrees/   (if exists)
  3. CLAUDE.md worktree preference (if specified)
  4. Exit 1 with suggestion

Exit codes:
  0  Worktree ready, tests pass
  1  Fatal error
  2  Worktree created but tests fail or no test runner found
EOF
}

cmd_worktree() {
  local branch="" base="" dir_override="" do_install=true do_test=true

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --branch) branch="$2"; shift 2 ;;
      --base) base="$2"; shift 2 ;;
      --dir) dir_override="$2"; shift 2 ;;
      --no-install) do_install=false; shift ;;
      --no-test) do_test=false; shift ;;
      --help) usage_worktree; exit 0 ;;
      *) die "Unknown option for worktree: $1" ;;
    esac
  done

  [[ -z "$branch" ]] && die "branch name required. Use --branch <name>"
  git rev-parse --git-dir &>/dev/null || die "not a git repository"

  local repo_root
  repo_root=$(git rev-parse --show-toplevel)

  # Determine worktree parent directory
  local wt_parent=""
  if [[ -n "$dir_override" ]]; then
    wt_parent="$dir_override"
  elif [[ -d "$repo_root/.worktrees" ]]; then
    wt_parent="$repo_root/.worktrees"
    info "Detected: .worktrees/"
  elif [[ -d "$repo_root/worktrees" ]]; then
    wt_parent="$repo_root/worktrees"
    info "Detected: worktrees/"
  elif [[ -f "$repo_root/CLAUDE.md" ]]; then
    local wt_dir
    # shellcheck disable=SC2016
    wt_dir=$(grep -i 'worktree.*director' "$repo_root/CLAUDE.md" 2>/dev/null | head -1 | sed 's/.*[`"]\([^`"]*\)[`"].*/\1/' || true)
    if [[ -n "$wt_dir" ]]; then
      wt_parent="$repo_root/$wt_dir"
      info "Detected from CLAUDE.md: $wt_dir"
    fi
  fi

  if [[ -z "$wt_parent" ]]; then
    die "no worktree directory detected. Create .worktrees/ in repo root, or use --dir <path>"
  fi

  mkdir -p "$wt_parent"

  # Safety: verify project-local directories are gitignored
  local wt_relpath="${wt_parent#"$repo_root"/}"
  if [[ "$wt_parent" == "$repo_root"/* ]]; then
    if ! git check-ignore -q "$wt_relpath" 2>/dev/null; then
      warn "$wt_relpath is not in .gitignore — adding it"
      echo "$wt_relpath" >> "$repo_root/.gitignore"
      git -C "$repo_root" add .gitignore
      git -C "$repo_root" commit -m "Add $wt_relpath to .gitignore"
      info "Committed .gitignore update"
    fi
  fi

  local wt_path="$wt_parent/$branch"

  # Create worktree
  info "Creating worktree at $wt_path..."
  if [[ -n "$base" ]]; then
    git worktree add "$wt_path" -b "$branch" "$base" || die "git worktree add failed"
  else
    git worktree add "$wt_path" -b "$branch" || die "git worktree add failed"
  fi

  # Install dependencies
  if [[ "$do_install" == true ]]; then
    info "Installing dependencies..."
    cd "$wt_path"

    if [[ -f package.json ]]; then
      info "Detected: package.json -> npm install"
      npm install 2>&1 >&2
    elif [[ -f Cargo.toml ]]; then
      info "Detected: Cargo.toml -> cargo build"
      cargo build 2>&1 >&2
    elif [[ -f requirements.txt ]]; then
      info "Detected: requirements.txt -> pip install"
      pip install -r requirements.txt 2>&1 >&2
    elif [[ -f pyproject.toml ]]; then
      if [[ -f poetry.lock ]]; then
        info "Detected: pyproject.toml -> poetry install"
        poetry install 2>&1 >&2
      else
        info "Detected: pyproject.toml -> pip install -e ."
        pip install -e . 2>&1 >&2
      fi
    elif [[ -f go.mod ]]; then
      info "Detected: go.mod -> go mod download"
      go mod download 2>&1 >&2
    else
      info "No dependency file detected, skipping install"
    fi
  fi

  # Run baseline tests
  if [[ "$do_test" == true ]]; then
    info "Running baseline tests..."
    cd "$wt_path"

    # Inline test runner detection (from finishing-a-development-branch/scripts/run-tests)
    local test_cmd=""
    if [[ -f package.json ]]; then
      local test_script
      test_script=$(sed -n '/"scripts"/,/}/p' package.json | grep '"test"' | head -1 | sed 's/.*"test"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/')
      if [[ -n "$test_script" && "$test_script" != 'echo "Error: no test specified" && exit 1' ]]; then
        test_cmd="npm test"
      fi
    elif [[ -f Cargo.toml ]]; then
      test_cmd="cargo test"
    elif [[ -f go.mod ]]; then
      test_cmd="go test ./..."
    elif [[ -f Makefile ]] && grep -q '^test[[:space:]]*:' Makefile; then
      test_cmd="make test"
    fi

    if [[ -n "$test_cmd" ]]; then
      info "Running: $test_cmd"
      if $test_cmd; then
        info "Baseline tests pass"
      else
        warn "Baseline tests failed"
        echo "$wt_path"
        exit 2
      fi
    else
      warn "No test runner detected"
      echo "$wt_path"
      exit 2
    fi
  fi

  echo "$wt_path"
}
```

### Step 2: Update routing

Replace the worktree stub:

```bash
  worktree) cmd_worktree "$@" ;;
```

### Step 3: Verify

```bash
cd /Users/hjewkes/Documents/projects/agents-skills

# Help works
skills/git-workflow/scripts/git-workflow worktree --help

# Shellcheck
shellcheck skills/git-workflow/scripts/git-workflow
```

Note: Do not actually create a worktree during verification — just verify --help and shellcheck.

### Step 4: Commit

```bash
git add skills/git-workflow/scripts/git-workflow
git commit -m "Add worktree subcommand to git-workflow CLI"
```

## Success Criteria

- [ ] `git-workflow worktree --help` prints usage
- [ ] All subcommands still work (`--help` for each)
- [ ] `shellcheck` passes clean
- [ ] Worktree logic includes: directory detection, gitignore safety, dep install, test baseline

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
- Do NOT actually create a worktree during verification
