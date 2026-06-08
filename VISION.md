## Diamond Cost Predictor Vision

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
- Keep the model formula and graph generation easy to inspect

Next priorities:

- Add README setup, data-source, and reproduction instructions
- Port scripts to a supported Python version in a dedicated pass
- Replace `eval`-based parsing with structured data loading
- Add checks around input files, field conversion, and model output

Contribution rules:

- One PR = one focused data, parsing, modeling, or documentation change.
- Document any dataset replacement or regenerated output.
- Keep generated reports separate from source changes.
- Verify model scripts with the declared Python/R environment before pushing.

## Security And Data

Scraped listings and generated datasets should be treated as data artifacts with
provenance. Do not add private purchase records or credentials.

Parsing changes should avoid executing untrusted input as code.

## What We Will Not Merge (For Now)

- Private or unattributed datasets
- More scraping without data-source and terms notes
- Model rewrites that cannot reproduce a baseline result
- Parser changes that keep executing untrusted text
