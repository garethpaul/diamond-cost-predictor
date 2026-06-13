---
title: Scraper Strict Response UTF-8
type: data-integrity
status: completed
date: 2026-06-13
---

# Scraper Strict Response UTF-8

## Summary

Reject malformed UTF-8 page responses instead of silently inserting Unicode
replacement characters into scraped diamond records.

## Requirements

- Decode bounded page payloads with strict UTF-8.
- Treat a decode failure as an isolated page failure and return no lines.
- Emit a stable diagnostic that does not include response bytes.
- Preserve the 2 MiB response cap, timeout behavior, pagination, endpoint
  validation, output format, and public helper signatures.
- Add offline tests proving valid non-ASCII UTF-8 passes and malformed bytes
  are rejected without replacement characters.
- Update source contracts and maintenance documentation.

## Verification

Completed on 2026-06-13:

- `make check` passed on Python 3.12.8 and Python 3.14.0 with 12 parser tests,
  21 scraper tests, source contracts, and bytecode compilation.
- `make -f /absolute/path/to/Makefile check` passed from `/tmp`.
- Eleven hostile mutations were rejected across strict decoding, decode-error
  isolation, stable diagnostics, Unicode fixtures, response-byte redaction,
  documentation, and completed-plan evidence.
- `sh -n scripts/check-baseline.sh`, `git diff --check`, focused diff review,
  and a changed-line secret-pattern scan passed.
- Python 3.10 was unavailable locally and remains a hosted-CI requirement.
- All scraper tests used fake or failing network functions; no live PriceScope
  request was made.

## Non-Goals

- Making a live PriceScope request.
- Changing response size or timeout limits.
- Parsing or validating individual diamond records at download time.
- Changing R model inputs or generated CSV files.
