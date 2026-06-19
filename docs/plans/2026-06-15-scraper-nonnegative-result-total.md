---
title: Scraper Nonnegative Result Total Guard
type: reliability
status: completed
date: 2026-06-15
execution: code
---

# Scraper Nonnegative Result Total Guard

## Problem Frame

`parse_total()` accepts any integer extracted from PriceScope result markup.
A negative upstream count therefore replaces the bounded fallback, stops all
remaining page requests, and contributes a negative value to the final
"diamonds reported" summary. Result counts are cardinalities and must never be
negative.

## Prioritized Engineering Work

1. **P0 - Result-count integrity:** reject negative parsed totals and retain the
   current bounded fallback.
2. **P1 - Source/provenance verification:** execute the existing model
   verification matrix against an authorized live source and record evidence.
3. **P2 - Model runtime and quality:** reproduce the R/rpy2 fit, residuals,
   generated PDF, and quality metrics in a maintainer-controlled environment.

This change implements only P0. P1 and P2 require external authorization and
runtime evidence and remain tracked by `MODEL_VERIFICATION.md`.

## Scope Boundaries

- Reject only parsed result totals below zero.
- Preserve zero-result queries, positive totals, malformed-markup fallback, the
  20-page ceiling, exact page boundaries, and partial final pages.
- Preserve endpoint, timeout, response-size, response-origin, UTF-8, range,
  atomic-output, parser, model-input, and checked-in dataset behavior.
- Do not access live PriceScope, change query parameters, regenerate datasets,
  run R/rpy2, or claim model-quality evidence.

## Requirements

- R1. `parse_total()` must return zero and positive parsed totals unchanged.
- R2. A negative parsed total must return the caller-provided fallback.
- R3. A negative total in page markup must retain bounded pagination instead of
  stopping the query or making the aggregate reported total negative.
- R4. Existing malformed markup, exact-boundary, partial-page, and zero-result
  behavior must remain covered.
- R5. Static contracts must reject negative-total acceptance, test removal,
  documentation drift, and stale completion evidence.

## Implementation Units

### U1: Validate Parsed Cardinality

Files:

- `psdownload.py`
- `scripts/test-psdownload.py`

Approach:

- Parse the count once and return it only when it is nonnegative.
- Reuse the existing fallback for negative and malformed values.
- Add helper-level and request-count regressions that distinguish zero from a
  negative count.

### U2: Preserve The Contract

Files:

- `scripts/check-baseline.sh`
- `AGENTS.md`
- `CHANGES.md`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `docs/plans/2026-06-15-scraper-nonnegative-result-total.md`

Approach:

- Require the nonnegative predicate, focused tests, synchronized guidance, and
  completed verification evidence.

## Verification

- focused `scripts/test-psdownload.py`
- full repository and external-directory `make check`
- Python compilation and shell syntax checks
- isolated hostile mutations for predicate removal, zero-result regression,
  negative-pagination regression, documentation drift, and plan evidence
- exact diff, generated artifact, conflict marker, and credential audits

## Risks

- Live source markup may differ from fixtures; malformed or negative counts will
  conservatively retain the existing 500-result bounded fallback.
- Live PriceScope, source terms, provenance, R/rpy2, generated PDF, and model
  quality remain outside this change.

## Status: Completed

## Work Completed

- Rejected parsed result totals below zero while preserving zero and positive
  cardinalities.
- Retained the existing 500-result bounded fallback for malformed and negative
  counts, preventing premature pagination termination and negative summaries.
- Added helper, request-count, static-contract, documentation, and completed-plan
  coverage.

## Verification Completed

- Focused scraper tests passed all 30 cases.
- Six hostile mutations were rejected for predicate removal, zero-result
  rejection, helper-test removal, pagination-test removal, documentation drift,
  and missing completion evidence.
- Python 3.12 and 3.14 repository and external-directory `make check` passed all
  51 parser, scraper, and model-input tests plus Python compilation.
- Live PriceScope access was not executed; source terms, provenance, R/rpy2,
  generated PDF, and model-quality evidence remain unexecuted.
