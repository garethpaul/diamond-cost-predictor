---
title: Numeric Field Validation
type: fix
status: completed
date: 2026-06-08
---

# Numeric Field Validation

## Summary

Tighten diamond record parsing so numeric model inputs reject non-finite and
non-positive values before they enter generated CSV output.

## Requirements

- R1. Carat, depth, and table fields must parse as finite positive numbers.
- R2. Price must parse as a positive integer.
- R3. Parser regression tests must cover non-finite numeric values and
  non-positive prices.
- R4. README, CHANGES, and the source guard must document and preserve the
  validation baseline.

## Verification

- `python3 scripts/test-safe-parsing.py`
- `scripts/check-baseline.sh`
- `git diff --check`
