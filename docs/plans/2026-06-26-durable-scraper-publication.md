# Durable Scraper Publication

**Status:** Pending hosted verification

## Goal

Make successful scraper output replacement durable across a subsequent power
loss by syncing the destination directory after the atomic rename.

## Problem

`write_diamonds` flushed and synced the staged file before `os.replace`, but it
did not sync the parent directory afterward. On POSIX filesystems, the new
directory entry can therefore remain outside durable storage even though the
function reports success.

## Implementation

- Add a small `fsync_directory` helper using a read-only directory descriptor.
- Call it only after `os.replace` succeeds.
- Close the directory descriptor in `finally` on both success and fsync failure.
- Preserve same-directory staging, prior-output protection before replacement,
  destination-symlink replacement behavior, and temporary-file cleanup.

## Verification

- `test_write_diamonds_fsyncs_destination_directory_after_replace` requires
  replace → directory open → destination-directory fsync → close ordering.
- `python3 scripts/test-psdownload.py`
- `make check`
- External-working-directory `make check`
- Hostile mutations for omitted and pre-replacement directory sync
- `git diff --check`

Exact-head hosted Python matrices and CodeQL remain pending.
