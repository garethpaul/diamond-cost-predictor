# Scraper Finite Argument Validation

Status: Completed
Date: 2026-06-09

## Goal

Reject NaN and infinite scraper arguments before PriceScope download loops can
start.

## Changes

- Added finite checks for `min_carat`, `max_carat`, and `timeout`.
- Added CLI and direct-helper regression coverage for non-finite values.
- Extended the source baseline, README, changelog, and vision with the finite
  scraper argument contract.

## Verification

- `scripts/check-baseline.sh`
- `python3 scripts/test-psdownload.py`
- `make check`
- `git diff --check`
