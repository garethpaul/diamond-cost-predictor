# Issue 5 Urlopen Timeout

## Issue

`garethpaul/diamond-cost-predictor#5` reports that `psdownload.py` calls
`urlopen` without a timeout, which can leave the scraper waiting forever on a
stalled upstream service.

## Plan

- Replace the direct `urllib.urlopen(...).readlines()` call with a helper.
- Use `urllib2.urlopen(..., timeout=DOWNLOAD_TIMEOUT_SECONDS)` for a per-call
  timeout while preserving Python 2 compatibility.
- Catch timeout and URL errors, print a clear page-level failure message, and
  return an empty result for that page.
- Add a source-level baseline script that can run without Python 2 installed.

## Verification

- `scripts/check-baseline.sh`
- `rg -n "DOWNLOAD_TIMEOUT_SECONDS|urllib2.urlopen|socket.timeout|urllib2.URLError" psdownload.py scripts/check-baseline.sh`
- `git diff --check`
