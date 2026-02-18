# Buildkite CLI — Command Reference

Full reference for the `bk` CLI. For quick examples, see SKILL.md.

---

## Authentication & Config

```bash
# First-time setup — interactive API token configuration
bk configure

# Show current authenticated user
bk whoami

# Switch between configured profiles/orgs
bk use PROFILE_NAME
```

---

## Builds

```bash
# List builds (most recent first)
bk build list --pipeline SLUG
bk build list --pipeline SLUG --state failed
bk build list --pipeline SLUG --state running
bk build list --pipeline SLUG --branch BRANCH_NAME

# View a specific build
bk build view BUILD_NUMBER --pipeline SLUG

# Create (trigger) a new build
bk build create --pipeline SLUG --branch BRANCH --message "MESSAGE"
bk build create --pipeline SLUG --branch BRANCH --commit HEAD --message "MESSAGE"

# Rebuild (retry) a build
bk build rebuild BUILD_NUMBER --pipeline SLUG

# Cancel a running build
bk build cancel BUILD_NUMBER --pipeline SLUG

# Download build resources
bk build download BUILD_NUMBER --pipeline SLUG
```

---

## Jobs

```bash
# List jobs within a build
bk job list --build BUILD_NUMBER --pipeline SLUG

# View job log output
bk job log JOB_ID
```

---

## Pipelines

```bash
# List all pipelines in the org
bk pipeline list

# View pipeline details
bk pipeline view SLUG
```

---

## Artifacts

```bash
# List artifacts for a build
bk artifacts list --build BUILD_NUMBER --pipeline SLUG

# Download artifacts
bk artifacts download --build BUILD_NUMBER --pipeline SLUG
bk artifacts download --build BUILD_NUMBER --pipeline SLUG --path "GLOB_PATTERN"
```

---

## Agents

```bash
# List connected agents
bk agent list
```

---

## API Escape Hatch

For any Buildkite REST API endpoint not covered by direct commands, use `bk api`:

```bash
# GET request (default)
bk api /v2/organizations/ORG/pipelines

# With jq for extraction
bk api /v2/organizations/ORG/pipelines | jq '.[].slug'

# GET with query params
bk api "/v2/organizations/ORG/pipelines/SLUG/builds?state=failed&per_page=5"

# POST request
bk api --method POST /v2/organizations/ORG/pipelines/SLUG/builds \
  --body '{"branch": "main", "message": "API triggered"}'
```

### Common REST API Endpoints

| Endpoint | Description |
|----------|-------------|
| `/v2/organizations/ORG/pipelines` | List pipelines |
| `/v2/organizations/ORG/pipelines/SLUG/builds` | List builds for pipeline |
| `/v2/organizations/ORG/pipelines/SLUG/builds/NUMBER` | Get build details |
| `/v2/organizations/ORG/pipelines/SLUG/builds/NUMBER/jobs/JOB_ID/log` | Get job log |
| `/v2/organizations/ORG/agents` | List agents |

---

## Output Tips

- `bk` outputs JSON by default. Always pipe through `jq` for readability or extraction.
- Use `jq -r` for raw string output (no quotes).
- Chain with `| jq '.[0]'` to get the most recent item from a list.
- Use `bk api` + `jq` for advanced filtering the CLI doesn't support natively.
