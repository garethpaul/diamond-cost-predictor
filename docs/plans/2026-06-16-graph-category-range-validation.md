---
title: Graph Category Range Validation
status: completed
date: 2026-06-16
---

# Graph Category Range Validation

## Problem

`graph.py` accepts any positive integer for the optional color and clarity
prediction categories. The committed model inputs consistently encode color as
`1..6` and clarity as `1..8`, so values outside those domains silently ask the
linear model to extrapolate from categories it was never trained to represent.

## Priority

Reject unsupported prediction categories before opening `output.csv` or loading
R. A clear CLI failure is safer than producing a precise-looking price from an
out-of-domain category.

## Requirements

1. Accept color values from 1 through 6 and clarity values from 1 through 8.
2. Reject zero, negative, fractional, nonnumeric, and above-range categories.
3. Preserve no-argument behavior, valid boundary values, finite-positive carat
   and price validation, and failure ordering before model input or rpy2.
4. Keep the encoding limits named and dependency-free so source and tests share
   an explicit model contract.
5. Add direct, subprocess, static, guidance, changelog, and completed-plan
   regressions.

## Implementation

- Add named inclusive color and clarity ranges to `graph.py` and validate the
  parsed category values against them.
- Extend `scripts/test-model-input.py` with lower/upper boundary success and
  above-range failures, including a subprocess proof that invalid categories
  fail before `output.csv` access.
- Register source, test, documentation, and completed-plan assertions in
  `scripts/check-baseline.sh` and synchronize maintained guidance.

## Verification Plan

- Focused model/graph tests
- Repository-root and external-directory `make check`
- Isolated hostile mutations for both upper bounds, missing tests, guidance,
  and plan status/evidence
- Exact diff, Python artifact, whitespace, mode, and credential-pattern audits

## Scope Boundaries

- Do not change the committed datasets, category encodings, model formula,
  coefficients, graph rendering, or R/rpy2 integration.
- Do not claim live model fitting, generated PDF review, or prediction accuracy
  validation on this host.

## Verification Completed

- The focused model/graph tests passed with all 13 test methods; the complete
  dependency-free suite passed 55 tests plus Python and shell syntax checks.
- A finalized isolated tracked-file mirror passed repository-root validation;
  external-directory make check passed before the real plan was completed.
- Six isolated hostile mutations were rejected for the color and clarity upper
  bounds, missing boundary tests, erased guidance, and reopened plan status.
- Exact diff, generated-artifact, whitespace, file-mode, and added-line
  credential-pattern audits passed before the canonical final gates.
- R/rpy2 model execution, prediction PDF generation, live PriceScope access,
  provenance review, and model accuracy validation were not exercised.
