#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
README="$ROOT_DIR/README.md"
VISION="$ROOT_DIR/VISION.md"
PLAN="$ROOT_DIR/docs/plans/2026-06-08-safe-diamond-parsing-baseline.md"
PARSER="$ROOT_DIR/csv.py"
TESTS="$ROOT_DIR/scripts/test-safe-parsing.py"

require_file() {
  path=$1
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file is missing: $path" >&2
    exit 1
  fi
}

for path in \
  "README.md" \
  "VISION.md" \
  "SECURITY.md" \
  "csv.py" \
  "scripts/check-baseline.sh" \
  "scripts/test-safe-parsing.py" \
  "docs/plans/2026-06-08-safe-diamond-parsing-baseline.md"; do
  require_file "$path"
done

if grep -Eq '(^|[^._[:alnum:]])eval[[:space:]]*\(' "$PARSER"; then
  printf '%s\n' "csv.py must not execute scraped diamond records with eval()." >&2
  exit 1
fi

if ! grep -Fq "ast.literal_eval" "$PARSER"; then
  printf '%s\n' "csv.py must parse scraped records with ast.literal_eval." >&2
  exit 1
fi

if ! grep -Fq "def parse_diamond_line" "$PARSER" || ! grep -Fq "if __name__ == '__main__'" "$PARSER"; then
  printf '%s\n' "csv.py must expose a testable parser and a main guard." >&2
  exit 1
fi

if ! grep -Fq "__import__('os').system" "$TESTS"; then
  printf '%s\n' "Parser tests must cover malicious non-literal input." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$README"; then
  printf '%s\n' "README must document the baseline guard." >&2
  exit 1
fi

if ! grep -Fq "ast.literal_eval" "$README"; then
  printf '%s\n' "README must document the safe parsing baseline." >&2
  exit 1
fi

if ! grep -Fq "avoid executing untrusted input as code" "$VISION"; then
  printf '%s\n' "VISION.md must keep the parser safety direction visible." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$PLAN"; then
  printf '%s\n' "Plan must be marked completed." >&2
  exit 1
fi

python3 -m py_compile "$PARSER" "$TESTS"
python3 "$TESTS"

printf '%s\n' "Diamond safe parsing baseline checks passed."
