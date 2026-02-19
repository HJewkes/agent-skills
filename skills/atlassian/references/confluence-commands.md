# confluence Command Reference

Detailed reference for all subcommands of the `confluence` wrapper script.
Load this when you need flag details or examples beyond the SKILL.md overview.

## Authentication

The `confluence` wrapper auto-detects first run and launches `scripts/setup` to configure `~/.atlassian-env`. Help flags (`--help`) work without authentication.

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Failure |
| 2 | Partial / warning |

---

## search

```
confluence search "CQL query" [--limit N]
```

Search Confluence using CQL (Confluence Query Language). Paginates automatically — follows all `_links.next` cursors until all results are collected.

**Arguments**

| Argument | Required | Description |
|----------|----------|-------------|
| CQL query | Yes | CQL search string, passed as a positional argument |

**Options**

| Flag | Default | Description |
|------|---------|-------------|
| `--limit N` | 25 | Page size for each API request — not a total cap |
| `--help` | — | Print usage and exit |

**Output**

JSON array of search result objects. Progress lines (`Fetching: ...`) are written to stderr.

**Examples**

```bash
# Find pages in a space whose title contains "roadmap"
confluence search "type=page AND space=DEV AND title~\"roadmap\""

# Full-text search, smaller page size
confluence search "text ~ 'deployment'" --limit 10

# Extract page IDs from results
confluence search "space=OPS AND type=page" | jq '.[].content.id'
```

---

## get

```
confluence get PAGE_ID [--format storage|view]
```

Retrieve a Confluence page by its numeric ID, including the body content.

**Arguments**

| Argument | Required | Description |
|----------|----------|-------------|
| PAGE_ID | Yes | Numeric page ID |

**Options**

| Flag | Default | Description |
|------|---------|-------------|
| `--format storage\|view` | `storage` | `storage`: XHTML-like markup (writable). `view`: rendered HTML (read-only). |
| `--help` | — | Print usage and exit |

**Output**

Full page JSON object including `id`, `title`, `version`, and `body`.

**Examples**

```bash
# Get page body in storage format (default)
confluence get 12345

# Extract title and body content
confluence get 12345 | jq '.title, .body.storage.value'

# Get rendered HTML
confluence get 12345 --format view | jq '.body.view.value'
```

---

## create

```
confluence create --space KEY --title "..." [--body "..." | --body-file PATH] [--parent PAGE_ID]
```

Create a new page in the specified space. The space key is automatically resolved to a numeric space ID before the page is created.

**Options**

| Flag | Required | Description |
|------|----------|-------------|
| `--space KEY` | Yes | Space key (e.g., `DEV`, `OPS`) |
| `--title "..."` | Yes | Page title |
| `--body "..."` | No | Page body in storage format (XHTML) |
| `--body-file PATH` | No | Read body from a file instead of inline |
| `--parent PAGE_ID` | No | Numeric ID of the parent page for nesting |
| `--help` | — | Print usage and exit |

`--body` and `--body-file` are mutually exclusive. Omitting both creates a page with an empty body.

**Output**

JSON object of the created page, including the assigned `id`. Space resolution progress is written to stderr.

**Examples**

```bash
# Create a top-level page with inline body
confluence create --space DEV --title "API Guide" --body "<p>Content goes here.</p>"

# Create from a file
confluence create --space DEV --title "Release Notes" --body-file ./release-notes.html

# Create a child page under an existing page
confluence create --space DEV --title "v2 Notes" --body-file ./v2.html --parent 12345

# Capture the new page ID
NEW_ID=$(confluence create --space DEV --title "Draft" | jq -r '.id')
```

---

## update

```
confluence update PAGE_ID [--body "..." | --body-file PATH] [--title "..."]
```

Update an existing page. The script automatically reads the current version number and increments it — no manual version tracking needed. If `--title` is omitted, the current title is preserved.

**Arguments**

| Argument | Required | Description |
|----------|----------|-------------|
| PAGE_ID | Yes | Numeric page ID |

**Options**

| Flag | Required | Description |
|------|----------|-------------|
| `--body "..."` | No | New body in storage format (XHTML). Must be the full body — no partial updates. |
| `--body-file PATH` | No | Read body from a file instead of inline |
| `--title "..."` | No | New title. Keeps current title if omitted. |
| `--help` | — | Print usage and exit |

`--body` and `--body-file` are mutually exclusive. Omitting both sends an update without changing the body (title-only update).

**Output**

JSON object of the updated page. Version progression (`Updating from version N to N+1`) is written to stderr.

**Examples**

```bash
# Replace the body, keep the title
confluence update 12345 --body "<p>Revised content.</p>"

# Update from a file
confluence update 12345 --body-file ./updated.html

# Rename the page without changing the body
confluence update 12345 --title "New Title"

# Replace both title and body
confluence update 12345 --title "Updated Guide" --body-file ./new-content.html
```

---

## spaces

```
confluence spaces [--limit N]
```

List all Confluence spaces. Paginates automatically — follows all `_links.next` cursors until all spaces are collected.

**Options**

| Flag | Default | Description |
|------|---------|-------------|
| `--limit N` | 50 | Page size for each API request |
| `--help` | — | Print usage and exit |

**Output**

JSON array of space objects. Each object includes `id`, `key`, `name`, `type`, and `status`. Progress lines are written to stderr.

**Examples**

```bash
# List all spaces
confluence spaces

# Extract key and name pairs
confluence spaces | jq '.[] | {key, name}'

# Find a specific space by key
confluence spaces | jq '.[] | select(.key == "DEV")'

# List only global spaces
confluence spaces | jq '[.[] | select(.type == "global")]'
```

---

## comments

```
confluence comments PAGE_ID
```

List footer comments on a page. Paginates automatically.

**Arguments**

| Argument | Required | Description |
|----------|----------|-------------|
| PAGE_ID | Yes | Numeric page ID |

**Options**

| Flag | Description |
|------|-------------|
| `--help` | Print usage and exit |

**Output**

JSON array of footer comment objects. Body content is in storage format under `.body.storage.value`. Progress lines are written to stderr.

**Examples**

```bash
# List all comments on a page
confluence comments 12345

# Extract comment bodies
confluence comments 12345 | jq '.[].body.storage.value'

# Count comments
confluence comments 12345 | jq 'length'
```

---

## Common Patterns

### Search then read

Find a page by title or content, then retrieve its full body:

```bash
confluence search "title = 'Deploy Guide' AND space = 'OPS'" \
  | jq -r '.[0].content.id' \
  | xargs confluence get
```

### Search and extract body in one pipeline

```bash
confluence search "text ~ 'incident runbook'" \
  | jq -r '.[0].content.id' \
  | xargs -I{} confluence get {} --format storage \
  | jq -r '.body.storage.value'
```

### Find a space key then search within it

```bash
# Confirm a space exists before searching it
confluence spaces | jq '.[] | select(.key == "DEV")'

confluence search "space=DEV AND type=page" | jq '.[].title'
```

### Create then update

```bash
PAGE_ID=$(confluence create --space DEV --title "WIP" | jq -r '.id')
confluence update "$PAGE_ID" --body-file ./final.html --title "Final Doc"
```

### Bulk-read pages from search results

```bash
confluence search "label = 'runbook'" \
  | jq -r '.[].content.id' \
  | while read -r id; do
      confluence get "$id" | jq '{id: .id, title: .title}'
    done
```

### Read comments after finding a page

```bash
confluence search "title = 'Architecture Overview'" \
  | jq -r '.[0].content.id' \
  | xargs confluence comments
```
