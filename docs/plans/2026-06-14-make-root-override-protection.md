---
title: Make Repository Root Override Protection
type: reliability
status: completed
date: 2026-06-14
---

# Make Repository Root Override Protection

## Status: Completed

## Problem Frame

The Makefile derives an absolute repository path in `ROOT`, but a command-line
assignment such as `make ROOT=/tmp check` overrides that value. The verification
targets then execute tools outside the checkout instead of the repository's
tracked gates.

## Scope Boundaries

- Preserve the existing `lint`, `test`, `build`, `verify`, and `check` behavior.
- Preserve `PYTHON` as an intentional caller-selected interpreter override.
- Do not change parser, scraper, model, generated-output, or dependency behavior.
- Keep repository commands independent of the caller's working directory.

## Requirements

- R1. Derive the repository root from the loaded Makefile itself.
- R2. Command-line and environment assignments must not redirect that root.
- R3. The deterministic checker must enforce the protected assignment form.
- R4. The full gate must pass from both repository and external directories.
- R5. Isolated mutations that restore an overridable root or remove its static
  contract must fail verification.

## Implementation

1. Protect the Makefile's repository-root assignment from caller overrides.
2. Add a static contract for the protected assignment to the baseline checker.
3. Run focused, full, external-directory, and hostile-override validation.

## Verification

- `sh -n scripts/check-baseline.sh`
- `make lint`
- `make check`
- External-working-directory `make -C <repository> check`
- Hostile command-line and environment `ROOT` assignments
- `git diff --check`
- Isolated hostile mutations for root override protection and static coverage

## Work Completed

- Protected the repository-root assignment with GNU Make's `override` directive
  while preserving `PYTHON` as a caller-selected interpreter.
- Registered the plan and exact protected assignment in the deterministic
  baseline checker.
- Preserved every existing verification target and repository-relative command.

## Verification Completed

- `sh -n scripts/check-baseline.sh` passed.
- `make lint` and `make check` passed on Python 3.12.8 and Python 3.14.0.
- External-working-directory `make -C <repository> lint` and `make -C
  <repository> check` passed.
- Full checks passed with both command-line and environment `ROOT=/tmp`
  assignments, and every command still resolved inside the repository.
- Three isolated hostile mutations were rejected: a regular assignment, a
  conditional assignment, and a caller-working-directory assignment.
