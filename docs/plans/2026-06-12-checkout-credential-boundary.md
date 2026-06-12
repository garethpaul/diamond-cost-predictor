# Checkout Credential Boundary

## Status: Completed

## Context

The Python verification matrix only needs repository contents. The checkout
credential should not remain in Git configuration while parser and scraper
tests run.

## Objectives

- Disable checkout credential persistence without changing Python coverage.
- Preserve immutable action pins, read-only permissions, and the Python
  3.10/3.12/3.14 matrix.
- Reject duplicate workflows, checkout steps, or boundary declarations.

## Work Completed

- Added `persist-credentials: false` to the pinned checkout step.
- Added exact static contracts for the sole workflow and checkout boundary.
- Updated CI and security documentation.

## Verification

- `make lint`
- `make test`
- `make build`
- `make verify`
- `make check`
- `git diff --check`
- Hostile workflow and plan mutations were rejected.

## Remaining Risk

Live scraping, R modeling, graph generation, and model accuracy remain outside
this workflow-only change.
