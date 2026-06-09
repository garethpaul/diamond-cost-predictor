---
title: Scraper Argument Validation
type: reliability
status: completed
date: 2026-06-09
---

# Scraper Argument Validation

## Summary

Reject invalid PriceScope scraper carat ranges and timeout values before any
download loop begins.

## Requirements

- R1. `min_carat` must be positive.
- R2. `max_carat` must be greater than `min_carat`.
- R3. `--timeout` must be positive.
- R4. Scraper helper tests must cover invalid range and timeout arguments.
- R5. Direct `collect_diamonds` calls must use the same validation as the CLI.
- R6. README and the source guard must document the argument validation.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `python3 scripts/test-psdownload.py`
- `git diff --check`
