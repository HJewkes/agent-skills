# Task 05: CLI Skeleton + Status Subcommand

## Architectural Context

The `git-workflow` CLI is a bash script at `skills/git-workflow/scripts/git-workflow`. It follows the repo's CLI pattern: `#!/usr/bin/env bash`, `set -euo pipefail`, color helpers, `usage()` function, subcommand routing via case statement. The `status` subcommand is the default — it detects the environment (gt vs git) and reports repo state.

## File Ownership

**May modify:**
- `skills/git-workflow/scripts/git-workflow`

**Must not touch:**
- `skills/git-workflow/SKILL.md`
- Any reference files

**Read for context (do not modify):**
- `skills/repo-ci/scripts/repo-ci` — example CLI pattern (color helpers, usage, subcommand routing)

## Steps

### Step 1: Write the CLI skeleton with status subcommand

Write the file at `skills/git-workflow/scripts/git-workflow`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Color helpers
if [[ -t 1 ]] && command -v tput &>/dev/null; then
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  CYAN=$(tput setaf 6)
  BOLD=$(tput bold)
  RESET=$(tput sgr0)
else
  RED="" GREEN="" YELLOW="" CYAN="" BOLD="" RESET=""
fi

die() { echo "${RED}Error: $1${RESET}" >&2; exit 1; }
info() { echo "${CYAN}$1${RESET}" >&2; }
warn() { echo "${YELLOW}Warning: $1${RESET}" >&2; }

# --- Tool detection ---

detect_tool() {
  if command -v gt &>/dev/null; then
    echo "graphite"
  elif command -v git &>/dev/null; then
    echo "git"
  else
    echo "none"
  fi
}

detect_trunk() {
  local remote="${1:-origin}"
  if git rev-parse --verify "$remote/main" &>/dev/null; then
    echo "main"
  elif git rev-parse --verify "$remote/master" &>/dev/null; then
    echo "master"
  else
    git remote show "$remote" 2>/dev/null | awk '/HEAD branch/{print $NF}' || echo "main"
  fi
}

# --- Usage ---

usage() {
  cat <<'EOF'
Usage: git-workflow <command> [options]

Commands:
  status     Detect environment and report repo state (default)
  commit     Guided commit with conventional format
  split      Analyze and decompose large diffs
  stack      View and manage branch stack
  worktree   Create isolated worktree
  clean      Remove merged/gone branches

Options:
  --help     Show this help message

Run 'git-workflow <command> --help' for command-specific options.

Exit codes:
  0  Success
  1  Error
  2  Warnings
EOF
}

# --- Status subcommand ---

usage_status() {
  cat <<'EOF'
Usage: git-workflow status [options]

Detect git tool (Graphite or Git) and report repository state.

Options:
  --json     Output as JSON
  --help     Show this help message

Output includes:
  - Detected tool (graphite or git) and version
  - Current branch
  - Dirty file count (staged + unstaged)
  - Ahead/behind counts relative to remote
  - Stack state (Graphite only)
EOF
}

cmd_status() {
  local json_output=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --json) json_output=true; shift ;;
      --help) usage_status; exit 0 ;;
      *) die "Unknown option for status: $1" ;;
    esac
  done

  # Must be in a git repo
  git rev-parse --git-dir &>/dev/null || die "not a git repository"

  local tool
  tool=$(detect_tool)
  [[ "$tool" == "none" ]] && die "neither git nor gt found"

  local tool_version=""
  if [[ "$tool" == "graphite" ]]; then
    tool_version=$(gt --version 2>/dev/null || echo "unknown")
  else
    tool_version=$(git --version 2>/dev/null | awk '{print $3}')
  fi

  local branch
  branch=$(git branch --show-current 2>/dev/null || echo "detached")

  local trunk
  trunk=$(detect_trunk)

  # Dirty files
  local staged unstaged
  staged=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  unstaged=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
  local untracked
  untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

  # Ahead/behind
  local ahead=0 behind=0
  if git rev-parse --verify "origin/$branch" &>/dev/null; then
    ahead=$(git rev-list --count "origin/$branch..HEAD" 2>/dev/null || echo 0)
    behind=$(git rev-list --count "HEAD..origin/$branch" 2>/dev/null || echo 0)
  fi

  # Stack state (Graphite only)
  local stack_info=""
  if [[ "$tool" == "graphite" ]]; then
    stack_info=$(gt log short 2>/dev/null || echo "no stack")
  fi

  if [[ "$json_output" == true ]]; then
    cat <<ENDJSON
{
  "tool": "$tool",
  "toolVersion": "$tool_version",
  "branch": "$branch",
  "trunk": "$trunk",
  "staged": $staged,
  "unstaged": $unstaged,
  "untracked": $untracked,
  "ahead": $ahead,
  "behind": $behind
}
ENDJSON
  else
    echo "${BOLD}Git Workflow Status${RESET}"
    echo ""
    echo "  Tool:      ${GREEN}$tool${RESET} ($tool_version)"
    echo "  Branch:    ${CYAN}$branch${RESET}"
    echo "  Trunk:     $trunk"
    echo "  Staged:    $staged files"
    echo "  Unstaged:  $unstaged files"
    echo "  Untracked: $untracked files"
    echo "  Ahead:     $ahead commits"
    echo "  Behind:    $behind commits"
    if [[ -n "$stack_info" && "$stack_info" != "no stack" ]]; then
      echo ""
      echo "  ${BOLD}Stack:${RESET}"
      echo "$stack_info" | sed 's/^/    /'
    fi
  fi
}

# --- Subcommand routing ---

COMMAND="${1:-status}"
shift 2>/dev/null || true

case "$COMMAND" in
  status)   cmd_status "$@" ;;
  commit)   die "commit subcommand not yet implemented" ;;
  split)    die "split subcommand not yet implemented" ;;
  stack)    die "stack subcommand not yet implemented" ;;
  worktree) die "worktree subcommand not yet implemented" ;;
  clean)    die "clean subcommand not yet implemented" ;;
  --help|-h) usage; exit 0 ;;
  *)        die "Unknown command: $COMMAND. Run 'git-workflow --help' for usage." ;;
esac
```

### Step 2: Make executable

```bash
chmod +x skills/git-workflow/scripts/git-workflow
```

### Step 3: Verify

```bash
# Help works
skills/git-workflow/scripts/git-workflow --help

# Status works in this repo
cd /Users/hjewkes/Documents/projects/agents-skills
skills/git-workflow/scripts/git-workflow status

# JSON output works
skills/git-workflow/scripts/git-workflow status --json

# Shellcheck passes
shellcheck skills/git-workflow/scripts/git-workflow
```

### Step 4: Commit

```bash
git add skills/git-workflow/scripts/git-workflow
git commit -m "Add git-workflow CLI skeleton with status subcommand"
```

## Success Criteria

- [ ] `skills/git-workflow/scripts/git-workflow` is executable
- [ ] `git-workflow --help` prints usage
- [ ] `git-workflow status` reports tool, branch, dirty files, ahead/behind
- [ ] `git-workflow status --json` outputs valid JSON
- [ ] `shellcheck skills/git-workflow/scripts/git-workflow` passes clean

## Anti-patterns

- Do NOT modify files outside the ownership list above
- Do NOT modify CLAUDE.md or any persistent configuration files
- Do NOT add features beyond what is specified in the steps
- Do NOT implement other subcommands yet — use stub `die` messages
