---
title: PriceScope HTTPS Baseline
type: fix
status: completed
date: 2026-06-08
---

# PriceScope HTTPS Baseline

## Summary

Finish the downloader hardening by requiring HTTPS for PriceScope requests,
allowing only HTTPS endpoint overrides, and making timeout or URL failures
page-local instead of crashing or hanging the scraper.

## Problem Frame

The Python 3 scraper baseline added explicit CLI arguments and request
timeouts, but the generated URL still used the legacy plain-HTTP PriceScope AJAX
endpoint. The downloader also needed an explicit source guard so future changes
do not silently reintroduce cleartext transport.

## Requirements

- R1. `psdownload.py` must default to the HTTPS PriceScope AJAX endpoint.
- R2. `--endpoint` and `PRICESCOPE_AJAX_URL` overrides must reject non-HTTPS
  values.
- R3. Downloader request URLs must keep query-string construction centralized
  through `urlencode`.
- R4. Timeout and URL failures must be handled at page scope and return an empty
  page result.
- R5. README and `scripts/check-baseline.sh` must document and enforce the HTTPS
  downloader contract.

## Implementation Units

### U1. HTTPS Endpoint Selection

- **Goal:** Centralize endpoint selection and reject cleartext overrides.
- **Files:** `psdownload.py`
- **Verification:** `scripts/check-baseline.sh`

### U2. Page-Level Network Failure Handling

- **Goal:** Keep one failed page from crashing the whole bounded scrape.
- **Files:** `psdownload.py`, `scripts/test-psdownload.py`
- **Verification:** `python3 scripts/test-psdownload.py`,
  `scripts/check-baseline.sh`

### U3. Guard And Documentation

- **Goal:** Make HTTPS and timeout assumptions visible and repeatable.
- **Files:** `README.md`, `CHANGES.md`, `scripts/check-baseline.sh`, this plan
- **Verification:** `scripts/check-baseline.sh`, `git diff --check`

## Risks & Dependencies

- This pass does not perform a live scrape or validate current PriceScope HTML
  structure.
- The scraper remains dependent on PriceScope availability and any applicable
  data-source terms.
