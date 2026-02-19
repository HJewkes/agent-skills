# Atlassian (Jira & Confluence)

Jira issue tracking and Confluence page management for Atlassian Cloud.

## Install

```bash
npx skills add hjewkes/agent-skills --skill='atlassian'
```

## Prerequisites

- macOS with Homebrew
- An Atlassian Cloud account
- An API token from https://id.atlassian.com/manage/api-tokens

## Setup

Setup runs automatically on first use of `jira` or `confluence` wrappers. It:

1. Installs `jira-cli` and `jq` via Homebrew (if missing)
2. Prompts for your Atlassian domain, email, and API token
3. Writes credentials to `~/.atlassian-env` (mode 600)
4. Configures `jira-cli` for your instance
5. Validates connectivity to both Jira and Confluence
6. Adds `.atlassian-env` to your global gitignore

To re-run setup manually: `skills/atlassian/scripts/setup`

## Usage

### Jira

```bash
jira issue list -q "status = 'In Progress'" --plain
jira issue view PROJ-123 --raw | jq '.fields.summary'
jira issue create -t Bug -s "Login fails" --no-input
jira issue move PROJ-123 "In Review"
jira sprint list --current --plain
```

### Confluence

```bash
confluence search "type=page AND space=DEV AND title~\"roadmap\""
confluence get PAGE_ID
confluence create --space DEV --title "Page Title" --body "<p>Content</p>"
confluence update PAGE_ID --body-file ./content.html
confluence spaces
confluence comments PAGE_ID
```

## Configuration

Credentials are stored in `~/.atlassian-env`:

```
ATLASSIAN_DOMAIN=yoursite
ATLASSIAN_EMAIL=you@example.com
ATLASSIAN_API_TOKEN=your-token
```
