# Atomic Prediction PDF Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Status:** Completed

**Goal:** Preserve an existing `prediction.pdf` unless a complete nonempty replacement report is successfully generated.

**Architecture:** Add a dependency-free same-directory staging context manager to `graph.py`. Route the R PDF device to the staged path, always close it in `finally`, validate the staged artifact, and atomically publish it with `os.replace` only after successful plotting.

**Tech Stack:** Python 3 standard library, rpy2/R call boundary, unittest, POSIX shell, GNU Make

---

### Task 1: Specify atomic publication behavior

**Files:**
- Modify: `scripts/test-model-input.py`
- Modify: `scripts/check-baseline.sh`

**Step 1: Write failing tests**

Add tests that require `staged_prediction_pdf` to replace a prior destination
on success, preserve it on exceptions, remove staged files, and reject empty
output. Require a destination symlink to be replaced without changing its
target.

**Step 2: Run tests to verify RED**

Run: `python3 scripts/test-model-input.py`

Expected: FAIL because `graph.py` does not define `staged_prediction_pdf`.

### Task 2: Implement staged PDF publication

**Files:**
- Modify: `graph.py`

**Step 1: Add the minimal context manager**

Use `tempfile.mkstemp` in the resolved destination directory, close the
descriptor, yield the staged path, reject a missing or empty artifact, and call
`os.replace` on successful exit. Always remove leftover staging files.

**Step 2: Route R output through the context**

Open the R PDF device on the staged path. Wrap every plot and legend operation
in `try/finally` so `dev.off()` is attempted before the context publishes.

**Step 3: Run focused tests to verify GREEN**

Run: `python3 scripts/test-model-input.py`

Expected: PASS.

### Task 3: Add hostile contracts and maintained guidance

**Files:**
- Create: `scripts/test-prediction-pdf-atomic-mutations.sh`
- Modify: `Makefile`
- Modify: `scripts/check-baseline.sh`
- Modify: `README.md`
- Modify: `VISION.md`
- Modify: `AGENTS.md`
- Modify: `CHANGES.md`
- Modify: `docs/plans/2026-06-25-atomic-prediction-pdf.md`

**Step 1: Add hostile mutations**

Reject removal of same-directory staging, nonempty validation, atomic replace,
cleanup, staged R-device routing, and guaranteed device close.

**Step 2: Synchronize documentation**

Document atomic model-output publication and remove the completed generic model
output priority while retaining R/rpy2 execution as an explicit verification
gap.

**Step 3: Run canonical verification**

Run: `make check`, external-directory `make check`, `python3 -m py_compile`,
and `git diff --check`.

Expected: PASS, with no R model or PDF execution claimed.

### Task 4: Review and hosted verification

**Files:**
- Modify: `docs/plans/2026-06-25-atomic-prediction-pdf.md`

**Step 1: Commit and open the pull request**

Push the focused branch and open a PR against `master`.

**Step 2: Run review**

Run: `codex review --base origin/master` and manually verify findings.

**Step 3: Record exact-head evidence**

Require hosted Check and CodeQL on the exact final SHA before marking the plan
completed and merging.

## Verification Results

- Four focused runtime tests passed for successful replacement, failure
  preservation and cleanup, empty-output rejection, and symlink-safe
  publication.
- All eight hostile atomic prediction PDF mutations were rejected across
  destination-symlink ownership, same-directory staging, nonempty validation,
  durable flush, atomic replace, cleanup, staged R-device routing, and
  guaranteed device closure.
- No R model or prediction PDF execution is claimed.
- Exact-head hosted Check and CodeQL passed.
