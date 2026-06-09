---
title: Scraper Endpoint Validation
type: security
status: completed
date: 2026-06-09
---

# Scraper Endpoint Validation

## Summary

Harden PriceScope endpoint override handling so scraper tests and local runs
cannot silently accept malformed or credential-bearing URLs.

## Requirements

- R1. Parse endpoint overrides instead of checking only a string prefix.
- R2. Require HTTPS and a non-empty host before building scraper URLs.
- R3. Reject embedded username/password credentials.
- R4. Reject query strings and fragments because `build_url` appends the
  canonical scraper query itself.
- R5. Keep no-network scraper regression tests for the endpoint validation
  contract.
- R6. Update README, VISION, CHANGES, and the baseline guard.

## Verification

- `python3 scripts/test-psdownload.py`
- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
