# AGENTS.md

## Repository purpose

`garethpaul/diamond-cost-predictor` is a public sample, documentation, or utility project. Predict diamond cost using a linear regression model.

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `tests` - tests and fixtures

## Development commands

- Install dependencies: no repository-specific install command is documented.
- Full baseline: `make check`
- Combined verification: `make verify`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Language mix noted in the README: Python (12), shell (2).
- Prefer dependency-free tests or stdlib checks when legacy packages are unavailable.

## Testing guidance

- Test-related files detected: `scripts/test-psdownload.py`, `scripts/test-safe-parsing.py`, `tests/`
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.
- `csv.py` parses downloaded records with `ast.literal_eval` and rejects unsafe non-literal input.
- Numeric parser validation rejects non-finite or non-positive model inputs before they are written to generated CSV rows.
- `psdownload.py` defaults to HTTPS, rejects non-HTTPS endpoint overrides, and rejects endpoint overrides without a host, with embedded credentials, or with query strings or fragments.
- `psdownload.py` handles page-level timeout or URL errors.
- Failed scraper pages must abort collection before output replacement; a valid empty response remains distinct from acquisition failure.
- `psdownload.py` must validate the final response origin before reading a page body.
- `psdownload.py` validates carat ranges and timeout values before scraping.
- `psdownload.py` must not request a page whose start offset equals the reported result total.
- `psdownload.py` must reject negative reported result totals while preserving zero-result queries.
- `psdownload.py` must preserve existing output until atomic replacement of a
  fully written and synced same-directory staged file.
- `output.csv` rows must preserve the producer's exact ten-field shape and pass
  finite-positive model validation before `graph.py` loads rpy2.
- Training rows must stay within color 1 through 6 and clarity 1 through 8.
- `graph.py` must validate optional prediction arguments before model input or rpy2.
- `graph.py` predictions must stay within color 1 through 6 and
  clarity 1 through 8, matching the committed model encodings.
- `prediction.pdf` must be staged, checked as nonempty, and atomically replaced
  only after the R device closes; failures must preserve the prior report, and
  publication must replace rather than follow a destination symlink.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
