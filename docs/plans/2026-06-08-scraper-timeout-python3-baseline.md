---
title: Scraper Timeout And Python 3 Baseline
type: fix
status: completed
date: 2026-06-08
---

# Scraper Timeout And Python 3 Baseline

## Summary

Complete the first safe parsing pass by making the PriceScope downloader
timeout-aware, giving it explicit CLI arguments, ensuring every checked-in
Python script parses under Python 3, and ignoring generated scraper/model
outputs.

## Problem Frame

`psdownload.py` used Python 2 `urllib.urlopen` without a timeout, so a network
stall could hang the scraper indefinitely. `graph.py` and `lm.py` still used
Python 2 print/raw_input syntax, which prevented a repository-wide Python 3
syntax check. Generated `diamonds.txt` and `prediction.pdf` outputs were not
ignored.

## Requirements

- R1. Network downloads must set a timeout.
- R2. Scraper inputs and output path must be explicit command-line arguments.
- R3. Scraper helper behavior must be covered without making network calls.
- R4. PriceScope requests must default to HTTPS and reject plain-HTTP endpoint
  overrides.
- R5. All checked-in Python scripts must compile under Python 3.
- R6. Generated scraper/model outputs must be ignored.
- R7. README, changelog, and guard script must document and verify the broader
  source baseline.

## Implementation Units

### U1. Timeout-Aware Scraper

- **Goal:** Keep the legacy query flow but avoid unbounded network waits.
- **Files:** `psdownload.py`
- **Verification:** `scripts/check-baseline.sh`

### U2. HTTPS Endpoint Guard

- **Goal:** Avoid plain-HTTP PriceScope requests and reject insecure endpoint
  overrides.
- **Files:** `psdownload.py`, `scripts/test-psdownload.py`,
  `scripts/check-baseline.sh`
- **Verification:** `python3 scripts/test-psdownload.py`

### U3. Python 3 Syntax Baseline

- **Goal:** Ensure parser, scraper, and modeling scripts parse on the available
  Python runtime.
- **Files:** `csv.py`, `psdownload.py`, `graph.py`, `lm.py`
- **Verification:** `python3 -m py_compile ...`

### U4. Scraper Regression Tests

- **Goal:** Verify URL encoding, total parsing, CLI defaults, page-level URL
  failure handling, and output writing without live network access.
- **Files:** `scripts/test-psdownload.py`, `scripts/check-baseline.sh`
- **Verification:** `python3 scripts/test-psdownload.py`

### U5. Generated Output Hygiene

- **Goal:** Keep local scraper/model outputs out of source control.
- **Files:** `.gitignore`
- **Verification:** `scripts/check-baseline.sh`

### U6. Documentation And Guard

- **Goal:** Make the baseline repeatable for future data/model changes.
- **Files:** `README.md`, `CHANGES.md`, `scripts/check-baseline.sh`, this plan
- **Verification:** `scripts/check-baseline.sh`, `git diff --check`

## Risks & Dependencies

- The R/rpy2 model execution path still requires a compatible local R and rpy2
  environment.
- This pass does not redownload data or regenerate checked-in CSV artifacts.
- The scraper still depends on legacy PriceScope HTML structure and should be
  reviewed against current data-source terms before live use.
