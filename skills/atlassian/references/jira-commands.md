# jira-cli Command Reference

Loaded on demand when SKILL.md lacks detail for a specific command. Covers the full command surface Claude needs to construct correct jira-cli invocations.

---

## Global Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--project` | `-p` | Override the default project key |
| `--raw` | | Output raw JSON (machine-readable) |
| `--plain` | | Plain text output (no TUI) |
| `--no-input` | | Skip all interactive prompts |
| `--config` | | Path to config file |

---

## Issue Commands

### `jira issue list`

List issues filtered by project and optional criteria.

| Flag | Short | Description |
|------|-------|-------------|
| `--jql` | `-q` | Raw JQL string (runs within project context) |
| `--type` | `-t` | Issue type (Bug, Story, Task, Epic, …) |
| `--status` | `-s` | Status name; prefix `~` to negate: `-s~Open` |
| `--assignee` | `-a` | Assignee login; `-ax` = unassigned |
| `--priority` | `-y` | Priority (Highest, High, Medium, Low, Lowest) |
| `--label` | `-l` | Label filter |
| `--created` | | Created date filter, e.g. `-1w`, `2024-01-01` |
| `--updated` | | Last-updated date filter, same syntax |
| `--paginate` | | `FROM:LIMIT` (max 100 per page) |
| `--columns` | | Comma-separated column names to display |
| `--plain` | | Plain text output |

Examples:

```bash
# All open bugs assigned to me
jira issue list -t Bug -s~Closed -a$(jira me --plain)

# JQL override — unresolved issues updated this week
jira issue list -q "resolution = Unresolved AND updated >= -1w ORDER BY updated DESC"

# Paginate: skip 20, return next 20
jira issue list --paginate 20:20 --plain

# Tabular output with specific columns
jira issue list --plain --columns key,summary,status,assignee
```

---

### `jira issue view KEY`

View a single issue.

| Flag | Short | Description |
|------|-------|-------------|
| `--raw` | | JSON output — pipe to jq for extraction |
| `--plain` | | Human-readable text |
| `--comments` | | Show last N comments |

Examples:

```bash
jira issue view PROJ-123 --plain
jira issue view PROJ-123 --raw | jq '.fields.status.name'
jira issue view PROJ-123 --comments 5 --plain
```

---

### `jira issue create`

Create a new issue.

| Flag | Short | Description |
|------|-------|-------------|
| `--type` | `-t` | Issue type (required) |
| `--summary` | `-s` | Summary / title (required for `--no-input`) |
| `--body` | `-b` | Description body |
| `--priority` | `-y` | Priority |
| `--assignee` | `-a` | Assignee login |
| `--label` | `-l` | Label (repeatable) |
| `--custom` | | Custom field: `--custom field=value` (repeatable) |
| `--no-input` | | Non-interactive — all required flags must be set |
| `--template` | | Path to a body template file |

Examples:

```bash
# Non-interactive bug creation
jira issue create -t Bug -s "Login fails on empty password" --no-input

# Story with description and label
jira issue create -t Story -s "Add dark mode" -b "Users need dark mode support" -l ui --no-input

# Custom field
jira issue create -t Task -s "Upgrade Node" --custom story_points=3 --no-input
```

---

### `jira issue edit KEY`

Edit an existing issue.

| Flag | Short | Description |
|------|-------|-------------|
| `--summary` | `-s` | New summary |
| `--body` | `-b` | New description |
| `--priority` | `-y` | New priority |
| `--assignee` | `-a` | New assignee |
| `--label` | `-l` | Label (repeatable) |
| `--custom` | | Custom field override |
| `--no-input` | | Non-interactive |

Examples:

```bash
jira issue edit PROJ-123 -s "Updated summary" --no-input
jira issue edit PROJ-123 -y High -a john --no-input
```

---

### `jira issue move KEY "STATE"`

Transition an issue to a new workflow state.

Aliases: `transition`, `mv`

| Flag | Short | Description |
|------|-------|-------------|
| `--comment` | | Add a comment during the transition |
| `-R` | | Set resolution (e.g. `Fixed`, `Won't Fix`) |

Examples:

```bash
jira issue move PROJ-123 "In Progress"
jira issue move PROJ-123 "Done" -R Fixed --comment "Deployed to prod"
jira issue transition PROJ-123 "In Review"
jira issue mv PROJ-123 "Closed"
```

---

### `jira issue assign KEY ASSIGNEE`

Assign an issue to a user. Use `x` as ASSIGNEE to unassign.

```bash
jira issue assign PROJ-123 john
jira issue assign PROJ-123 x          # unassign
```

---

### `jira issue comment add KEY "text"`

Add a comment to an issue.

| Flag | Description |
|------|-------------|
| `--template` | Path to a comment template file |
| `--no-input` | Non-interactive |

```bash
jira issue comment add PROJ-123 "Investigated — root cause is in auth middleware" --no-input
```

---

### `jira issue link KEY1 KEY2 TYPE`

Create an issue link. TYPE must match exactly.

Common link types: `Blocks`, `Duplicates`, `Clones`

```bash
jira issue link PROJ-123 PROJ-456 Blocks
jira issue link PROJ-789 PROJ-123 Duplicates
```

---

### `jira issue clone KEY`

