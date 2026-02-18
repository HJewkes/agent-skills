# CI/Release Standards

Source of truth for what a well-configured repo looks like. Referenced by audit scripts and agent guides. Patterns drawn from: brain, workout-analytics, voltra-node-sdk, titan-design.

---

## Universal Standards (all stacks)

| Area | Standard | Details |
|------|----------|---------|
| CI triggers | push to main + PRs to main | `on: push: branches: [main]` + `pull_request: branches: [main]` |
| Secret scanning | `gitleaks/gitleaks-action@v2` | Runs first; requires `fetch-depth: 0` on checkout |
| Branch protection | Rulesets via GitHub UI | Require PRs, no force push, no branch deletion |

---

## Node/TypeScript Standards

### CI Jobs

| Job | Tool | Command |
|-----|------|---------|
| Secret scan | gitleaks-action@v2 | (see Universal) |
| Dependency audit | npm audit | `npm audit --audit-level=critical` |
| Linting | ESLint | `npm run lint` |
| Format check | Prettier | `npm run format:check` |
| Type check | tsc | `npm run typecheck` |
| Tests | Vitest | `npx vitest run --coverage` (exclude heavy tests in PR CI) |
| Coverage upload | codecov-action@v5 | `fail_ci_if_error: false`; requires `CODECOV_TOKEN` secret |
| Build verify | shell | `test -f dist/<output> \|\| exit 1` |

### Release Pipeline

Trigger: `push: tags: v*`

| Step | Details |
|------|---------|
| 1. validate | lint + format:check + typecheck + test + build |
| 2. verify version | tag version must match `package.json` version |
| 3. publish | `npm publish --provenance --access public`; needs `id-token: write` permission |
| 4. github-release | `softprops/action-gh-release@v2`; `generate_release_notes: true`; auto-detect prereleases (`-alpha`, `-beta`, `-rc`) |

### Coverage Thresholds

| Approach | Detail |
|----------|--------|
| Measure first | Run `vitest --coverage` to get current levels |
| Set thresholds | Set ~5% below current measured levels |
| Enforce in CI | Vitest fails the job if thresholds are not met |
| Config location | `vitest.config.ts` → `test.coverage.thresholds` |
| Provider | `@vitest/coverage-v8` |

Example thresholds block:
```ts
coverage: {
  provider: 'v8',
  thresholds: { lines: 60, functions: 60, branches: 50 },
}
```

---

## Python Standards

### CI Jobs

| Job | Tool | Command |
|-----|------|---------|
| Secret scan | gitleaks-action@v2 | (see Universal) |
| Dependency audit | pip-audit | `pip-audit` |
| Linting | ruff | `ruff check .` |
| Type check | mypy | `mypy src/` |
| Tests | pytest | `pytest --cov --cov-report=xml` |
| Coverage upload | codecov-action@v5 | same as Node |

### Release Pipeline

Trigger: `push: tags: v*`

| Step | Details |
|------|---------|
| 1. validate | lint + typecheck + test |
| 2. publish | PyPI Trusted Publishing (OIDC); no stored token needed |
| 3. github-release | `softprops/action-gh-release@v2`; `generate_release_notes: true` |

---

## Special Considerations

| Scenario | Pattern |
|----------|---------|
| Native modules (e.g. better-sqlite3) | Compile via `npm ci` on ubuntu-latest; no special setup needed |
| Heavy optional deps (e.g. HuggingFace models) | Exclude those test files in PR CI via `--exclude` flag |
| Heavy test separation | Run excluded tests only in release `validate` job (all tests run on tag push) |
| Node version matrix | Use `strategy.matrix.node-version: [20, 22]` for libraries; pin single version for CLIs/apps |
| Prerelease detection | `contains(github.ref, '-alpha') \|\| contains(github.ref, '-beta') \|\| contains(github.ref, '-rc')` |
| OIDC npm publish | Requires `permissions: id-token: write` at job level; use `--provenance` flag |
