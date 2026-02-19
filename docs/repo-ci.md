# repo-ci

CI audit and scaffolding CLI for Node.js and Python projects.

## Install

```bash
npx skills add hjewkes/agent-skills --skill='repo-ci'
```

## Prerequisites

- Bash 4+
- `gh` CLI (optional — enables GitHub-specific checks like branch protection)

## Usage

### Audit an existing repo

```bash
repo-ci audit              # Human-readable scorecard
repo-ci audit --json       # Machine-readable JSON output
```

Scores the repo across 6 areas: linting, testing, CI workflows, branch protection, security scanning, and release automation. Reports gaps and offers to fix them.

### Scaffold CI for a new project

```bash
repo-ci setup --dry-run    # Preview what would be generated
repo-ci setup              # Generate workflow files
```

Detects project type (Node.js or Python) and generates GitHub Actions workflows, branch protection rules, and a release pipeline.

### Other commands

```bash
repo-ci --help             # Full usage
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error |
