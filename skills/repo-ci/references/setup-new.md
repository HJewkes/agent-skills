# Setup New Repo CI

Agent guide for `repo-ci` setup mode. Always preview before generating.

## Full Repo Init (New Projects)

For brand-new projects that need a GitHub repo created, use `repo-ci init` instead of `setup`:

```bash
repo-ci init --dry-run    # Preview what will happen
repo-ci init              # Create repo, configure settings, generate CI, push
```

This handles: repo creation, repo settings, branch rulesets, CI/release workflows, initial push.

Skip to [Step 4: Post-Setup Checklist](#step-4-post-setup-checklist) after init completes — steps 1-3 are handled automatically.

---

## Step 1: Preview First

In the target repo directory, always run with `--dry-run` before writing any files:

```bash
repo-ci setup --dry-run
```

If the stack is ambiguous or auto-detection may be wrong, confirm with the user and use `--preset`:

```bash
repo-ci setup --dry-run --preset node    # Node/TypeScript
repo-ci setup --dry-run --preset python  # Python
```

If `repo-ci setup` exits with code 2 and prints an unsupported-stack message, jump to [Exit Door Handling](#exit-door-handling) below.

## Step 2: Review with User

Show the user what will be generated:
- Which files will be created (e.g., `.github/workflows/ci.yml`, `.github/workflows/release.yml`)
- Whether any existing files will be overwritten
- Which preset was selected and why

Confirm before proceeding:
> "This will create the above files. Shall I go ahead?"

## Step 3: Generate

Once confirmed, run without `--dry-run`:

```bash
repo-ci setup
```

Or with an explicit preset if needed:

```bash
repo-ci setup --preset node
```

Exit code 0 = files written successfully.

The setup command automatically checks for required npm scripts (Node projects only) and warns about any that are missing. Review the post-setup output and add any missing scripts to `package.json` before pushing.

## Step 4: Post-Setup Checklist

### 4a. CODECOV_TOKEN Secret

Coverage upload requires a repo secret:

1. Go to [codecov.io](https://codecov.io) and add the repo
2. Copy the upload token
3. In GitHub: Settings → Secrets and variables → Actions → New repository secret
4. Name: `CODECOV_TOKEN`, value: the token from codecov.io

### 4b. Verify CI Runs

```bash
git add .github/workflows/
git commit -m "Add CI/CD workflows"
git push
```

Open the Actions tab in GitHub and confirm the CI workflow runs without errors on the push.

### 4c. Confirm Branch Rulesets

Branch rulesets are created automatically by `repo-ci init` and `repo-ci setup`. Verify they are active:

```bash
gh api repos/{owner}/{repo}/rulesets
```

If the response is an empty array, set up rulesets manually:
- GitHub repo → Settings → Rules → Rulesets
- Require a pull request before merging
- Disable force push and branch deletion on `main`

See [standards.md](standards.md) under Universal Standards for the full ruleset spec.

## Exit Door Handling

If `repo-ci setup` exits with code 2 (unsupported stack), generate a minimal CI scaffold manually.

### Minimal CI Scaffold

Create `.github/workflows/ci.yml` with:
- `gitleaks/gitleaks-action@v2` for secret scanning (with `fetch-depth: 0`)
- A basic lint job appropriate for the stack
- A basic test job appropriate for the stack

Trigger on `push: branches: [main]` and `pull_request: branches: [main]`.

### Encourage Extending the Skill

Let the user know how to add proper support for their stack:

> "This stack isn't supported by `repo-ci` yet. Here's how to add it:"

1. Add a new template in `skills/repo-ci/templates/<stack>/` — model it after the existing `node/` or `python/` directories
2. Update `skills/repo-ci/references/standards.md` with the new stack's standards
3. The script's stack detection is in `skills/repo-ci/scripts/repo-ci` — add the new preset there

## Common Customizations

After generation, the user may want to adjust these:

| Customization | Where to change |
|---------------|-----------------|
| Coverage thresholds | `vitest.config.ts` → `test.coverage.thresholds` (set ~5% below current levels) |
| Exclude heavy test files from PR CI | CI workflow `vitest run` command → add `--exclude` flag |
| Add Node version matrix | CI workflow `strategy.matrix.node-version` |
| Change coverage failure behavior | CI workflow codecov step → `fail_ci_if_error: true/false` |
| Add extra lint or type-check steps | Add jobs to the generated workflow file |

For threshold guidance, see [standards.md](standards.md) under Coverage Thresholds.
