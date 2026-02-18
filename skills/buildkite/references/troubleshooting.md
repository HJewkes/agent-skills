# Buildkite Skill — Troubleshooting Reference

Common failures with the `bk` CLI, with symptom, cause, and fix.

---

## Authentication

### 401 Unauthorized

**Symptom:** `bk` commands fail with `401 Unauthorized` or `bk whoami` returns an auth error.

**Causes:**
- API token expired or revoked
- Token lacks required scopes
- Token copied with leading/trailing whitespace

**Fix:**
1. Generate a new token at <https://buildkite.com/user/api-access-tokens>
2. Ensure the token has `read_builds`, `write_builds`, `read_pipelines` scopes at minimum
3. Re-run setup:
   ```
   skills/specialized/buildkite/scripts/setup
   ```

---

### 403 Forbidden

**Symptom:** A specific operation returns `403 Forbidden` (e.g., triggering a build, canceling a build).

**Causes:**
- API token missing required scopes for that operation
- User lacks permissions in the Buildkite organization

**Fix:**
- Check token scopes at <https://buildkite.com/user/api-access-tokens>
- Required scopes: `read_builds`, `write_builds` for build operations; `read_pipelines` for pipeline listing
- Ask an org admin to grant the necessary permissions

---

## Configuration

### `bk` command not found

**Symptom:** Shell returns `command not found: bk` or similar.

**Cause:** The Buildkite CLI is not installed or not in PATH.

**Fix:**
```bash
brew tap buildkite/buildkite && brew install buildkite/buildkite/bk
```

Or download a binary from <https://github.com/buildkite/cli/releases>.

---

### `bk` commands fail with "not configured"

**Symptom:** `bk` commands exit with a configuration error or prompt for setup.

**Cause:** `bk configure` was never run, or the config file is missing/corrupted.

**Fix:**
```bash
# Re-run configuration
bk configure

# Or run the full skill setup
skills/specialized/buildkite/scripts/setup
```

---

### `~/.buildkite-env` not found

**Symptom:** The skill's convenience scripts can't find the org slug.

**Cause:** The env file doesn't exist or was deleted.

**Fix:**
```bash
# Re-run setup
skills/specialized/buildkite/scripts/setup

# Or create manually
echo "BUILDKITE_ORG=your-org-slug" > ~/.buildkite-env
chmod 600 ~/.buildkite-env
```

---

## Rate Limiting

### 429 Too Many Requests

**Symptom:** `bk` commands or `bk api` calls return `429 Too Many Requests`.

**Cause:** Buildkite enforces API rate limits (varies by plan).

**Fix:**
- Wait 60 seconds before retrying
- Reduce request frequency — avoid rapid sequential `bk api` calls
- Use pagination to limit result sets

---

## Common CLI Errors

### Pipeline not found

**Symptom:** `bk build list --pipeline SLUG` returns a "not found" error.

**Causes:**
- Pipeline slug is wrong (check for typos)
- Pipeline is in a different organization than the configured one
- Pipeline was recently deleted

**Fix:**
```bash
# List all pipelines to find the correct slug
bk pipeline list

# Verify the current org
bk whoami
```

---

### Build number not found

**Symptom:** `bk build view BUILD_NUMBER --pipeline SLUG` returns "not found".

**Causes:**
- Build number is wrong
- Build belongs to a different pipeline

**Fix:**
```bash
# List recent builds to find the correct number
bk build list --pipeline SLUG
```

---

## Quick Diagnostic Commands

```bash
# Test authentication
bk whoami

# Check CLI version
bk version

# List pipelines (verifies auth + org access)
bk pipeline list

# Test API access directly
bk api /v2/organizations/ORG/pipelines | jq 'length'

# Re-run full setup
skills/specialized/buildkite/scripts/setup
```
