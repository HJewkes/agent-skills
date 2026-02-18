---
name: buildkite
description: Buildkite CI/CD integration. Use when the user needs to check build status, trigger builds, read build logs, debug failures, manage pipelines, or any Buildkite workflow. Triggers include "buildkite", "build", "pipeline", "CI", "deploy", "build log", "build failed".
allowed-tools: Bash(bk:*)
---

# Buildkite — CI/CD

## Setup

Run `scripts/setup` for first-time configuration.

## Build Operations

```bash
# List recent builds for a pipeline
bk build list --pipeline SLUG

# View build details
bk build view BUILD_NUMBER --pipeline SLUG

# Trigger a new build
bk build create --pipeline SLUG --branch main --message "Deploy"

# Rebuild a failed build
bk build rebuild BUILD_NUMBER --pipeline SLUG

# Cancel a running build
bk build cancel BUILD_NUMBER --pipeline SLUG
```

## Job & Log Operations

```bash
# List jobs for a build
bk job list --build BUILD_NUMBER --pipeline SLUG

# View job log output
bk job log JOB_ID

# Download build artifacts
bk artifacts download --build BUILD_NUMBER --pipeline SLUG
```

## Pipeline Operations

```bash
# List all pipelines
bk pipeline list

# View pipeline configuration
bk pipeline view SLUG
```

## Failure Debugging Workflow

When a build fails, follow this sequence:

1. Find the failed build:
   `bk build list --pipeline SLUG --state failed`

2. View build details to see which jobs failed:
   `bk build view BUILD_NUMBER --pipeline SLUG`

3. Get the failed job's log:
   `bk job log JOB_ID`

4. Download artifacts (test reports, etc.) if available:
   `bk artifacts download --build BUILD_NUMBER --pipeline SLUG`

For detailed debugging patterns, load `references/build-debugging.md`.

## Output Conventions

- `bk` outputs JSON by default — pipe through `jq` for display or extraction.
- Use `bk api` for REST API endpoints not covered by direct commands.
- Example: `bk api /v2/organizations/ORG/pipelines | jq '.[].slug'`

## Reference Files

| Reference | When to Load |
|-----------|-------------|
| references/bk-commands.md | Full bk CLI command reference needed |
| references/build-debugging.md | Debugging build failures in depth |
| references/troubleshooting.md | Auth failures, CLI errors, rate limits |
