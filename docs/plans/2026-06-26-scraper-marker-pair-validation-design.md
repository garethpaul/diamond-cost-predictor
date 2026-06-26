# Scraper Marker-Pair Validation Design

## Problem

`collect_diamonds` treats every line after a `diamond-data` marker as a record.
If a successful HTTP response ends at the marker, the page is silently accepted
without that record. If the following line is blank, an empty record is added.
Either response can reach the atomic publisher and replace an existing dataset
with truncated or blank content.

## Approaches Considered

1. **Validate marker pairs at extraction time (selected).** Reject a marker at
   end-of-page and reject a blank paired line. This directly closes the proven
   structural truncation path while preserving current pagination and record
   conversion boundaries.
2. **Reconcile downloaded rows with reported totals.** This is broader, but the
   scraper deliberately retains bounded fallback behavior for missing or
   malformed totals, so total equality is not a reliable universal invariant.
3. **Parse every record with `csv.py` during acquisition.** This would detect
   more content errors but couples the network collector to downstream model
   conversion and changes when unsupported categories are filtered.

## Design

Keep the existing line-oriented parser. When `found_data_marker` is set, strip
the next line and raise a stable `RuntimeError` if it is blank; otherwise append
the record. After each page is consumed, raise the same error if the marker is
still pending. Collection already completes before `write_diamonds`, so any
such error preserves the existing output.

## Validation

- Test both orphaned and blank marker payloads before implementation.
- Preserve successful record extraction and valid empty responses.
- Mutation-test removal of each structural guard.
- Run repository and external-directory `make check` plus hosted Python and
  CodeQL checks before exact-head merge.