Clone an issue.

| Flag | Short | Description |
|------|-------|-------------|
| `--summary` | `-s` | Override summary on the clone |
| `--replace` | `-H` | String substitution: `-H "old:new"` (repeatable) |

```bash
jira issue clone PROJ-123
jira issue clone PROJ-123 -s "Cloned: original summary" -H "v1:v2"
```

---

### `jira issue delete KEY`

Delete an issue permanently (no confirmation in `--no-input` mode).

```bash
jira issue delete PROJ-123
```

---

## Sprint Commands

### `jira sprint list`

List sprints for the board.

| Flag | Description |
|------|-------------|
| `--state` | Filter by state: `active`, `closed`, `future` |
| `--current` | Show only the active sprint |
| `--prev` | Show the most recently closed sprint |
| `--next` | Show the next planned sprint |
| `--table` | Tabular output |
| `--plain` | Plain text output |

```bash
jira sprint list --current --plain
jira sprint list --state active --plain
jira sprint list --prev --plain
```

---

### `jira sprint list SPRINT_ID`

List issues inside a specific sprint.

```bash
jira sprint list 42 --plain
jira sprint list 42 --plain --columns key,summary,status
```

---

### `jira sprint add SPRINT_ID KEY [KEY...]`

Move one or more issues into a sprint.

```bash
jira sprint add 42 PROJ-123
jira sprint add 42 PROJ-123 PROJ-124 PROJ-125
```

---

## Epic Commands

### `jira epic list`

List all epics in the project.

```bash
jira epic list --plain
```

---

### `jira epic list EPIC_KEY`

List issues belonging to a specific epic.

```bash
jira epic list PROJ-10 --plain
jira epic list PROJ-10 --plain --columns key,summary,status
```

---

### `jira epic create`

Create a new epic.

| Flag | Short | Description |
|------|-------|-------------|
| `--name` | `-n` | Epic name (displayed in roadmap) |
| `--summary` | `-s` | Epic summary / title |
| `--body` | `-b` | Description |
| `--priority` | `-y` | Priority |
| `--label` | `-l` | Label (repeatable) |
| `--no-input` | | Non-interactive |

```bash
jira epic create -n "Q3 Mobile Refresh" -s "All Q3 mobile work" --no-input
```

---

### `jira epic add EPIC_KEY KEY [KEY...]`

Add issues to an epic.

```bash
jira epic add PROJ-10 PROJ-123
jira epic add PROJ-10 PROJ-123 PROJ-124
```

---

### `jira epic remove KEY [KEY...]`

Remove issues from their epic (does not delete the issue).

```bash
jira epic remove PROJ-123
jira epic remove PROJ-123 PROJ-124
```

---

## Board Commands

### `jira board list`

List all boards accessible in the project.

```bash
jira board list --plain
```

---

## Utility Commands

### `jira me`

Return the current authenticated user's info.

```bash
jira me                     # interactive display
jira me --plain             # plain text — use in scripts
SELF=$(jira me --plain)     # capture login for use as -a flag
```

---

### `jira open KEY`

Open an issue in the default browser.

```bash
jira open PROJ-123
```

---

## JQL Flag Mechanics

### `-q` scope

`-q` appends JQL to the implicit `project = PROJECT` clause. It does not replace it.

```bash
# Equivalent to: project = PROJ AND status = "In Progress" ORDER BY created DESC
jira issue list -q "status = \"In Progress\" ORDER BY created DESC"
```

### Quoting rules

Double-quote the entire JQL expression. Single-quote inner values with spaces:

```bash
jira issue list -q "summary ~ \"login\" AND status != Done"
```

### Built-in filter negation

Prepend `~` to the short flag value to negate, not to the flag itself:

```bash
-s~Open          # status NOT "Open"
-s~"In Progress" # status NOT "In Progress"
-ax              # unassigned (special value, not negation syntax)
```

### Pagination

`--paginate FROM:LIMIT` — zero-indexed offset, max 100 per page.

```bash
# First page
jira issue list --paginate 0:50 --plain

# Second page
jira issue list --paginate 50:50 --plain
```

### Common JQL operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` | Exact match | `status = Done` |
| `!=` | Not equal | `status != Closed` |
| `~` | Contains (text) | `summary ~ "login"` |
| `!~` | Does not contain | `summary !~ "spike"` |
| `in` | In list | `status in (Open, "In Progress")` |
| `not in` | Not in list | `priority not in (Low, Lowest)` |
| `is EMPTY` | Field unset | `assignee is EMPTY` |
| `is not EMPTY` | Field set | `fixVersion is not EMPTY` |
| `>=` / `<=` | Date range | `created >= -2w` |
| `ORDER BY` | Sort | `ORDER BY updated DESC` |

---

## Output Flag Decision Tree

```
Need to display result to user?
  └─ Yes → --plain
       └─ Want columns? → --plain --columns key,summary,status

Need to extract a field for scripting?
  └─ Yes → --raw | jq '.fields.<fieldName>'
       └─ Multiple issues → --raw | jq '.[].fields.<fieldName>'

Need tabular data without TUI?
  └─ Yes → --plain --columns key,summary,status,assignee,priority
```

Never use TUI mode (the default) in scripts — it blocks on terminal interaction.
