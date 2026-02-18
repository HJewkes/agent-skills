# Build Failure Debugging Guide

Step-by-step workflow for diagnosing and resolving Buildkite build failures.

---

## Triage Workflow

### Step 1: Find the failed build

```bash
# List recent failed builds for a pipeline
bk build list --pipeline SLUG --state failed

# Or find builds for a specific branch
bk build list --pipeline SLUG --branch BRANCH_NAME
```

### Step 2: Inspect build details

```bash
# View the build — note which jobs failed
bk build view BUILD_NUMBER --pipeline SLUG
```

### Step 3: Get the failed job log

```bash
# List jobs to find the failed one
bk job list --build BUILD_NUMBER --pipeline SLUG

# Read the job log
bk job log JOB_ID
```

### Step 4: Download artifacts

```bash
# Test reports, coverage files, screenshots, etc.
bk artifacts download --build BUILD_NUMBER --pipeline SLUG
```

### Step 5: Analyze and fix

Read the log output. Cross-reference with the failure categories below to identify root cause.

---

## Common Failure Categories

### Test Failures

**Indicators:**
- Exit code 1 from test runner
- Lines like `FAIL`, `FAILED`, `AssertionError`, `Expected ... but got ...`
- Test framework summary (e.g., `3 failed, 42 passed`)

**Log patterns to grep:**
```bash
bk job log JOB_ID | grep -E '(FAIL|ERROR|AssertionError|Expected.*got)'
```

**Action:** Read the specific test failures, check if they reproduce locally, fix the code.

### Dependency Resolution Errors

**Indicators:**
- `npm ERR!`, `pip install failed`, `Could not resolve dependencies`
- Package version conflicts, missing packages
- Registry authentication failures

**Log patterns to grep:**
```bash
bk job log JOB_ID | grep -iE '(ERR!|could not resolve|not found|403|401)'
```

**Action:** Check lock files, verify registry access, pin problematic versions.

### Timeouts

**Indicators:**
- `Job timed out`, `exceeded time limit`
- Build terminated without test output completing
- Builds that ran much longer than usual

**Action:** Check for infinite loops, long-running tests, or resource contention. Consider increasing timeout or splitting the job.

### Out of Memory (OOM)

**Indicators:**
- `Killed`, `OOMKilled`, `signal: killed`
- Process terminated without error output
- Memory usage spikes in agent metrics

**Action:** Profile memory usage, reduce parallelism, increase agent memory, or split into smaller jobs.

### Flaky Tests

**Indicators:**
- Test passes on retry without code changes
- Intermittent failures in the same test
- Timing-dependent assertions

**Diagnosis:**
```bash
# Rebuild to confirm flakiness
bk build rebuild BUILD_NUMBER --pipeline SLUG

# Compare logs between failing and passing runs
```

**Action:** Fix timing dependencies, add retries for external service calls, quarantine flaky tests.

### Infrastructure Issues

**Indicators:**
- `docker pull` failures, registry timeouts
- Agent disconnected, agent lost
- Network connectivity errors
- `No agents available`

**Action:** Check agent status (`bk agent list`), verify Docker registry access, check network connectivity.

### Permission / Auth Failures

**Indicators:**
- `403 Forbidden`, `401 Unauthorized`
- Secret or environment variable missing
- Deployment credentials expired

**Log patterns to grep:**
```bash
bk job log JOB_ID | grep -iE '(403|401|forbidden|unauthorized|permission denied|access denied)'
```

**Action:** Rotate credentials, verify environment variables are set in pipeline settings, check IAM/role permissions.

---

## Tips

- **Start with the last 50 lines** of a failed job log — the error summary is usually at the end.
- **Compare with last passing build** — diff the logs to find what changed.
- **Check the commit diff** — the failure is usually in the code that changed between the last green build and this one.
- **Use `bk api`** for detailed job metadata if `bk job list` output is insufficient.
