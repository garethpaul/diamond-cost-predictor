---
title: Scraper Atomic Output
type: fix
date: 2026-06-13
status: planned
---

# Scraper Atomic Output

## Summary

Write downloaded diamond records to a temporary file in the destination
directory and atomically replace the requested output only after every record
has been serialized and durably flushed.

## Problem Frame

`write_diamonds` opens the destination directly in write mode. That truncates a
previously valid dataset before record conversion and writes complete. A
failing `__str__`, disk error, interruption, or short write can therefore leave
the destination missing or partially updated even though the scrape did not
finish successfully.

## Requirements

- R1. Output must be staged in the destination directory so final replacement
  stays on the same filesystem.
- R2. The staged file must use UTF-8, preserve one-record-per-line output, flush
  Python buffers, and `fsync` before publication.
- R3. `os.replace` must publish the complete staged file atomically.
- R4. Any conversion, write, flush, sync, or replace failure must remove the
  temporary file and preserve an existing destination unchanged.
- R5. Successful replacement must leave no temporary output artifact.
- R6. Existing blank-path validation and CLI behavior must remain unchanged.
- R7. Offline tests and the static baseline must enforce success, failure
  preservation, cleanup, same-directory staging, durability, docs, and
  completed-plan evidence through `make check`.

## Key Technical Decisions

- **Use `tempfile.mkstemp`:** Create the staged file beside the destination with
  an identifiable hidden prefix and close it through `os.fdopen`.
- **Flush before replace:** Call `flush` and `os.fsync` while the staged file is
  open, then close it before `os.replace`.
- **Single cleanup owner:** Track the temporary path and unlink it in `finally`
  when publication has not consumed it.
- **Propagate failures:** Do not convert output failures into a successful empty
  dataset; callers should receive the original exception.

## Implementation Units

### U1. Stage And Atomically Publish Output

- **Files:** `psdownload.py`
- **Goal:** Replace direct truncating writes with same-directory temporary
  output, durable flush, atomic publication, and failure cleanup.
- **Covers:** R1, R2, R3, R4, R5, R6

### U2. Add Output Integrity Regressions

- **Files:** `scripts/test-psdownload.py`
- **Goal:** Prove successful replacement, unchanged prior output on conversion
  failure, exception propagation, and absence of temporary artifacts.
- **Covers:** R2, R3, R4, R5, R6, R7

### U3. Preserve Static And Documentation Contracts

- **Files:** `scripts/check-baseline.sh`, `README.md`, `CHANGES.md`, `VISION.md`,
  `AGENTS.md`
- **Goal:** Keep atomic-output source structure, tests, completed plan, and
  maintenance guidance enforced by repository gates.
- **Covers:** R7

## Verification

- Run `python scripts/test-psdownload.py`, `make check`, and the absolute-path
  `make check` wrapper from `/tmp` under available supported Python versions.
- Run shell syntax, Python compilation, whitespace, secret, and artifact checks.
- Apply isolated hostile mutations for direct destination writes, omitted
  `fsync`, non-atomic rename, wrong staging directory, swallowed conversion
  failures, missing preservation/cleanup fixtures, documentation drift, and
  incomplete plan status; each mutation must fail.
- Do not make live PriceScope requests or claim R-model execution.

## Prioritized Follow-Ups

1. Add bounded retry policy only for explicitly transient PriceScope failures.
2. Separate scraped record parsing from HTML line traversal with fixture-based
   parser tests before changing the upstream response contract.

## Risks

- Atomic replacement uses destination-directory permissions and may produce a
  new inode with default creation permissions; this matches the current new-file
  behavior and avoids partial publication.
- Directory metadata durability is not guaranteed without syncing the parent
  directory, which is outside this focused protection against partial files.
