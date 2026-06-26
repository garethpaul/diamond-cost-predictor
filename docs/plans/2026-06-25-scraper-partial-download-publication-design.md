# Scraper Partial Download Publication Design

## Problem

`read_lines` returns `[]` for both a valid empty response and transport,
response-origin, size, or UTF-8 failures. `collect_diamonds` therefore continues
after a failed page and `main` can atomically replace a prior complete output
with a partial dataset.

## Options

1. Return `None` for failed page acquisition and keep `[]` for a valid empty
   body. This is explicit, dependency-free, and preserves current success data.
2. Raise from `read_lines`. This is also fail-closed but removes the existing
   local diagnostic ownership and broadens exception handling at every caller.
3. Return a result object. This is clearer at scale but excessive for one
   internal caller.

## Decision

Use `None` as the failure sentinel. `collect_diamonds` raises `RuntimeError`
before processing or publication when any requested page fails. `main` already
collects all rows before `write_diamonds`, so existing output remains untouched.

## Validation

- Watch direct failure-result tests and a partial-download preservation test
  fail first.
- Keep valid empty bodies as `[]`.
- Verify all transport/trust/size/UTF-8 failures return `None`.
- Verify `collect_diamonds` aborts at the failed page and `main` never calls the
  atomic writer.
- Run the full Python 3.10/3.12/3.14 hosted matrix and CodeQL.
