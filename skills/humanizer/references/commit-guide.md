# Commit Message Guide

## Structure
- Subject line: imperative mood, under 72 characters
- Blank line between subject and body
- Body (if needed): explains WHY, not WHAT — the diff shows what changed

## Subject line
- "Add feature" not "Added feature" or "Adding feature"
- "Fix crash when X" not "Fixed a bug that caused crashes"
- Start with a verb: Add, Fix, Remove, Update, Refactor, Extract
- No period at the end

## Anti-patterns
- No "This commit..." openers — redundant
- No prose summaries of the diff in the body
- No "Additionally" or "Furthermore" in bodies
- No bullet lists restating each changed file
- No marketing language ("Enhance user experience by optimizing...")
- No explanation of implementation details that belong in code comments

## Length
- Subject: 50 chars ideal, 72 max
- Body: 0-3 sentences for most commits
- If the body is longer than 5 lines, the commit is probably too large
