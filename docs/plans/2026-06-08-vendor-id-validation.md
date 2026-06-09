---
title: Vendor ID Validation
type: fix
status: completed
date: 2026-06-08
---

# Vendor ID Validation

## Summary

Validate scraped diamond `vendor_id` values with the existing positive-integer
helper before writing numeric model rows.

## Requirements

- R1. `vendor_id` remains a required scraped record field.
- R2. Zero or negative vendor IDs raise `ValueError`.
- R3. Valid vendor IDs continue to format as integers in CSV rows.
- R4. Parser tests and source baseline cover the invalid vendor ID case.
- R5. README and changelog document positive vendor ID validation.

## Verification

- `python3 scripts/test-safe-parsing.py`
- `python3 scripts/test-psdownload.py`
- `scripts/check-baseline.sh`
- `git diff --check`
