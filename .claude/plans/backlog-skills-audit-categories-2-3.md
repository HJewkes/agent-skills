# Backlog: Skills Audit — Categories 2 & 3

## Category 2: Multi-Workflow Context Surfacing

**Question**: Should skills with multiple workflows/modes use a CLI to surface context on-demand vs reference files?

**Current state**: Most multi-workflow skills use reference files (tier 3 progressive disclosure). The LLM reads the main SKILL.md, decides which workflow applies, then reads the relevant reference file.

**Hypothesis**: A CLI (`skill-name mode-name`) that outputs targeted context is functionally equivalent to reading a reference file — both cost one tool call, both inject similar tokens. The CLI has marginal ergonomic benefits (discoverability via `--help`, consistent interface) but adds maintenance overhead.

**Key insight**: The real value appears when a Category 2 skill contains Category 1 operations hiding inside its workflows. In those cases, the CLI can both surface context AND execute deterministic steps, which reference files can't do. The audit should check each multi-workflow skill for embedded Category 1 patterns before deciding the delivery mechanism.

**Skills to evaluate**:
- code-review (4 review modes with dispatch logic)
- systematic-debugging (4 phases with different activities)
- skills-management (7+ reference files for different lifecycle operations)
- git-workflow (multiple operations: status, commit, split, stack, worktree, clean)
- coordinator (multiple coordination modes)

**Next step**: After Category 1 audit is complete, revisit these skills and assess whether their workflows contain deterministic operations that would tip the balance toward CLI.

---

## Category 3: Linear Steps with Compaction Resilience

**Question**: Should skills with fixed linear steps (requiring human dialog at each) use a CLI to gate progression and externalize state?

**Current state**: Skills like brainstorming, executing-plans, and writing-plans describe all steps in the SKILL.md body. The LLM follows them linearly with human interaction at each step.

**Hypothesis**: A CLI that gates progression (`skill next --output phase3.md`) would force the LLM to externalize state before advancing, protecting against context compaction losing critical step details. But it adds ceremony and tool calls to every transition.

**Trade-offs**:
- Pro: Compaction resilience — subsequent steps loaded fresh when needed
- Pro: Forces structured output between phases (useful for handoffs)
- Con: Extra tool call per transition
- Con: Added complexity for what is currently a simple markdown checklist
- Con: Speculative — depends on how often compaction actually causes problems

**Skills to evaluate**:
- brainstorming (6-step checklist)
- executing-plans (5-step process)
- writing-plans (multi-phase planning)
- finishing-a-development-branch (structured completion flow)

**Next step**: Monitor compaction issues in practice. If they become a recurring problem in long sessions, prototype the gated CLI approach on one skill (executing-plans is the best candidate) and evaluate.
