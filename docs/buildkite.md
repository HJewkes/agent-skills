# Buildkite

CI/CD pipeline management for Buildkite.

## Install

```bash
npx skills add hjewkes/agent-skills --skill='buildkite'
```

## Prerequisites

- macOS with Homebrew
- A Buildkite account
- An API token from https://buildkite.com/user/api-access-tokens (scopes: `read_builds`, `write_builds`, `read_pipelines`)

## Setup

Setup runs automatically on first use of the `buildkite` wrapper. It:

1. Installs `bk` CLI and `jq` via Homebrew (if missing)
2. Runs `bk configure` for API token setup
3. Prompts for your org slug
4. Writes org config to `~/.buildkite-env` (mode 600)
5. Validates connectivity with `bk whoami`
6. Adds `.buildkite-env` to your global gitignore

To re-run setup manually: `skills/buildkite/scripts/setup`

## Usage

```bash
buildkite build list --pipeline my-app
buildkite build view 42 --pipeline my-app
buildkite build create --pipeline my-app --branch main --message "Deploy"
buildkite job log JOB_ID
buildkite pipeline list
buildkite artifacts download --build 42 --pipeline my-app
```

All commands output JSON — pipe through `jq` for readable output.

## Configuration

Org slug is stored in `~/.buildkite-env`:

```
BUILDKITE_ORG=your-org-slug
```

API token is managed by `bk configure` (stored in `~/.config/buildkite/`).
