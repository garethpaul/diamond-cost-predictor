---
title: Diamond Model Input Row Validation
type: reliability
status: planned
date: 2026-06-13
---

# Diamond Model Input Row Validation

## Status: Planned

## Problem Frame

`graph.py` reads generated `output.csv` rows with `str.split()` and immediately
indexes six columns. A truncated row raises an uncontextualized `IndexError`,
while a non-finite value such as `nan` is accepted for an R model vector despite
the producer's finite-positive numeric contract.

## Scope Boundaries

- Preserve the ten-column `csv.py` output format, regression formula, optional
  purchased-diamond arguments, PDF output, and printed model summary.
- Validate model input before loading or invoking `rpy2`.
- Do not change scraper behavior, PriceScope requests, R formulas, dependencies,
  generated files, or command-line compatibility.
- Do not claim R model or PDF execution because `rpy2` and R are unavailable on
  this host.

## Requirements

- R1. Every nonempty model input file must contain at least one row.
- R2. Every row must contain exactly ten comma-separated fields.
- R3. Carat and price must be finite and positive; color, clarity, symmetry, and
  polish must be positive integers.
- R4. Validation failures must identify the input path and one-based line number.
- R5. `graph.py` must load validated rows before importing `rpy2` or building R
  vectors.
- R6. Dependency-free tests must cover valid input, truncation, extra fields,
  non-finite values, non-positive values, non-integers, blank rows, and an empty
  file.
- R7. The deterministic checker and maintenance docs must preserve this boundary
  and the completed verification record.

## Implementation

1. Add a dependency-free model-row parser and file loader.
2. Refactor `graph.py` into a `main()` flow that validates `output.csv` before
   importing `rpy2`, then builds the same vectors and regression.
3. Add offline unit tests and include them in the Make and static gates.
4. Update README, vision, changelog, and this plan without adding dependencies.

## Verification

- Focused model-input tests
- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- External-working-directory `make check`
- Python 3.12 and 3.14 where available
- `sh -n scripts/check-baseline.sh`
- `git diff --check`
- Isolated hostile mutations for missing field-count validation, finite checks,
  positivity checks, line-number context, graph integration, stale status, and
  missing verification evidence must each fail the checker.
