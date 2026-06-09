# Changelog

## 2026-06-09

- Rejected invalid scraper carat ranges and non-positive timeouts before
  starting PriceScope download loops.

## 2026-06-08

- Added a root `make check` wrapper for the safe parsing and scraper tests.
- Validated scraped vendor IDs as positive integers before writing model rows.
- Replaced `eval`-based diamond record parsing with `ast.literal_eval` and field validation.
- Added focused parser regression tests for valid records, malicious non-literal input, missing fields, and unknown codes.
- Added `scripts/check-baseline.sh` as the local safe-parsing verification gate.
- Added timeout-aware scraper downloads and explicit CLI arguments.
- Switched the PriceScope scraper default endpoint to HTTPS and rejected plain-HTTP overrides.
- Added no-network scraper helper regression tests.
- Updated the source guard to compile all Python scripts under Python 3.
- Ignored generated `diamonds.txt` and `prediction.pdf` outputs.
- Enforced HTTPS PriceScope downloader endpoints and added page-level URL error handling.
- Added parser validation for finite positive numeric fields and regression
  coverage for non-finite values and non-positive prices.
