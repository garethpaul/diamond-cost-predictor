# Changelog

## 2026-06-26 - Reject malformed scraper marker pairs

- Malformed diamond-data marker pairs abort collection before output replacement.
- Rejected page-ending markers and blank paired records so structurally
  truncated responses cannot publish incomplete datasets.
- Added test-first scraper coverage plus design and implementation records.
- Python 3.11.8 passes the focused and full root/external gates; independent
  removal of either structural guard fails the intended regression.

## 2026-06-26

- Scraper publication fsyncs the destination directory after atomic replacement
  so successful output publication includes durable rename metadata.
- Added an ordering-aware runtime regression for replace, directory open,
  directory fsync, descriptor close, and fsync-failure cleanup.
- Validated the exact implementation head with duplicate Python 3.10/3.12/3.14
  matrices, CodeQL Actions and Python analysis, and a clean immutable manual
  review; Codex review failed with HTTP 401 before analysis.

## 2026-06-25

- Published prediction PDFs only after same-directory staging, nonempty and
  durable-file checks, R-device closure, and atomic replacement.
- Prevented failed page downloads from publishing partial datasets over an
  existing scraper output while preserving valid empty responses.
- Revalidated the shared converter and model-input category schema across the
  full parser, scraper, model-input, compilation, and hosted Python matrix.

## 2026-06-22

- Shared one trained color and clarity domain between conversion and model input,
  skipping source categories outside that domain before CSV rows are emitted.

## 2026-06-16

- Rejected training rows outside color 1 through 6 and clarity 1 through 8
  before model input can reach R.
- Rejected graph predictions outside color 1 through 6 and clarity 1 through 8
  before model input or R execution.

## 2026-06-15

- Validated graph prediction CLI values before model input and R execution,
  including exact arity, finite-positive values, and positive integer categories.
- Rejected negative PriceScope result totals while preserving zero-result
  queries and bounded fallback pagination.
- Stopped redundant PriceScope page requests at exact 25-row result boundaries
  while preserving partial-page and malformed-count fallback behavior.

## 2026-06-14

- Added an exact-head model verification matrix with provenance, accuracy,
  reproducibility, and artifact evidence fields kept explicitly unexecuted.

## 2026-06-13

- Validated generated model rows before loading rpy2, with exact field counts,
  finite-positive values, and path/line diagnostics.
- Validated final scraper response origins before body reads, rejecting HTTPS
  downgrades and cross-origin redirects.
- Published scraper output atomically after same-directory staging, flush, and
  sync so failed writes preserve an existing dataset.
- Rejected malformed UTF-8 scraper responses at page scope instead of
  inserting replacement characters into downloaded diamond records.

## 2026-06-12

- Stopped GitHub Actions checkout from persisting its credential and added an
  exact contract for the sole workflow and checkout step.
- Rejected fractional and non-finite float literals in vendor ID and price
  fields instead of truncating them or leaking conversion errors.
- Added regression coverage for both integer fields and retained support for
  exact integral float values.
- Limited each scraper invocation to a `0.5` carat span before network work.
- Rejected invalid or non-advancing floating-point range steps and added
  no-network regression coverage for both work limits.

## 2026-06-10

- Limited each downloaded PriceScope page to 2 MiB before decoding and added
  offline regression tests for bounded and oversized responses.
- Rooted Make verification to the repository and pinned CI to Ubuntu 24.04.
- Added a GitHub Actions workflow that runs `make check` on Python 3.10, 3.12,
  and 3.14.
- Pinned workflow actions and limited repository access to read-only with
  bounded execution.
- Extended the baseline guard and docs to require the hosted CI verification
  path.

## 2026-06-09

- Rejected boolean literals for parsed numeric diamond model fields.
- Rejected non-finite scraper carat and timeout arguments before starting
  PriceScope download loops.
- Validated direct `write_diamonds` output paths before opening files.
- Rejected blank scraper output paths before starting PriceScope download
  loops and exposed a Python compile `make build` gate.
- Rejected malformed PriceScope endpoint overrides that lack an HTTPS host,
  include embedded credentials, or include query strings or fragments.
- Rejected invalid scraper carat ranges and non-positive timeouts before
  starting PriceScope download loops.

## 2026-06-08

- Added a root `make check` wrapper for the safe parsing and scraper tests.
- Validated scraped vendor IDs as positive integers before writing model rows.
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
