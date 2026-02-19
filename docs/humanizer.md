# Humanizer

Clean AI-generated text — normalize characters and flag overused phrases.

## Install

```bash
npx skills add hjewkes/agent-skills --skill='humanizer'
```

## Prerequisites

- Bash 4+
- `python3` (optional — enables full Unicode normalization; falls back to basic replacement without it)

## Usage

```bash
echo "Let's delve into the robust — and comprehensive — solution." | humanize
humanize README.md
humanize --report doc.md    # Verbose output with replacement counts
humanize --help
```

## What It Fixes Automatically

- Em dashes to space-hyphen-space
- Smart quotes to straight quotes
- Unicode ellipsis to three periods
- Non-breaking and invisible spaces to regular spaces
- Invisible Unicode watermark characters removed
- Bullet characters to ASCII hyphens

## What Gets Flagged

The script flags phrases that need human judgment to rewrite:

- **Red-flag words:** delve, tapestry, seamless, robust, comprehensive, etc.
- **Hedging filler:** "it's important to note", "it's worth noting"
- **Cliche openers/closers:** "I hope this finds you well", "feel free to reach out"
- **Overused transitions:** furthermore, moreover, additionally

Full pattern list: `skills/humanizer/references/phrases.txt`

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Clean — no issues found |
| 1 | Error |
| 2 | Phrase flags found (text still cleaned) |
