# Scraper Partial Download Publication Implementation Plan

**Status:** Completed

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Prevent failed page downloads from publishing a partial diamond dataset over existing output.

**Architecture:** Distinguish valid empty responses from failed acquisition with a `None` sentinel. Abort collection before the existing atomic writer runs, preserving the previous destination.

**Tech Stack:** Python 3 standard library, unittest, GNU Make

---

### Task 1: Add failing page-acquisition tests

**Files:**
- Modify: `scripts/test-psdownload.py`

1. Require transport, origin, size, and UTF-8 failures to return `None`.
2. Require a valid empty response to remain `[]`.
3. Require collection to raise on a failed requested page.
4. Require `main` to preserve an existing output when collection fails.
5. Run `python3 scripts/test-psdownload.py` and confirm RED.

### Task 2: Implement fail-closed collection

**Files:**
- Modify: `psdownload.py`

1. Return `None` from failed `read_lines` paths.
2. Raise a constant `RuntimeError` when a requested page returns `None`.
3. Run the focused tests to GREEN.

### Task 3: Synchronize verification and guidance

**Files:**
- Modify: `scripts/check-baseline.sh`
- Modify: `README.md`
- Modify: `CHANGES.md`
- Modify: `VISION.md`
- Modify: `AGENTS.md`
- Modify: this plan

1. Require the failure sentinel and abort-before-processing ordering.
2. Document that incomplete scrapes never replace existing output.
3. Run root/external `make check`, shell syntax, and diff checks.
4. Open a PR, require exact-head hosted matrices and CodeQL, review, and merge.

## Verification Results

- Direct failure-result tests and the collection regression failed before the
  implementation; collection raised an accidental `TypeError` on the sentinel.
- The focused scraper suite passes with failed acquisition returning `None`, a
  valid empty body returning `[]`, and collection raising a constant
  `RuntimeError` on any failed page download.
- Existing output remains unchanged because `main` completes collection before
  calling the atomic writer.
- All four isolated partial-publication mutations were rejected for URL-error,
  UTF-8, response-origin, and omitted collection-abort regressions.
- Repository-root and external-Makefile `make check`, shell syntax, and diff
  checks passed under the local Python runtime.
- Exact-head Check runs `28219912055` and `28219913116` passed Python 3.10,
  3.12, and 3.14.
- Exact-head CodeQL run `28219912547` passed Actions and Python analysis.
- Exact-head hosted Check and CodeQL passed.
