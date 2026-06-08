---
title: Issue 1 HTTPS Pricescope Endpoint
type: fix
status: active
date: 2026-06-08
origin: https://github.com/garethpaul/diamond-cost-predictor/issues/1
execution: code
---

# Issue 1 HTTPS Pricescope Endpoint

## Summary

Move the diamond download script's runtime Pricescope request off plain HTTP so it no longer starts network traffic over cleartext transport.

## Problem Frame

Issue #1 was filed from the public repository review because `psdownload.py` calls `urllib.urlopen` with a `http://www.pricescope.com/results/ajax/` URL. The project is a legacy Python 2 script, so the fix should stay limited to the endpoint scheme instead of migrating Python syntax or restructuring request handling.

## Requirements

- R1. `psdownload.py` must not contain the runtime URL literal `http://www.pricescope.com/results/ajax/?`.
- R2. The replacement must use `https://www.pricescope.com/results/ajax/?`.
- R3. The change must avoid Python 2 to Python 3 migration, parser rewrites, output format changes, or unrelated data-processing changes.
- R4. The PR must reference `https://github.com/garethpaul/diamond-cost-predictor/issues/1`.

## Implementation Unit

### U1. HTTPS Runtime URL Literal

- **Goal:** Replace the reported plain-HTTP Pricescope endpoint with the HTTPS equivalent while preserving the existing query string and downloader control flow.
- **Files:** `psdownload.py`
- **Test Scenarios:** Verify the reported HTTP literal no longer exists, the HTTPS literal is present, and the remote host responds over TLS.
- **Verification:** `rg -n "http://www\\.pricescope\\.com/results/ajax|https://www\\.pricescope\\.com/results/ajax" psdownload.py`, `git diff --check`, and `curl -I --max-time 10 https://www.pricescope.com/results/ajax/?`.

## Risks

- This workspace does not provide Python 2, so the legacy script cannot be executed locally without changing runtime compatibility.
- Pricescope currently returns a Cloudflare challenge to this workspace over HTTPS, but the response proves TLS is available and removes the initial cleartext request.
