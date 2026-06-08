---
title: Safe Diamond Parsing Baseline
type: fix
status: completed
date: 2026-06-08
---

# Safe Diamond Parsing Baseline

## Summary

Replace the `eval`-based diamond record parser with a structured literal parser,
add focused parser tests, and document a repeatable source-level verification
gate for the legacy Python data-science sample.

## Problem Frame

`csv.py` reads scraped diamond records from `diamonds.txt` and executed each
line with `eval`. That allows arbitrary code execution if scraped or local input
is malformed or hostile. The script also executed its parsing logic at import
time, which made it hard to test without a real `diamonds.txt` file.

## Requirements

- R1. Scraped diamond records must not be parsed with `eval`.
- R2. The parser must reject non-dictionary, missing-field, and unknown-code
  records with clear `ValueError` failures.
- R3. `csv.py` must expose testable parsing and formatting functions while
  retaining command-line behavior.
- R4. A no-dependency verification command must compile and test the safe parser.
- R5. README and the plan must document the safe parsing baseline.

## Implementation Units

### U1. Structured Parser

- **Goal:** Preserve current CSV output shape without executing input records.
- **Files:** `csv.py`
- **Verification:** `python3 scripts/test-safe-parsing.py`

### U2. Parser Regression Tests

- **Goal:** Lock in supported parsing, malicious-input rejection, missing-field
  rejection, and unknown-code rejection.
- **Files:** `scripts/test-safe-parsing.py`
- **Verification:** `scripts/check-baseline.sh`

### U3. Baseline Guard And Docs

- **Goal:** Make the parser safety contract repeatable for future changes.
- **Files:** `scripts/check-baseline.sh`, `README.md`, this plan
- **Verification:** `scripts/check-baseline.sh`, `git diff --check`

## Risks & Dependencies

- This pass does not port the R/rpy2 modeling scripts from Python 2 syntax.
- The scraper and model still need dedicated passes for network timeouts,
  source provenance, and reproducible runtime dependencies.
- The project still expects `diamonds.txt` for the parser command-line path.
