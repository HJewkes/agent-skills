# Debugging Principles Reference

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed root cause investigation, you cannot propose fixes. Symptom fixes are failure.

## Four-Phase Process

| Phase | Key Activities | Gate |
|-------|---------------|------|
| **1. Root Cause** | Read errors completely, reproduce consistently, check recent changes, gather evidence | Understand WHAT and WHY before proceeding |
| **2. Pattern** | Find working examples, compare against references, identify every difference | Know what's different between working and broken |
| **3. Hypothesis** | Form single specific theory, test with smallest possible change, one variable at a time | Confirmed or form new hypothesis — don't stack fixes |
| **4. Implementation** | Create failing test, implement single fix, verify | Bug resolved, all tests pass |

## Multi-Component Diagnostic Instrumentation

For systems with multiple components (CI -> build -> signing, API -> service -> database), gather evidence showing WHERE the chain breaks before proposing fixes:

```bash
# Check each boundary layer sequentially — find where it first fails
diagnose layers "echo IDENTITY: ${IDENTITY:+SET}" "env | grep IDENTITY" "security list-keychains" "codesign --sign ..."
```

## Root Cause Tracing (Backward Through Call Stack)

When a bug manifests deep in execution:

1. **Observe symptom** — Note the error and location
2. **Find immediate cause** — What code directly triggers the error?
3. **Ask "what called this?"** — Trace one level up the call chain
4. **Keep tracing** — Follow the bad value upstream until you find its origin
5. **Fix at the source** — Not at the symptom point

Add instrumentation when manual tracing stalls:
```typescript
const stack = new Error().stack;
console.error('DEBUG git init:', { directory, cwd: process.cwd(), stack });
```

Use `find-polluter.sh` to bisect which test causes side effects:
```bash
./find-polluter.sh '.git' 'src/**/*.test.ts'
```

## Defense-in-Depth Validation (4-Layer Pattern)

After finding root cause, add validation at EVERY layer data passes through:

| Layer | Purpose | Example |
|-------|---------|---------|
| **1. Entry point** | Reject invalid input at API boundary | `if (!dir) throw new Error('dir required')` |
| **2. Business logic** | Ensure data makes sense for operation | Validate projectDir before workspace init |
| **3. Environment guard** | Prevent dangerous ops in specific contexts | Refuse `git init` outside tmpdir during tests |
| **4. Debug instrumentation** | Capture context for forensics | Stack trace + cwd logging before risky ops |

Single validation = "we fixed the bug." Four layers = "we made the bug impossible."

## Condition-Based Waiting (Replace Arbitrary Timeouts)

```typescript
// BAD: Guessing at timing
await new Promise(r => setTimeout(r, 50));

// GOOD: Wait for actual condition
await waitFor(() => getResult() !== undefined, 'result available');
```

| Scenario | Pattern |
|----------|---------|
| Wait for event | `waitFor(() => events.find(e => e.type === 'DONE'))` |
| Wait for state | `waitFor(() => machine.state === 'ready')` |
| Wait for file | `waitFor(() => fs.existsSync(path))` |

Arbitrary timeout is correct ONLY when testing actual timing behavior (debounce, tick intervals) — document WHY.

## Red Flags — STOP and Return to Phase 1

- "Quick fix for now, investigate later"
- "Just try changing X and see"
- Proposing solutions before tracing data flow
- "I see the problem, let me fix it" (seeing symptoms != root cause)
- "One more fix attempt" after 2+ failures
- Each fix reveals new problems in different places

## The 3+ Failed Fixes Gate

If 3+ fixes have failed, STOP. This signals an architectural problem, not a bug:
- Each fix reveals new shared state / coupling in different places
- Fixes require "massive refactoring" to implement
- Each fix creates new symptoms elsewhere

**Question the architecture. Discuss with your human partner before attempting more fixes.**

## Rationalization Counters

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms != understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question pattern, don't fix again. |
