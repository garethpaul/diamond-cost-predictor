---
title: Diamond Cost Predictor Check Wrapper
type: chore
status: completed
date: 2026-06-08
---

# Diamond Cost Predictor Check Wrapper

## Summary

Add a repository-standard `make check` entry point that runs the existing
safe-parsing baseline and the focused Python parser/scraper regression tests.

## Requirements

- R1. `make check` must run the safe parsing baseline and focused Python test
  scripts from the repository root.
- R2. The Makefile must expose `lint`, `test`, `verify`, and `check` targets
  without introducing external Python package dependencies.
- R3. README, CHANGES, and baseline checks must document and preserve the root
  check wrapper.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
