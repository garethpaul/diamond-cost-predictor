# Changelog

## 2026-06-08

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
