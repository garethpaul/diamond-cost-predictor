# Scraper Marker-Pair Validation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Prevent structurally truncated PriceScope pages from publishing incomplete scraper output.

**Architecture:** Validate `diamond-data` marker pairs inside the existing line parser. Reject blank paired records and page-ending orphan markers with one stable collection error, preserving the existing collect-before-atomic-write publication boundary.

**Tech Stack:** Python 3 standard library, unittest mocks, GNU Make.

---

**Status:** Completed

### Task 1: Add failing structural regressions

**Files:**
- Modify: `scripts/test-psdownload.py`

1. Return a page ending with `diamond-data` and require collection failure.
2. Return `diamond-data` followed by a blank line and require the same failure.
3. Run the focused tests and confirm current collection accepts both pages.

### Task 2: Validate marker pairs

**Files:**
- Modify: `psdownload.py`

1. Strip the line paired with a marker.
2. Reject a blank paired record before appending it.
3. Reject a marker still pending after the page loop.
4. Rerun focused and full scraper tests.

### Task 3: Preserve maintained contracts

**Files:**
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `SECURITY.md`
- Modify: `VISION.md`
- Modify: `CHANGES.md`
- Modify: `scripts/check-baseline.sh`
- Modify: `docs/plans/2026-06-26-scraper-marker-pair-validation.md`

1. Document malformed marker-pair rejection and output preservation.
2. Add durable source, test, plan, and documentation contracts.
3. Mutation-test the blank-record and orphan-marker guards.
4. Run root/external `make check`, compilation, syntax, and diff checks.
5. Merge only the exact hosted-green reviewed head.

## Verification Results

- Red: both the page-ending marker and blank paired record were accepted without raising.
- Green: the focused regression and all 36 scraper tests pass on Python 3.11.8.
- Removing either the blank-record guard or the orphan-marker guard makes the focused regression fail with `RuntimeError not raised`.
- Repository-root and external-directory `make check` pass across safe parsing,
  scraper, model-input, prediction-PDF atomic/mutation, and compilation gates.
- `/bin/sh -n scripts/*.sh`, Python compilation, and `git diff --check` pass.
- Hosted Python matrix, CodeQL, and exact-head review remain required before merge.
