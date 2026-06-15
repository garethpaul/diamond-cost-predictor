---
title: Graph CLI Validation
status: in_progress
date: 2026-06-15
---

# Graph CLI Validation

## Problem

`graph.py` treats two or three user arguments as though no prediction request was
made, accepts extra arguments, and allows non-finite or non-positive values into
prediction and savings calculations. A zero actual price can divide by zero, and
invalid values are not rejected until after model input or rpy2 work begins.

## Requirements

1. Accept either no prediction values or exactly four values: carat, color,
   clarity, and actual price.
2. Require finite-positive carat and price values.
3. Require positive integer color and clarity values.
4. Reject invalid arguments before opening `output.csv` or importing rpy2.
5. Preserve the existing no-argument model flow and valid prediction behavior.

## Implementation

- Add a dependency-free `parse_prediction_args` helper to `graph.py`.
- Parse once at the start of `main` and use the validated tuple for optional
  prediction annotation.
- Extend model-input tests with valid, partial, extra, non-finite, non-positive,
  fractional-category, and failure-order cases.
- Add static contracts and synchronized CLI guidance.

## Verification Plan

- Focused graph argument tests
- `make check`
- `make -C /tmp -f <worktree>/Makefile check`
- Isolated hostile mutations for arity, finiteness, positivity, integer fields,
  failure ordering, documentation, and plan evidence
- Exact diff, Python artifact, whitespace, conflict-marker, and credential scans

## Status: In Progress

Implementation and verification evidence will be recorded after the gates complete.
