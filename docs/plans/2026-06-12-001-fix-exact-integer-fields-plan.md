---
title: Exact Integer Field Validation
type: fix
date: 2026-06-12
---

# Exact Integer Field Validation

## Summary

Require parsed `vendor_id` and `price` values to represent exact positive
integers instead of silently truncating fractional float literals.

## Problem Frame

`positive_int` currently converts values with `int(value)`. A record containing
`225.75` is emitted as `225`, while an infinite float raises `OverflowError`
outside the parser's documented `ValueError` contract.

## Requirements

- R1. Fractional float literals must be rejected for `vendor_id` and `price`.
- R2. Non-finite float literals in integer fields must be rejected as
  `ValueError`.
- R3. Positive integer strings, integer literals, and integral float literals
  must retain their current accepted behavior.
- R4. Parser tests and the source baseline must preserve exact-integer field
  validation.
- R5. README, VISION, and CHANGES must document the tightened model-input
  contract.

## Key Technical Decisions

- **Validate floats before integer conversion:** Use `math.isfinite` and
  `float.is_integer` only for float inputs so accepted integer strings remain
  backward compatible.
- **Keep one parser error type:** Convert numeric conversion failures,
  including `OverflowError`, into the existing field-specific `ValueError`.
- **Cover both integer fields:** Test fractional vendor IDs and prices because
  both flow through the shared helper.

## Implementation Units

### U1. Enforce exact positive integers

- **Goal:** Reject fractional and non-finite float values without changing
  supported exact integer representations.
- **Files:** `csv.py`
- **Verification:** Focused helper and record parser tests.

### U2. Add parser regressions and baseline guards

- **Goal:** Cover fractional vendor IDs, fractional prices, non-finite integer
  fields, and accepted integral floats.
- **Files:** `scripts/test-safe-parsing.py`, `scripts/check-baseline.sh`
- **Verification:** `python3 scripts/test-safe-parsing.py` and `make check`.

### U3. Document the exact-integer contract

- **Goal:** Keep contributor guidance aligned with parser behavior.
- **Files:** `README.md`, `VISION.md`, `CHANGES.md`
- **Verification:** `scripts/check-baseline.sh` and `git diff --check`.

## Acceptance Examples

- AE1. Given `price: 225.75`, when the record is parsed, then parsing fails with
  `ValueError`. Covers R1.
- AE2. Given `vendor_id: 42.5`, when the record is parsed, then parsing fails
  with `ValueError`. Covers R1.
- AE3. Given `price: 1e309`, when the record is parsed, then parsing fails with
  `ValueError` rather than leaking `OverflowError`. Covers R2.
- AE4. Given `price: 225.0`, when the record is parsed, then the normalized
  value remains integer `225`. Covers R3.

## Scope Boundaries

- Do not change validation for carat, depth, or table fields.
- Do not alter output column ordering or formatting.
- Do not port the legacy modeling scripts or add dependencies.

## Risks And Mitigations

- Rejecting all floats would break exact values from literal input. Accept
  finite floats whose value is mathematically integral.
- Broad numeric coercion could change accepted strings. Restrict the new
  precondition to actual float instances.
