---
title: Issue 1 HTTPS PriceScope Endpoint
type: fix
status: active
date: 2026-06-08
origin: https://github.com/garethpaul/diamond-cost-predictor/issues/1
execution: code
---

# Issue 1 HTTPS PriceScope Endpoint

## Summary

Move the diamond scraper's PriceScope AJAX request off plain HTTP so runtime scraping traffic is not sent over cleartext transport.

## Problem Frame

Issue #1 was filed from the public repository review because `psdownload.py` downloads search results from `http://www.pricescope.com/results/ajax/?`. The repository is Python 2-era code, and this workspace does not provide Python 2, so the fix should remain a source-reviewable endpoint scheme change.

## Requirements

- R1. `psdownload.py` must not contain `http://www.pricescope.com/results/ajax/?`.
- R2. The request path, query parameters, pagination behavior, and parsing flow must remain unchanged.
- R3. The change must avoid Python 2-to-3 migration, scraper behavior changes, dependency changes, or output format changes.
- R4. The PR must reference `https://github.com/garethpaul/diamond-cost-predictor/issues/1`.

## Implementation Unit

### U1. HTTPS Scraper Endpoint

- **Goal:** Replace the cleartext PriceScope endpoint literal with its HTTPS equivalent.
- **Files:** `psdownload.py`
- **Test Scenarios:** Verify no cleartext PriceScope endpoint remains and the HTTPS endpoint responds over TLS.
- **Verification:** `rg -n "http://www\\.pricescope\\.com/results/ajax|https://www\\.pricescope\\.com/results/ajax" psdownload.py` and `git diff --check`.

## Risks

- `python2` is unavailable in this workspace, so runtime and syntax verification for the legacy script cannot be run locally.
- PriceScope currently serves a Cloudflare challenge to this workspace over HTTPS; that is separate from the cleartext transport issue.
