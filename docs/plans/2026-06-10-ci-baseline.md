# CI Baseline

status: completed

## Context

The repository had a local Python `make check` baseline for safe diamond
parsing and scraper helper validation, but no hosted workflow ran it for pushes
and pull requests.

## Objectives

- Verify the standard-library code across maintained and newest Python lines.
- Pin third-party action code and keep repository access read-only.
- Avoid live network calls while exercising parser, endpoint, and output guards.

## Changes

- Added a GitHub Actions workflow that runs `make check` on Python 3.10, 3.12,
  and 3.14 for pushes, pull requests, and manual dispatches.
- Pinned checkout and Python setup actions to reviewed commits, limited
  repository access to read-only, and bounded execution with timeout and
  concurrency cancellation.
- Extended the baseline guard and documentation so the hosted CI path stays
  covered.

## Verification

- `make check`
- Python 3.10, 3.12, and 3.14 hosted jobs
- `git diff --check`
