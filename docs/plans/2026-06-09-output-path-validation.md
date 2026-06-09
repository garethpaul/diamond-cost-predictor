---
title: Scraper Output Path Validation
type: reliability
status: completed
date: 2026-06-09
---

# Scraper Output Path Validation

## Summary

Reject blank PriceScope scraper output paths before any download loop begins.

## Requirements

- R1. `--output` must not be empty or whitespace-only.
- R2. Output validation must run during CLI argument parsing before scraping.
- R3. Scraper helper tests must cover blank output arguments.
- R4. README, VISION, CHANGES, and the baseline guard must document the output
  path validation.
- R5. The repository verification wrapper must expose a Python compile build
  target.

## Verification

- `python3 scripts/test-psdownload.py`
- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
