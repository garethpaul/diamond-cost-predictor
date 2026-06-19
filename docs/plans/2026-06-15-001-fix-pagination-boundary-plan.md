---
title: "fix: Stop redundant diamond page requests"
type: fix
status: completed
date: 2026-06-15
execution: code
---

# Fix Redundant Diamond Page Requests

## Problem Frame

PriceScope result pages contain 25 rows. The scraper currently skips a page
only when its starting offset is greater than the reported result total. At an
exact page boundary such as 25 or 50 results, it therefore requests one page
beyond the available result set. The fixed 20-page ceiling bounds the damage,
but the extra request still wastes source capacity and increases rate-limit
exposure.

## Scope Boundaries

- Correct only the page-boundary decision inside `collect_diamonds`.
- Preserve the 20-page ceiling, 25-row page shape, carat-range limits, request
  timeout, response byte limit, response-origin checks, UTF-8 handling, and
  atomic output publication.
- Do not change the PriceScope query, source terms, model inputs, R workflow, or
  checked-in datasets.

## Requirements

- R1. A query reporting exactly 25 results must request only page 1.
- R2. A query reporting exactly 50 results must request only pages 1 and 2.
- R3. A positive partial final page must still be requested.
- R4. Malformed total markup must retain the existing bounded fallback behavior.
- R5. Static contracts must reject comparison drift, request-count test removal,
  documentation drift, and stale plan evidence.

## Key Technical Decision

Use the page start offset as the boundary: skip when the offset is greater than
or equal to the reported total. Keep the existing fallback total and page cap so
an absent or malformed count cannot create unbounded work.

## Implementation Units

### U1: Pagination Boundary And Regression Tests

Goal: stop exact-boundary over-fetching without changing partial-page behavior.

Files:

- `psdownload.py`
- `scripts/test-psdownload.py`

Approach:

- Name the 25-row page size instead of repeating an unexplained literal.
- Correct the boundary comparison in `collect_diamonds`.
- Add deterministic request-count tests using a narrowed shape/range fixture and
  a stubbed response reader.

Test scenarios:

- Exactly 25 results: page 1 only.
- Exactly 50 results: pages 1 and 2 only.
- 26 results: pages 1 and 2.
- Malformed count: bounded fallback remains in effect.

### U2: Repository Contracts And Maintenance Evidence

Goal: make the request-minimization behavior durable.

Files:

- `scripts/check-baseline.sh`
- `README.md`
- `SECURITY.md`
- `CHANGES.md`
- `VISION.md`
- `AGENTS.md`
- `docs/plans/2026-06-15-001-fix-pagination-boundary-plan.md`

Approach:

- Require the named page size, corrected comparison, request-count fixtures,
  synchronized maintenance guidance, and completed verification evidence.

## Verification

- Focused `scripts/test-psdownload.py`
- Full `make check`
- Absolute-path `make check` from an external directory
- `python3 -m compileall` for changed Python modules
- `sh -n scripts/check-baseline.sh`
- `git diff --check`
- Isolated mutations for boundary comparison, page-size constant, exact and
  partial request-count fixtures, documentation, plan status, and evidence

## Risks

- The scraper parses a legacy upstream HTML marker; malformed count markup must
  continue using the existing 500-result fallback rather than prematurely
  stopping pagination.
- Live source behavior remains outside local tests and must not be inferred from
  deterministic stubs.

## Status: Completed

## Work Completed

- Named the 25-row PriceScope page size and corrected the page start-offset
  comparison so exact result boundaries do not trigger an extra request.
- Added deterministic request-count coverage for 25, 26, and 50 reported results.
- Added source, test, documentation, and completed-plan contracts to the static
  baseline.

## Verification Completed

- Focused scraper tests passed all 27 cases.
- The static baseline passed through every implementation and documentation
  contract before stopping at the intentionally incomplete plan-status gate.
- Eight hostile mutations were rejected for comparison drift, page-size constant
  deletion, exact, partial, and malformed-fallback request-count fixture removal,
  documentation drift, stale plan status, and missing evidence.
- Repository-root and absolute-path `make check` passed the static baseline,
  all 48 parser/scraper/model-input tests, and Python compilation.
- Live PriceScope access was not executed; deterministic response stubs prove
  request counts without sending source traffic.
