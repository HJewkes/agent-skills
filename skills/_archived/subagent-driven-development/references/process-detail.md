# Subagent-Driven Development — Process Detail

## Decision Tree

```dot
digraph when_to_use {
    "Have implementation plan?" [shape=diamond];
    "Tasks mostly independent?" [shape=diamond];
    "Stay in this session?" [shape=diamond];
    "subagent-driven-development" [shape=box];
    "executing-plans" [shape=box];
    "Manual execution or brainstorm first" [shape=box];

    "Have implementation plan?" -> "Tasks mostly independent?" [label="yes"];
    "Have implementation plan?" -> "Manual execution or brainstorm first" [label="no"];
    "Tasks mostly independent?" -> "Stay in this session?" [label="yes"];
    "Tasks mostly independent?" -> "Manual execution or brainstorm first" [label="no - tightly coupled"];
    "Stay in this session?" -> "subagent-driven-development" [label="yes"];
    "Stay in this session?" -> "executing-plans" [label="no - parallel session"];
}
```

## Full Process Flow

```dot
digraph process {
    rankdir=TB;
    subgraph cluster_per_task {
        label="Per Task";
        impl [label="Dispatch implementer\n(./implementer-prompt.md)" shape=box];
        questions [label="Questions?" shape=diamond];
        answer [label="Answer, provide context" shape=box];
        work [label="Implement, test, commit" shape=box];
        spec [label="Spec reviewer\n(./spec-reviewer-prompt.md)" shape=box];
        spec_ok [label="Spec compliant?" shape=diamond];
        spec_fix [label="Fix spec gaps" shape=box];
        quality [label="Quality reviewer\n(./code-quality-reviewer-prompt.md)" shape=box];
        qual_ok [label="Quality approved?" shape=diamond];
        qual_fix [label="Fix quality issues" shape=box];
        done [label="Mark task complete" shape=box];
    }
    start [label="Read plan.md + manifest.json\nNote task IDs and waves" shape=box];
    more [label="More tasks?" shape=diamond];
    final [label="Final code review" shape=box];
    cleanup [label="Cleanup plan directory" shape=box];
    finish [label="git-workflow stack" shape=box style=filled fillcolor=lightgreen];

    start -> impl;
    impl -> questions;
    questions -> answer [label="yes"];
    answer -> impl;
    questions -> work [label="no"];
    work -> spec;
    spec -> spec_ok;
    spec_ok -> spec_fix [label="no"];
    spec_fix -> spec [label="re-review"];
    spec_ok -> quality [label="yes"];
    quality -> qual_ok;
    qual_ok -> qual_fix [label="no"];
    qual_fix -> quality [label="re-review"];
    qual_ok -> done [label="yes"];
    done -> more;
    more -> impl [label="yes"];
    more -> final [label="no"];
    final -> cleanup;
    cleanup -> finish;
}
```

## Dispatching Agents

For each task, dispatch the implementer with:
- A 2-3 sentence summary (from the orchestration plan's task table)
- The briefing file path: `.claude/plans/<plan-id>/briefings/task-NN.md`
- The agent reads the full specification from its briefing file

See prompt templates for exact dispatch format.

## At Wave Boundaries

Re-read `manifest.json` from disk to recover task state if context has been compacted. Update task statuses in the manifest as tasks complete.
