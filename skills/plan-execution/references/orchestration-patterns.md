# Orchestration Patterns

## Agent Spawn Rules

- Each agent gets **explicit file ownership** (which files it may modify)
- Spawn prompt includes **ALL context** -- agents don't inherit conversation history
- Include **return format constraint** in every spawn prompt (token budget + structure)
- **Max 4 concurrent agents** to avoid resource contention
- **Name agents by role**: `impl-auth`, `test-api`, `review-security`

## Dispatch Prompt Template

Every agent dispatch prompt must include these 6 sections:

### 1. Role
What the agent is and what expertise it brings.

### 2. Context
Scene-setting: where this fits, dependencies, architectural context. Include plan-id, task-id, briefing path, working directory. Point agents at their briefing file on disk -- never paste full briefing content inline.

### 3. Scope
Explicit file ownership list. Which files the agent may create or modify. Which files are read-only context.

### 4. Success Criteria
What "done" looks like. Measurable outcomes the agent can verify.

### 5. Return Format
Token budget (e.g., "under 500 tokens", "under 1000 tokens") and structure (e.g., "verdict first, then details"). Prevents output bloat from consuming coordinator context.

### 6. Anti-patterns
What NOT to do. Common mistakes specific to this task.

## Agent Role Templates

### Architect Agent
Use for: design decisions, dependency analysis, interface design.

```
Role: Code architect analyzing [system/component].
Context: [architectural context, constraints, existing patterns]
Scope: Read-only analysis of [files/directories].
Success Criteria: Produce design recommendation with trade-offs.
Return Format: Under 1000 tokens. Lead with recommendation, then rationale.
Anti-patterns: Don't implement anything. Don't suggest changes outside scope.
```

### Explorer Agent
Use for: codebase investigation, finding patterns, understanding existing code.

```
Role: Code explorer investigating [question/pattern].
Context: [what we know so far, what we need to find out]
Scope: Read-only exploration of [files/directories].
Success Criteria: Answer [specific question] with file:line references.
Return Format: Under 500 tokens. Answer first, then supporting evidence.
Anti-patterns: Don't modify any files. Don't speculate without evidence.
```

## Common Mistakes

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Too broad scope ("fix all the tests") | Agent gets lost, poor results | One clear problem domain per agent |
| No context in prompt | Agent wastes time rediscovering what you know | Include error messages, test names, relevant code |
| No constraints | Agent refactors everything | Explicit scope: "fix tests only", "don't change production code" |
| Vague output format | Don't know what changed, bloated responses | Specify token budget and structure |
| Spawning without file ownership | Two agents edit same file, merge conflicts | Explicit file ownership per agent |
| Pasting briefing inline | Wastes coordinator context budget | Point agent at briefing file path on disk |
| Dependent tasks in same wave | Race conditions, incomplete inputs | Tasks needing another task's output go in later waves |
| Skipping verification after merge | Subtle integration bugs | Run full test suite after integrating each agent's changes |
| Not re-reading manifest at wave boundaries | Lose track of completed tasks after compaction | Always re-read manifest.json from disk between waves |
| Using teams for sequential tasks | Overhead without parallelism benefit | Use subagent or batch mode instead |
