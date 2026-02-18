---
name: research
description: Use when the user asks to research a topic, investigate options, compare technologies, analyze a problem space, or gather information before making a decision — for both coding and non-coding work
---

# Research

## Overview

Structured research process that works for coding tasks (evaluating libraries, understanding APIs) and non-coding work (market research, content creation, learning new domains). Produces organized, actionable artifacts — and deposits findings into the brain for future retrieval.

## Process

### 1. Scope
Define what we're researching and why:
- What question(s) need answering?
- What decisions will this inform?
- What's out of scope?
- What format should the output take?

Confirm scope with user before proceeding.

### 2. Brain Check
Before gathering new information, search the brain for prior work:

```bash
brain search "<topic>" --category <project> --min-score 0.4 --expand --json
```

If relevant notes exist:
- Summarize what's already known
- Identify gaps that still need research
- Avoid re-researching settled questions
- Note any notes marked `outdated` or `low` confidence that may need updating

If nothing relevant: proceed to Gather.

### 3. Gather
Collect information from available sources:
- **Brain**: Prior decisions, patterns, and research (from step 2)
- **Code**: Read relevant files, grep for patterns, check dependencies
- **Web**: WebSearch for docs, articles, comparisons. WebFetch for specific pages
- **Docs**: Framework docs via context7 MCP if available
- **Context**: Check project CLAUDE.md, existing patterns

Use parallel subagents for independent research threads.

### 4. Organize
Structure findings:
- Group by theme, not by source
- Flag contradictions between sources and existing brain notes
- Note confidence level (verified, likely, uncertain)
- Separate facts from opinions

### 5. Synthesize
Draw conclusions:
- Answer the original questions directly
- Provide recommendation with reasoning
- List trade-offs explicitly
- Note what remains unknown

### 6. Artifact
Deliver in the agreed format:
- **Decision**: Recommendation + alternatives + trade-offs table
- **Comparison**: Feature matrix with weighted criteria
- **Summary**: Key findings + action items
- **Brief**: Background + analysis + recommendation (for sharing with others)

### 7. Deposit
After the user accepts findings, save to brain:

```bash
brain add artifact.md \
  --title "Research: <topic>" \
  --type research \
  --category <project> \
  --tags "<topic>,<domain>,<subtags>" \
  --summary "<one-line finding>" \
  --confidence <high|medium|low|speculative> \
  --review-interval 90d \
  --related "<existing-note-ids>"
```

If research supersedes an existing note, add `supersedes: <old-note-id>` to the frontmatter and update the old note's status to `outdated`.

**Skip deposit** if the research was trivial (quick lookups, single-fact answers) or the user declines.

## Quick Reference

| Research Type | Key Sources | Brain Type | Typical Output |
|--------------|-------------|------------|----------------|
| Library eval | npm/pypi, GitHub, docs, brain | research | Comparison matrix |
| Bug investigation | Code, logs, issue trackers | pattern | Root cause + fix options |
| Architecture | Brain decisions, code, web | decision | Decision document |
| Content/topic | Web search, articles, brain | research | Structured summary |
| API integration | API docs, examples, SDKs | research | Integration guide |

## Common Mistakes
- Starting to gather before defining scope (wastes time on irrelevant info)
- Skipping brain check (re-researching what's already known)
- Presenting raw findings without synthesis (user wants answers, not data dumps)
- Not confirming scope with user (researching the wrong thing)
- Single-source conclusions (verify across multiple sources)
- Forgetting to deposit (research evaporates after the session)
