# Verification Principles Reference

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## 5-Step Gate Function

```
1. IDENTIFY — What command proves this claim?
2. RUN     — Execute the FULL command (fresh, complete)
3. READ    — Full output, check exit code, count failures
4. VERIFY  — Does output confirm the claim?
5. CLAIM   — ONLY THEN make the claim, WITH evidence
```

Skip any step = lying, not verifying.

## Red Flags (Unverified Language)

Stop immediately if you catch yourself using:
- "should", "probably", "seems to"
- "Great!", "Perfect!", "Done!" before running verification
- ANY wording implying success without having run verification
- About to commit/push/PR without fresh verification output

## Common Failures

| Claim | What's Required | What's NOT Sufficient |
|-------|----------------|----------------------|
| Tests pass | Test command output showing 0 failures | Previous run, "should pass" |
| Linter clean | Linter output showing 0 errors | Partial check, extrapolation |
| Build succeeds | Build command exit 0 | Linter passing, "logs look good" |
| Bug fixed | Test original symptom passes | Code changed, assumed fixed |
| Agent completed | VCS diff shows actual changes | Agent reports "success" |
| Requirements met | Line-by-line checklist verified | "Tests passing" alone |

## Verification Patterns

**Tests:**
```
RUN: [test command]  →  SEE: 34/34 pass  →  CLAIM: "All tests pass"
NEVER: "Should pass now" / "Looks correct"
```

**Regression (TDD Red-Green):**
```
Write test → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
NEVER: "I've written a regression test" without red-green verification
```

**Build:**
```
RUN: [build command]  →  SEE: exit 0  →  CLAIM: "Build passes"
NEVER: "Linter passed" (linter != compiler)
```

**Requirements:**
```
Re-read plan → Create checklist → Verify each item → Report gaps or completion
NEVER: "Tests pass, phase complete"
```

**Agent delegation:**
```
Agent reports success → Check VCS diff → Verify changes independently → Report actual state
NEVER: Trust agent report without independent verification
```

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification. |
| "I'm confident" | Confidence is not evidence. |
| "Just this once" | No exceptions. |
| "Linter passed" | Linter is not compiler. |
| "Agent said success" | Verify independently. |
| "I'm tired" | Exhaustion is not an excuse. |
| "Partial check is enough" | Partial proves nothing. |
| "Different words so rule doesn't apply" | Spirit over letter. |
