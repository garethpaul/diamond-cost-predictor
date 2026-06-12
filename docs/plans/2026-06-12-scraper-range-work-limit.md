---
title: Scraper Range Work Limit
type: reliability
status: completed
date: 2026-06-12
---

# Scraper Range Work Limit

## Summary

Bound each PriceScope scrape invocation to a narrow carat span and reject
floating-point ranges whose step cannot advance. This prevents finite but
extreme arguments from creating effectively unbounded or duplicate request
loops.

## Problem Frame

The scraper validates that carat arguments are finite, positive, and ordered,
but it does not limit their distance. Its `drange` helper also repeatedly adds
a small floating-point step; at sufficiently large magnitudes that addition can
produce the same value and never terminate. Both cases occur before any useful
modeling work and can consume excessive network or CPU time.

## Requirements

- R1. A scrape invocation must reject carat spans greater than `0.5` before
  making network requests.
- R2. The existing documented `0.25` to `0.30` sample range must remain valid.
- R3. `drange` must reject non-finite or non-positive steps.
- R4. `drange` must raise a clear `ValueError` if adding the step does not
  advance the current value.
- R5. CLI parsing and direct `collect_diamonds` calls must share the same work
  limit.
- R6. No-network tests, the static baseline, README, VISION, and CHANGES must
  preserve the bounded-range contract.

## Non-Goals

- Changing PriceScope query fields, pagination, or response parsing.
- Performing a live scrape.
- Estimating completion time or adding parallel downloads.
- Changing diamond-record parsing or model formulas.

## Work Completed

- Added a shared `MAX_CARAT_SPAN` validation used by CLI parsing and direct
  collection calls.
- Hardened `drange` against invalid and non-advancing floating-point steps.
- Added no-network tests for the accepted boundary, excessive spans, invalid
  steps, and large-magnitude no-progress ranges.
- Extended the source baseline and project documentation with the bounded-work
  contract.

## Verification

- `python3 scripts/test-psdownload.py`
- `make check`
- Python 3.10, 3.12, and 3.14 test/build matrix where locally available.
- Mutation check: removing the carat-span rejection must fail tests.
- Mutation check: removing no-progress detection must fail tests.
- `sh -n scripts/check-baseline.sh`
- `git diff --check`
