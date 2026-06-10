---
title: Scraper Response Limit
type: security
status: completed
date: 2026-06-10
---

# Scraper Response Limit

## Summary

Prevent a remote PriceScope or test endpoint from making the scraper read an
unbounded page response into memory.

## Work Completed

- Added a 2 MiB per-page response limit.
- Reads one byte beyond the limit so oversized responses are detected before
  UTF-8 decoding or line splitting.
- Returns the existing empty page result for oversized responses, preserving
  page-level failure isolation.
- Added offline fake-response tests for normal UTF-8 lines, the exact read
  bound, and oversized payload rejection.
- Rooted Make verification to the repository and pinned CI to Ubuntu 24.04.
- Extended the source baseline and project documentation with the response
  memory boundary.

## Verification

- `python3 scripts/test-psdownload.py`
- `make check`
- `make -f /absolute/path/to/Makefile check`
- Mutation checks for removed byte cap, missing oversize test, floating runner,
  unrooted Make targets, and incomplete plan status
- `sh -n scripts/check-baseline.sh`
- `git diff --check`

All scraper tests use fake or failing network functions. No live PriceScope
request was made during this maintenance pass.
