# Output Helper Validation

Status: Completed
Date: 2026-06-09

## Goal

Keep direct `write_diamonds` calls from opening blank output paths while
preserving support for path-like objects.

## Changes

- Normalized output paths through `os.fspath` before blank-path validation.
- Reused `validate_output_path` inside `write_diamonds`.
- Added scraper tests for blank direct helper output paths while preserving the
  existing `pathlib.Path` write coverage.
- Extended the source baseline, README, changelog, and vision with the helper
  validation contract.

## Verification

- `sh -n scripts/check-baseline.sh`
- `scripts/check-baseline.sh`
- `python3 -m py_compile csv.py psdownload.py graph.py lm.py scripts/test-safe-parsing.py scripts/test-psdownload.py`
- `python3 scripts/test-safe-parsing.py`
- `python3 scripts/test-psdownload.py`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
