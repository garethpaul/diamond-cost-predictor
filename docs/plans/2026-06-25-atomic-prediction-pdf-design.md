# Atomic Prediction PDF Design

## Evidence

- `graph.py` opens `prediction.pdf` directly before plotting and replaces its
  contents in place.
- Plotting, legend construction, or device shutdown can still fail after the
  destination has been truncated, leaving a partial report and destroying a
  previously verified artifact.
- `psdownload.py` already establishes the repository precedent: stage output in
  the destination directory, finish and sync it, then publish with
  `os.replace`.
- The roadmap explicitly calls for checks around model output, while generated
  PDFs remain untracked artifacts.

## Approaches

### 1. Same-directory staged PDF with atomic replacement

Create a private temporary file next to the destination, give R that path,
close the R device in `finally`, require a nonempty staged PDF, and replace the
destination only after the plotting block succeeds.

This is the recommended approach because it preserves an existing report on
every Python/R failure and uses the repository's established atomic-publication
boundary.

### 2. Back up and restore the destination

Rename an existing PDF aside, write directly to the destination, then restore
the backup on failure. This introduces more rename states and crash windows and
is less direct than staging the new artifact.

### 3. Write directly and copy after completion

Keep R writing `prediction.pdf`, then copy it elsewhere after success. This
does not protect the canonical destination from truncation and therefore does
not solve the failure mode.

## Decision

Use a small context manager in `graph.py` that yields a same-directory staged
path and publishes it with `os.replace` only on clean exit. The plotting code
will always attempt `dev.off()` after opening the R device, but any plotting or
close failure will propagate through the context manager and preserve the
prior destination.

## Validation

- Test successful replacement with real temporary files.
- Test exception cleanup and preservation of an existing destination.
- Test rejection of an empty staged artifact.
- Test that a destination symlink is replaced without modifying its target.
- Keep the existing deferred-rpy2 and model-input tests green.
- Add source and hostile mutation contracts for same-directory staging,
  nonempty output validation, cleanup, and atomic replacement.
- Run repository/external `make check`; do not claim an R model or PDF runtime
  because rpy2/R is unavailable on the maintenance host.

## Boundaries

- Do not change the model formula, input rows, prediction arguments, plot
  contents, dependencies, or generated artifact name.
- Do not add a new CLI or make generated PDFs tracked.
- Do not claim report reproducibility without the pinned R/rpy2 matrix.
