---
title: Scraper Response Origin Guard
type: security
status: planned
date: 2026-06-13
---

# Scraper Response Origin Guard

## Status: Planned

## Problem Frame

The scraper validates that its requested PriceScope endpoint uses HTTPS, but
Python's URL opener follows redirects and the final response URL is not checked.
A compromised or misconfigured endpoint could redirect downloads to plain HTTP
or another origin while the scraper continues parsing and publishing the body.

## Scope Boundaries

- Require the final response URL to remain HTTPS and on the same normalized
  host and port as the requested URL.
- Allow same-origin redirects, including path and query changes.
- Preserve timeout handling, the 2 MiB response cap, strict UTF-8 decoding,
  page parsing, argument validation, and atomic output publication.
- Do not perform live PriceScope requests in tests.

## Requirements

- R1. `read_lines` must inspect the final response URL before reading any body.
- R2. HTTP downgrade, cross-host, explicit-port drift, credential-bearing, or
  malformed final URLs must return no lines with a non-sensitive diagnostic.
- R3. Same-origin HTTPS redirects must remain accepted.
- R4. Tests and static contracts must prove validation occurs before
  `response.read` and retain completed verification evidence.

## Implementation

- Add an origin-normalization helper based on `urllib.parse.urlparse`.
- Validate `response.geturl()` against the requested URL before body reads.
- Add fake-response tests for same-origin acceptance and hostile redirect
  rejection without body access.
- Synchronize README, SECURITY, CHANGES, VISION, AGENTS, and this plan.

## Verification

- `python3 scripts/test-psdownload.py`
- `make check`
- Absolute-path Make invocation from `/tmp`
- Python 3.10, 3.12, and 3.14 validation when installed
- Python compilation, shell syntax, and `git diff --check`
- Isolated hostile mutations for scheme, host, port, credential, pre-read
  ordering, tests, documentation, stale plan status, and missing evidence

## Risks

- Origin comparison must normalize default HTTPS port `443` without allowing an
  arbitrary explicit port.
- Full network behavior remains dependent on urllib and PriceScope; local tests
  use deterministic fake responses and do not claim live endpoint validation.
