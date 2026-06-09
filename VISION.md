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
- Validate scraper numeric arguments as finite values before downloading data
- Validate scraper endpoint overrides before downloading data
- Validate scraper output paths before downloading data and direct file writes
- Reject boolean literals in numeric diamond fields before model generation
- Keep the model formula and graph generation easy to inspect

Next priorities:

- Add README setup, data-source, and reproduction instructions
- Port scripts to a supported Python version in a dedicated pass
- Keep structured diamond record parsing covered by regression tests
- Add checks around input files and model output

Contribution rules:

- One PR = one focused data, parsing, modeling, or documentation change.
- Document any dataset replacement or regenerated output.
- Keep generated reports separate from source changes.
- Verify model scripts with the declared Python/R environment before pushing.

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
