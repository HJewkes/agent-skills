# Atlassian Skill — Troubleshooting Reference

Common failures from `jira` CLI and the `confluence` script, with symptom, cause, and fix.

---

## Authentication

### 401 Unauthorized

**Symptom:** Either tool returns `401 Unauthorized` or `jira me` fails with an auth error.

**Causes:**
- API token expired or revoked
- Wrong email address in `~/.atlassian-env`
- Token copied with leading/trailing whitespace

**Fix:**
1. Regenerate the token at <https://id.atlassian.com/manage/api-tokens>
2. Re-run setup to write the new credentials:
   ```
   skills/atlassian/scripts/setup
   ```

---

### 403 Forbidden

**Symptom:** Command returns `403 Forbidden` on a specific operation (e.g. creating a page, transitioning an issue).

**Causes:**
- The Atlassian user account lacks permissions for that resource or project
- Operation requires Confluence admin or Jira project admin role
- API token user is not a member of the target space or project

**Fix:**
- Confirm the account's role in Atlassian admin settings
- Ask an admin to grant the required permissions
- For Confluence: verify the user has Edit or Admin permissions for the target space

---

## Configuration

### jira commands fail with "no config found"

**Symptom:** `jira` commands exit with "no config found", "config file not found", or similar.

**Cause:** `~/.jira/.config.yml` is missing or corrupted — usually from a fresh install or a broken `jira init`.

**Fix:**
```bash
# Option 1: Re-run full setup (recommended)
skills/atlassian/scripts/setup

# Option 2: Re-initialize jira-cli directly
jira init --force
```

---

### Wrong project or board appears in jira output

**Symptom:** `jira issue list` shows issues from the wrong project; board commands target the wrong board.

**Cause:** jira-cli stores a default project in `~/.jira/.config.yml` that is stale or was set for a different context.

**Fix:**
```bash
# Re-initialize to select the correct project/board
jira init --force

# Or override per-command without changing defaults
jira issue list -p PROJECT_KEY
```

---

### `~/.atlassian-env` not found

**Symptom:** First-time use of `jira` or `confluence` wrappers triggers interactive setup.

**Cause:** The env file does not exist — this is expected on first run. The wrappers auto-detect and launch `scripts/setup`.

**Fix:** If setup was interrupted or failed, re-run manually:
```bash
skills/atlassian/scripts/setup
```

---

### Missing variable inside `~/.atlassian-env`

**Symptom:** The `confluence` script exits with `Missing ATLASSIAN_DOMAIN in /Users/<you>/.atlassian-env` (or `ATLASSIAN_EMAIL`, `ATLASSIAN_API_TOKEN`).

**Cause:** The env file exists but one or more required variables is blank or missing.

**Fix:** Re-run setup, or open `~/.atlassian-env` and add the missing variable.

---

## Rate Limiting

### 429 Too Many Requests

**Symptom:** A command returns `429 Too Many Requests` mid-run, often during bulk list or search operations.

**Cause:** Atlassian Cloud enforces a rate limit of approximately 100 requests per minute per user on REST API endpoints.

**Fix:**
- Wait 60 seconds before retrying
- Reduce the result set: pass `--limit 10` (or lower) to search and list operations
- Avoid running multiple `confluence` or `jira` commands in rapid succession

---

## API Errors

### `confluence search` returns empty for known content

**Symptom:** `confluence search "type=page AND title=\"My Page\""` returns `[]` despite the page existing in Confluence.

**Causes:**
- CQL syntax error — the API returns an empty result set instead of an error when the query is malformed
- Recently created or updated pages may not be indexed yet (indexing lag of a few minutes)

**Fix:**
1. Validate the CQL query in the Confluence UI first (search bar → Advanced search)
2. If the page was just created, wait 2–5 minutes and retry
3. Simplify the query to isolate the problematic clause: start with `type=page` and add filters one at a time

---

### `confluence update` fails with 409 Conflict

**Symptom:** `confluence update PAGE_ID ...` returns a `409 Conflict` error.

**Cause:** The version number sent in the PUT request does not match the current version on the server. This happens when the page was edited concurrently between the script's read and write steps.

**Fix:**
- The script re-reads the current version before every update, so a one-off 409 usually means someone else edited the page at the same moment — retry the command
- If 409 persists, another user may have the page open and actively editing; wait for them to save

---

### `confluence comments` returns 404

**Symptom:** `confluence comments PAGE_ID` returns a `404 Not Found` response.

**Cause:** Known bug in the Confluence v2 API with inline/footer comments for certain page types. The v2 endpoint (`/wiki/api/v2/pages/{id}/footer-comments`) does not exist or is not accessible for all pages.

**Fix:**
- This is an upstream Atlassian bug; no workaround is available via the current script
- Check the page in the Confluence UI to confirm comments exist
- If you need comment data for automation, file a support ticket with Atlassian referencing the v2 comments endpoint

---

## Connectivity

### `curl: (6) Could not resolve host`

**Symptom:** Any `confluence` subcommand exits immediately with `curl: (6) Could not resolve host: <domain>.atlassian.net`.

**Causes:**
- `ATLASSIAN_DOMAIN` in `~/.atlassian-env` is wrong (e.g. full URL instead of just the subdomain)
- No network connectivity

**Fix:**
1. Check `~/.atlassian-env` — `ATLASSIAN_DOMAIN` should be just the subdomain, not the full URL:
   ```
   # Correct
   ATLASSIAN_DOMAIN=myorg

   # Wrong
   ATLASSIAN_DOMAIN=https://myorg.atlassian.net
   ATLASSIAN_DOMAIN=myorg.atlassian.net
   ```
2. Verify network access: `ping myorg.atlassian.net`
3. Re-run setup to correct the domain: `skills/atlassian/scripts/setup`

---

## Quick Diagnostic Commands

```bash
# Test Jira authentication and identity
jira me

# Test Confluence authentication (returns number of accessible spaces, expect >= 1)
source ~/.atlassian-env && \
  curl -s \
    -u "${ATLASSIAN_EMAIL}:${ATLASSIAN_API_TOKEN}" \
    "https://${ATLASSIAN_DOMAIN}.atlassian.net/wiki/api/v2/spaces?limit=1" \
  | jq '.results | length'

# Check current jira-cli configuration
cat ~/.jira/.config.yml

# Show contents of env file (masked)
source ~/.atlassian-env && \
  echo "Domain: ${ATLASSIAN_DOMAIN}" && \
  echo "Email:  ${ATLASSIAN_EMAIL}" && \
  echo "Token:  ${ATLASSIAN_API_TOKEN:0:4}****"

# Re-run full setup (fixes most auth and config issues)
skills/atlassian/scripts/setup
```
