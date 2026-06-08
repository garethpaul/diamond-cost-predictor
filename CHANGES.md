# Changelog

## 2026-06-08

- Replaced `eval`-based diamond record parsing with `ast.literal_eval` and field validation.
- Added focused parser regression tests for valid records, malicious non-literal input, missing fields, and unknown codes.
- Added `scripts/check-baseline.sh` as the local safe-parsing verification gate.
