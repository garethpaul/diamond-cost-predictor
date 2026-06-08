#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
README="$ROOT_DIR/README.md"
VISION="$ROOT_DIR/VISION.md"
PLAN="$ROOT_DIR/docs/plans/2026-06-08-safe-diamond-parsing-baseline.md"
NUMERIC_PLAN="$ROOT_DIR/docs/plans/2026-06-08-numeric-field-validation.md"
PARSER="$ROOT_DIR/csv.py"
TESTS="$ROOT_DIR/scripts/test-safe-parsing.py"
SCRAPER_TESTS="$ROOT_DIR/scripts/test-psdownload.py"

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
  "psdownload.py" \
  "graph.py" \
  "lm.py" \
  "scripts/check-baseline.sh" \
  "scripts/test-safe-parsing.py" \
  "scripts/test-psdownload.py" \
  "docs/plans/2026-06-08-pricescope-https-baseline.md" \
  "docs/plans/2026-06-08-numeric-field-validation.md" \
  "docs/plans/2026-06-08-scraper-timeout-python3-baseline.md" \
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

if ! grep -Fq "test_rejects_non_finite_numeric_fields" "$TESTS" || ! grep -Fq "test_rejects_non_positive_price" "$TESTS"; then
  printf '%s\n' "Parser tests must cover invalid numeric model inputs." >&2
  exit 1
fi

if ! grep -Fq "math.isfinite" "$PARSER" || ! grep -Fq "def positive_int" "$PARSER"; then
  printf '%s\n' "csv.py must validate finite positive numeric model inputs." >&2
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

if ! grep -Fq "finite positive" "$README"; then
  printf '%s\n' "README must document numeric field validation." >&2
  exit 1
fi

if ! grep -Fq "https://www.pricescope.com/results/ajax/" "$README"; then
  printf '%s\n' "README must document the HTTPS PriceScope endpoint." >&2
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

if ! grep -Fq "status: completed" "$NUMERIC_PLAN"; then
  printf '%s\n' "Numeric validation plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "urlopen(url, timeout=timeout)" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must set a timeout on network downloads." >&2
  exit 1
fi

if ! grep -Fq 'DEFAULT_PRICESCOPE_AJAX_URL = "https://www.pricescope.com/results/ajax/"' "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must default to the HTTPS PriceScope endpoint." >&2
  exit 1
fi

if grep -Fq "http://www.pricescope.com/results/ajax/" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must not use the plain-HTTP PriceScope endpoint." >&2
  exit 1
fi

if ! grep -Fq 'endpoint.lower().startswith("https://")' "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must reject non-HTTPS endpoint overrides." >&2
  exit 1
fi

if ! grep -Fq "except (TimeoutError, socket.timeout, URLError)" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must handle timeout and URL failures at page scope." >&2
  exit 1
fi

if ! grep -Fq "argparse.ArgumentParser" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must expose explicit CLI arguments." >&2
  exit 1
fi

for ignored in "diamonds.txt" "prediction.pdf"; do
  if ! grep -Fq "$ignored" "$ROOT_DIR/.gitignore"; then
    printf '%s\n' ".gitignore must ignore generated $ignored" >&2
    exit 1
  fi
done

python3 -m py_compile "$PARSER" "$TESTS" "$SCRAPER_TESTS" "$ROOT_DIR/psdownload.py" "$ROOT_DIR/graph.py" "$ROOT_DIR/lm.py"
python3 "$TESTS"
python3 "$SCRAPER_TESTS"

printf '%s\n' "Diamond safe parsing baseline checks passed."
