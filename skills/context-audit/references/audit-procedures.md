# Context Audit — Detailed Procedures

## Static Inventory Procedure

> **Automation:** `scripts/audit-context` automates Steps 1-4 below. Use `--json` for structured output. The manual steps remain here as reference.

### Step 1: Discover Skills

```
Glob: ~/.claude/skills/*/SKILL.md
```

For each skill directory found:
- Read `SKILL.md` — record byte size and word count
- Glob `rules/*.md` — record count and total size (these are always-on)
- Glob `references/*.md` — record count and total size (these are on-demand)

### Step 2: Measure CLAUDE.md Files

Read these files if they exist:
- `~/CLAUDE.md` (global)
- `{project-root}/CLAUDE.md` (project-level)
- `{project-root}/.claude/CLAUDE.md` (alternate location)

Record byte size and word count for each.

### Step 3: Count Plugins and MCP Servers

Read `~/.claude/settings.json` and extract:
- `plugins` array — count entries
- `mcpServers` object — count keys
- For each MCP server, note if it has custom tool descriptions

### Step 4: Build Inventory Table

Sort all entries by size descending. Format:

```
| Source | Size | Words | Loads | Flag |
|--------|------|-------|-------|------|
| skills/tailwind/SKILL.md | 2.1KB | 620 | on-trigger | LARGE |
| CLAUDE.md (global) | 3.4KB | 890 | always-on | LARGE |
| skills/research/rules/defaults.md | 450B | 95 | always-on | RULES |
| ... | ... | ... | ... | ... |
```

Flag column values:
- `LARGE` — SKILL.md > 500 words or CLAUDE.md > 2KB
- `RULES` — any file in a rules/ directory (always loaded)
- `MCP` — 5+ MCP servers configured
- `-` — within acceptable range

Compute totals:
- **Always-on context**: sum of all rules/ files + CLAUDE.md files + plugin/MCP overhead estimate (200 words per MCP server, 50 words per plugin for tool descriptions)
- **On-trigger context**: average SKILL.md size across all skills

## Session Token Analysis

> **Automation:** `scripts/audit-context --session [path]` performs the full analysis below. Use `--json` for structured output. Use `--top N` to control spike count.

### What It Measures

- **Per-turn token usage**: input tokens, cache creation, and cache read tokens for each assistant turn
- **Context growth**: delta between consecutive turns, identifying where context expands
- **Top spikes**: largest input token jumps, correlated with the preceding tool call (Read, Skill, MCP, etc.)
- **Cache hit rate**: percentage of input tokens served from cache across the session

### Running the Analysis

Auto-detect the most recent session:
```bash
audit-context --session
```

Analyze a specific session file:
```bash
audit-context --session ~/.claude/projects/{hash}/{id}.jsonl
```

JSON output for programmatic use:
```bash
audit-context --session --json
```

### Interpreting the Output

- **Growth rate**: tokens added per turn on average. Over 5K/turn suggests large file reads or verbose tool output.
- **Top spikes**: each spike shows the token delta and the tool call that likely caused it. Large Read operations and Skill loads are the most common causes.
- **Cache hit rate**: higher is better. Below 30% means the context is changing too frequently for caching to help. Above 50% indicates good cache reuse.

## Scoring Rubric

### Skills Health (30 points)

| Condition | Points |
|-----------|--------|
| All SKILL.md files < 500 words | +10 |
| No rules/ directories (nothing always-on) | +10 |
| References used for detailed content | +5 |
| No overlapping skill triggers | +5 |

Deductions:
- Each SKILL.md > 500 words: -3
- Each rules/ directory: -5
- Each skill > 1000 words without references: -3

### CLAUDE.md Health (25 points)

| Condition | Points |
|-----------|--------|
| Global CLAUDE.md < 2KB | +10 |
| Project-specific CLAUDE.md exists and is focused | +5 |
| No duplication between global and project | +5 |
| Clear, actionable instructions (not vague) | +5 |

Deductions:
- Global CLAUDE.md > 4KB: -10
- Duplicated content across CLAUDE.md files: -5

### Plugin/MCP Health (25 points)

| Condition | Points |
|-----------|--------|
| < 5 MCP servers | +10 |
| < 10 plugins | +5 |
| All MCP servers actively used in session | +5 |
| No redundant tool providers | +5 |

Deductions:
- Each MCP server beyond 5: -3
- Each plugin beyond 15: -2

### Session Efficiency (20 points)

| Condition | Points |
|-----------|--------|
| Average growth < 5K tokens/turn | +10 |
| No single spike > 20K tokens | +5 |
| Cache hit rate > 50% | +5 |

Deductions:
- Average growth > 10K tokens/turn: -5
- Any spike > 30K tokens: -5
- Cache hit rate < 30%: -5

If no session JSONL is available, score this component at 10/20 (neutral).

### Letter Grades

| Score | Grade |
|-------|-------|
| 90-100 | A |
| 80-89 | B+ |
| 70-79 | B |
| 60-69 | C+ |
| 50-59 | C |
| 40-49 | D |
| 0-39 | F |

## Recommendation Rules

Generate recommendations based on findings. Priority order:

1. **rules/ directories exist** → "Move `{skill}/rules/{file}` content into SKILL.md — rules/ files load every conversation regardless of skill use"
2. **SKILL.md > 500 words** → "Extract detailed procedures from `{skill}/SKILL.md` into `references/` — keeps trigger cost low"
3. **CLAUDE.md > 4KB** → "Split global CLAUDE.md — move project-specific instructions to per-project files"
4. **5+ MCP servers** → "Review MCP server list — each adds tool descriptions to every conversation. Disable unused servers."
5. **Session spike > 20K tokens** → "Large context spike from {source} — consider chunked reads or summarization"
6. **Overlapping skill triggers** → "Skills `{a}` and `{b}` may both trigger on similar inputs — consolidate or differentiate triggers"
7. **No references/ used** → "Skills with large SKILL.md files should use references/ for detailed content that's only read when needed"
8. **High plugin count (15+)** → "Each plugin adds tool descriptions to context. Disable plugins you rarely use."

Format each recommendation with:
- What was found (evidence)
- What to do (action)
- Expected impact (words/tokens saved estimate)
