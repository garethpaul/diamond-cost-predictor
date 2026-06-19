# Diamond Model Verification Matrix

Status: Completed

## Problem

Portable tests cover safe parsing, finite positive model rows, HTTPS endpoint
validation, response-origin and UTF-8 checks, bounded scraping, and atomic CSV
publication. The repository does not define repeatable exact-head evidence for
live source provenance, R/rpy2 model fitting, generated prediction artifacts,
or model quality.

## Requirements

1. Add an exact-commit matrix for source authorization, dataset provenance,
   scrape shape, row validation, R/rpy2 environment, deterministic evaluation,
   model fit, residuals, generated PDF, and reproducibility.
2. Require non-sensitive source, toolchain, dataset, result, metric, and
   evidence fields with explicit pass, fail, blocked, or not-run outcomes.
3. Keep parser, scraper fixture, live source, R model, artifact, and accuracy
   evidence separate so portable checks cannot imply model execution.
4. Add mutation-sensitive contracts for the matrix, repository guidance, and
   completed plan evidence.

## Scope Boundaries

- Do not change Python, R/model behavior, dependencies, endpoints, output.csv,
  allDiamonds.csv, generated PDFs, fixtures, or runtime configuration.
- Do not add scraped proprietary data, account information, source cookies,
  raw responses, generated predictions, PDFs, logs, or local environments.
- Do not claim live PriceScope, R/rpy2, PDF, or model-quality execution from
  parser, fixture, compile, or static checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- `sh -n scripts/check-baseline.sh` and the focused baseline checker passed.
- `make check` passed under Python 3.12 and Python 3.14 from the repository and
  from an external working directory.
- Twelve isolated hostile mutations of the checklist, guidance, and completed
  plan contracts were rejected by `scripts/check-baseline.sh`.
- No live PriceScope access, R/rpy2 environment, model fit, evaluation metrics, residual review, prediction PDF, or reproducibility run was executed; every model row remains `not run`.
