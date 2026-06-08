#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CSV_PY="$ROOT_DIR/csv.py"

if grep -Fq 'eval(lines[i])' "$CSV_PY"; then
  printf '%s\n' "csv.py must not evaluate diamond data as Python source." >&2
  exit 1
fi

if ! grep -Fq 'ast.literal_eval(line)' "$CSV_PY"; then
  printf '%s\n' "csv.py must parse diamond records with ast.literal_eval." >&2
  exit 1
fi

if ! grep -Fq 'isinstance(parsed, dict)' "$CSV_PY"; then
  printf '%s\n' "csv.py must reject non-dictionary diamond records." >&2
  exit 1
fi

if ! grep -Fq 'parse_diamond_line(lines[i], i + 1)' "$CSV_PY"; then
  printf '%s\n' "csv.py must parse records through parse_diamond_line." >&2
  exit 1
fi

printf '%s\n' "Diamond parsing safety checks passed."
