# TDD Principles Reference

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? Delete it. Start over. Don't keep it as "reference". Don't "adapt" it. Delete means delete.

## Red-Green-Refactor Cycle

| Phase | Action | Gate |
|-------|--------|------|
| **RED** | Write one minimal failing test | Verify it fails for the RIGHT reason (feature missing, not typo) |
| **GREEN** | Write simplest code to pass | Verify it passes AND all other tests still pass |
| **REFACTOR** | Clean up (extract, rename, deduplicate) | Tests stay green. No new behavior added |
| **Repeat** | Next failing test for next behavior | - |

### Good vs Bad Examples

| Quality | Good | Bad |
|---------|------|-----|
| **Test name** | `'retries failed operations 3 times'` | `'retry works'` / `'test1'` |
| **Assertions** | Test real behavior with real code | Assert on mock elements (`*-mock` test IDs) |
| **Minimal code** | Just enough to pass the current test | Over-engineered with options/config nobody asked for |
| **Scope** | One behavior per test. "and" in name? Split it. | `'validates email and domain and whitespace'` |

## Five Testing Anti-Patterns

| Anti-Pattern | What Goes Wrong | Fix |
|--------------|----------------|-----|
| **Mock behavior testing** | Asserting mocks exist, not that code works | Test real component or unmock it |
| **Test-only methods in production** | `destroy()` only called in tests pollutes API | Move to test utilities |
| **Mocking without understanding** | Mock removes side effect the test depends on | Understand dependency chain first, mock minimally |
| **Incomplete mocks** | Partial mock hides structural assumptions; downstream breaks | Mirror real API response completely |
| **Integration tests as afterthought** | "Implementation complete" with no tests | TDD: test is part of implementation |

## Rationalization Counters

| Excuse | Technical Reality |
|--------|-------------------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing — might test wrong thing, implementation not behavior. |
| "Tests after achieve same goals" | Tests-after = "what does this do?" Tests-first = "what should this do?" Tests-after are biased by implementation. |
| "Already manually tested" | Ad-hoc, no record, can't re-run. Manual doesn't prove edge cases. |
| "Deleting X hours is wasteful" | Sunk cost fallacy. Keeping unverified code is technical debt. |
| "Keep as reference, write tests first" | You'll adapt it. That's testing after. Delete means delete. |
| "Need to explore first" | Fine. Throw away exploration entirely, then start with TDD. |
| "Test hard = skip it" | Hard to test = hard to use. Listen to the test — simplify the design. |
| "TDD will slow me down" | TDD is faster than debugging. "Pragmatic" shortcuts = debugging in production. |
| "Existing code has no tests" | You're improving it. Add tests for the code you touch. |

## When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write the wished-for API. Write assertion first. Ask your human partner. |
| Test too complicated | Design too complicated. Simplify the interface. |
| Must mock everything | Code too coupled. Use dependency injection. |
| Test setup huge | Extract helpers. Still complex? Simplify the design. |
| Mock setup > 50% of test | Consider integration tests with real components instead. |
