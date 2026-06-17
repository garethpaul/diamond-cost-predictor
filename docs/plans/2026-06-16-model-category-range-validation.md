---
title: Model Category Range Validation
status: completed
date: 2026-06-16
---

# Model Category Range Validation

## Problem

`graph.py` rejects prediction colors outside 1 through 6 and clarity values
outside 1 through 8, but `model_input.py` still accepts any positive integer in
those fields. A malformed `output.csv` can therefore train the model with
categories that the prediction boundary correctly treats as unsupported.

## Priority

Fail before loading rpy2 when generated or edited training rows violate the
same category domains enforced for predictions. Training and prediction must
share one explicit encoding contract.

## Requirements

1. Define the color and clarity ranges once and reuse them in both parsers.
2. Accept the lower and upper boundaries in model rows.
3. Reject above-range model categories with field-specific diagnostics.
4. Preserve exact row shape, finite-positive numeric validation, path and line
   diagnostics, and failure ordering before rpy2 import.
5. Add executable, static, documentation, changelog, and completed-plan
   regressions.

## Verification Plan

- Focused model/graph tests
- Repository-root and external-directory `make check`
- Isolated hostile mutations for shared bounds, parser delegation, executable
  cases, guidance, and plan status/evidence
- Exact diff, generated-artifact, whitespace, mode, and credential-pattern
  audits

## Scope Boundaries

- Do not change datasets, category encodings, model formula, coefficients,
  graph rendering, scraper behavior, or R/rpy2 integration.
- Do not claim live model fitting, generated PDF review, PriceScope access, or
  prediction accuracy validation on this host.

## Verification Completed

- The focused model/graph tests passed with all 16 test methods; the complete
  dependency-free suite passed 58 tests.
- Repository-root and external-directory make check passed with Python and
  POSIX shell syntax validation included.
- Twelve isolated hostile mutations were rejected across both upper bounds,
  both parser-delegation bypasses, inclusive-bound behavior, path and line
  diagnostics, the shared import, executable cases, maintained guidance,
  bounded-parser ownership, and completed-plan status and evidence.
- Exact diff, generated-artifact, whitespace, file-mode, and added-line
  credential-pattern audits passed.
- The implementation was committed as
  `20729749d2dda535db8285c7b2f38a5af658a3b2`.
- Canonical hosted verification passed on that exact implementation head:
  push run `27645252397` and pull-request run `27645266318` each completed
  successfully across Python 3.10, 3.12, and 3.14. PR #20 remained open,
  clean, and mergeable, and the branch had no open code-scanning alerts.
- R/rpy2 model execution, prediction PDF generation, live PriceScope access,
  provenance review, and prediction accuracy validation were not exercised.
