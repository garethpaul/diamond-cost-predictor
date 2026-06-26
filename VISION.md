## Diamond Cost Predictor Vision

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Diamond Cost Predictor is a Python 2-era set of scripts for scraping diamond
listing data, normalizing fields, and fitting a linear regression model through
R/rpy2.

The repository is useful as a preserved data-science experiment for turning
pricing attributes into a simple predicted-price model.

The goal is to keep the experiment reproducible enough to study while making
data provenance, runtime assumptions, and generated artifacts explicit.

The current focus is:

Priority:

- Preserve the raw CSV data, transformation scripts, and modeling scripts
- Keep Python 2 and rpy2/R assumptions visible
- Avoid hiding generated outputs or scraped-data provenance
- Validate scraper ranges before downloading data
- Bound each scraper invocation to a narrow carat span and reject range steps
  that cannot advance
- Validate scraper numeric arguments as finite values before downloading data
- Validate scraper endpoint overrides before downloading data
- Validate scraper output paths before downloading data and direct file writes
- Bound each remote scraper page before decoding it into memory
- Avoid redundant scraper page requests at exact result boundaries
- Reject negative upstream result totals without changing zero-result behavior
- Validate graph prediction arguments before model execution
- Keep graph prediction categories within color 1 through 6 and
  clarity 1 through 8, matching the committed model inputs
- Keep training rows within color 1 through 6 and clarity 1 through 8 before
  model execution
- Reject malformed UTF-8 scraper pages instead of repairing remote records
- Validate final scraper response origins before reading remote bodies
- Publish scraper output atomically only after durable same-directory staging
- Prevent incomplete scraper runs from replacing prior datasets
- Reject boolean literals in numeric diamond fields before model generation
- Require vendor IDs and prices to be exact positive integers
- Validate generated model rows before R execution
- Keep GitHub Actions aligned with the local Python `make check` baseline
  without persisting the checkout credential
- Keep the model formula and graph generation easy to inspect
- Scraper publication fsyncs the destination directory after atomic replacement
- Publish model PDFs with same-directory atomic replacement only after a
  complete nonempty report is closed and durably flushed

Next priorities:

- Execute the diamond model verification matrix against an authorized source
  and a pinned R/rpy2 environment
- Add README setup, data-source, and reproduction instructions
- Port scripts to a supported Python version in a dedicated pass
- Keep structured diamond record parsing covered by regression tests

Contribution rules:

- One PR = one focused data, parsing, modeling, or documentation change.
- Document any dataset replacement or regenerated output.
- Keep generated reports separate from source changes.
- Verify model scripts with the declared Python/R environment before pushing.
- Keep `.github/workflows/check.yml` in sync with the local parser and scraper
  guard.

## Security And Data

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Scraped listings and generated datasets should be treated as data artifacts with
provenance. Do not add private purchase records or credentials.

Parsing changes should avoid executing untrusted input as code.

## What We Will Not Merge (For Now)

- Private or unattributed datasets
- More scraping without data-source and terms notes
- Model rewrites that cannot reproduce a baseline result
- Parser changes that keep executing untrusted text

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
