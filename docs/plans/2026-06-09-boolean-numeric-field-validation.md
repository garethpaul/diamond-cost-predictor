# Boolean Numeric Field Validation

Status: Completed
Date: 2026-06-09

## Goal

Prevent Python boolean literals from being accepted as numeric diamond model
fields after safe literal parsing.

## Changes

- Rejected boolean values in both numeric text parsing and positive integer
  parsing.
- Added parser tests for boolean carat values and boolean integer fields.
- Extended the source baseline to require the boolean guards, tests, README
  note, vision note, and completed plan.
- Documented the guard in the README, changelog, and vision.

## Verification

- `scripts/check-baseline.sh`
- `python3 scripts/test-safe-parsing.py`
- `python3 scripts/test-psdownload.py`
- `make check`
- `git diff --check`
