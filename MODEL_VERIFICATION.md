# Diamond Model Verification Matrix

Use this matrix only for an exact implementation commit. Record the commit SHA and pull request
before testing so dataset, model, metric, and generated-artifact evidence cannot
be transferred to a different parser, scraper, or model implementation.

## Evidence Rules

- Confirm the source permits the planned access and record a public terms or
  authorization reference before any live scrape.
- Record Python, R, rpy2, package, source, dataset, split, metric, result, and
  sanitized evidence identifiers without committing generated data.
- Do not include scraped proprietary rows, account data, source cookies, raw
  responses, generated predictions, PDFs, logs, or local environments.
- Record dataset and artifact SHA-256 hashes instead of embedding their content.
- Record each result as `pass`, `fail`, `blocked`, or `not run`, with an owner
  and follow-up for every result other than `pass`.
- Do not convert `not run` into passing evidence.

## Run Identity

| Field | Value |
| --- | --- |
| Commit SHA | `not run` |
| Pull request | `not run` |
| Python / R / rpy2 versions | `not run` |
| Source authorization reference | `not run` |
| Dataset row count / SHA-256 | `not run` |
| Evaluation split / seed | `not run` |
| Prediction PDF SHA-256 | `not run` |
| Evidence location | `not run` |

## Verification Matrix

| Scenario | Expected evidence | Result | Evidence |
| --- | --- | --- | --- |
| Source terms review | A dated public terms or written authorization reference permits the exact access method and rate. | `not run` | `not run` |
| Live HTTPS source | The configured HTTPS source remains same-origin after redirects and returns strict UTF-8 within the response limit. | `not run` | `not run` |
| Bounded scrape | The approved carat range and timeout complete without exceeding the range, page-size, or request boundaries. | `not run` | `not run` |
| Atomic dataset publication | A failed scrape preserves the prior dataset and a successful scrape atomically publishes one synced file. | `not run` | `not run` |
| Dataset provenance | Source reference, retrieval time, command shape, row count, schema version, and SHA-256 are recorded outside git. | `not run` | `not run` |
| Model row validation | Every row has ten fields and finite positive model values before rpy2 is imported. | `not run` | `not run` |
| R/rpy2 environment | Exact Python, R, rpy2, and R package versions load without using an unrecorded global environment. | `not run` | `not run` |
| Deterministic evaluation split | A documented seed and split rule produce stable train and evaluation row hashes. | `not run` | `not run` |
| Model fit | The declared formula fits without warnings, non-finite coefficients, or silently dropped invalid rows. | `not run` | `not run` |
| Holdout accuracy | MAE, RMSE, sample count, and a predeclared acceptance threshold are recorded for the evaluation set. | `not run` | `not run` |
| Residual review | Residual distribution, largest errors, and obvious price/carat stratification failures are reviewed without exposing rows. | `not run` | `not run` |
| Prediction PDF | The PDF is generated outside git, opens successfully, and has a recorded SHA-256 and page count. | `not run` | `not run` |
| Reproducible rerun | A second run with the same dataset and seed reproduces metrics and artifact hash or records explained drift. | `not run` | `not run` |
| Clean failure | Missing R, rpy2, source access, data, or output permissions fail without replacing trusted datasets or artifacts. | `not run` | `not run` |

## Current Status

No live PriceScope access, R/rpy2 environment, model fit, evaluation metrics,
residual review, prediction PDF, or reproducibility run was executed for this checklist.
Treat every source, dataset, R, model, metric, residual, and artifact row as unexecuted
until evidence is attached to the exact commit.
