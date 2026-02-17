# agent-skills

Curated agent skills for software development workflows. 27 skills, 2 agents, and config examples — ready to install.

## Install

### All skills

```bash
npx skills add hjewkes/agent-skills --skill='*'
```

### Specific skills

```bash
npx skills add hjewkes/agent-skills --skill='code-review'
```

### Claude Code plugin (alternative)

```bash
# Add marketplace, then install
claude plugin marketplace add HJewkes/agent-skills
claude plugin install hjewkes-skills@hjewkes-agent-skills
```

Note: Plugin install namespaces skills as `/hjewkes-skills:skill-name`. The `npx skills add` method uses bare names.

### Update

```bash
npx skills check
npx skills update
```

## Skills Catalog

### Workflow

| Skill | Description | Origin |
|-------|-------------|--------|
| `brainstorming` | Explores user intent before implementation | Fork of obra/superpowers |
| `writing-plans` | Multi-step task planning before touching code | Fork of obra/superpowers |
| `executing-plans` | Execute implementation plans with review checkpoints | Fork of obra/superpowers |
| `subagent-driven-development` | Execute plans with independent tasks via subagents | Fork of obra/superpowers |
| `dispatching-parallel-agents` | Run 2+ independent tasks in parallel | Fork of obra/superpowers |
| `finishing-a-development-branch` | Guide branch completion — merge, PR, or cleanup | Fork of obra/superpowers |
| `coordinator` | Orchestrate multiple agents on related tasks | Original |

### Quality

| Skill | Description | Origin |
|-------|-------------|--------|
| `code-review` | Unified code review dispatch system | Original |
| `receiving-code-review` | Handle review feedback with technical rigor | Fork of obra/superpowers |
| `code-simplify` | Simplify code for clarity and maintainability | Original |
| `verification-before-completion` | Run verification before claiming work is done | Fork of obra/superpowers |
| `test-driven-development` | Write tests before implementation code | Fork of obra/superpowers |
| `systematic-debugging` | Structured debugging before proposing fixes | Fork of obra/superpowers |

### Development

| Skill | Description | Origin |
|-------|-------------|--------|
| `feature-agents` | Deep codebase exploration for feature development | Original |
| `frontend-design` | Production-grade frontend interfaces with high design quality | Original |
| `using-git-worktrees` | Isolated git worktrees for feature work | Fork of obra/superpowers |
| `github-pr` | GitHub PR creation and review workflow | Original |
| `managing-github-issues` | Issue triage, creation, and status management | Original |
| `vitest` | Vitest testing — mocking, coverage, fixtures | Fork of antfu/skills |
| `tailwind` | Tailwind CSS v4 with shadcn/ui patterns | Original |
| `sdk-verify` | Verify Claude Agent SDK applications | Original |

### Meta

| Skill | Description | Origin |
|-------|-------------|--------|
| `skills-management` | Create, find, install, and manage skills | Original |
| `using-superpowers` | Skill discovery and invocation at conversation start | Fork of obra/superpowers |
| `self-improve` | Capture reusable insights from sessions | Original |
| `context-audit` | Audit context window and identify optimization targets | Original |
| `research` | Research topics, compare options, gather information | Original |

### Specialized

| Skill | Description | Origin |
|-------|-------------|--------|
| `agent-browser` | Browser automation for AI agents | Fork of vercel-labs/agent-browser |

## Agents

Agents are pre-configured reviewers that run as read-only analysis passes.

| Agent | Description | Model |
|-------|-------------|-------|
| `accessibility-reviewer` | WCAG 2.1 AA compliance review for UI code | Sonnet |
| `security-reviewer` | OWASP Top 10 security review | Sonnet |

## Config Examples

The `config-examples/` directory contains reference configurations for Claude Code (settings.json with safety hooks, permission patterns, and notification setup). These are not installed automatically — copy and adapt for your setup.

## Provenance

`skill-manifest.json` tracks the origin and lineage of every skill in this repo:

- **`type: "original"`** — written from scratch for this collection
- **`type: "fork"`** — forked from an upstream skill repo, with `upstream` and `forkedAt` fields

Forked skills come primarily from two sources:
- **[obra/superpowers](https://github.com/obra/claude-code-superpowers)** — workflow, planning, and quality skills
- **[antfu/skills](https://github.com/antfu/claude-code-skills)** — development tool skills (vitest)
- **[vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser)** — browser automation

All forks have been adapted: paths updated, conventions aligned, content refined. The manifest lets you trace any skill back to its source and track divergence over time.

## License

[MIT](LICENSE)
