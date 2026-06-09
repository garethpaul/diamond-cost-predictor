#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
README="$ROOT_DIR/README.md"
VISION="$ROOT_DIR/VISION.md"
PLAN="$ROOT_DIR/docs/plans/2026-06-08-safe-diamond-parsing-baseline.md"
NUMERIC_PLAN="$ROOT_DIR/docs/plans/2026-06-08-numeric-field-validation.md"
CHECK_PLAN="$ROOT_DIR/docs/plans/2026-06-08-diamond-check-wrapper.md"
OUTPUT_PLAN="$ROOT_DIR/docs/plans/2026-06-09-output-path-validation.md"
OUTPUT_HELPER_PLAN="$ROOT_DIR/docs/plans/2026-06-09-output-helper-validation.md"
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
  "Makefile" \
  "csv.py" \
  "psdownload.py" \
  "graph.py" \
  "lm.py" \
  "scripts/check-baseline.sh" \
  "scripts/test-safe-parsing.py" \
  "scripts/test-psdownload.py" \
  "docs/plans/2026-06-08-diamond-check-wrapper.md" \
  "docs/plans/2026-06-08-pricescope-https-baseline.md" \
  "docs/plans/2026-06-08-numeric-field-validation.md" \
  "docs/plans/2026-06-08-scraper-timeout-python3-baseline.md" \
  "docs/plans/2026-06-08-safe-diamond-parsing-baseline.md" \
  "docs/plans/2026-06-09-scraper-argument-validation.md" \
  "docs/plans/2026-06-09-scraper-endpoint-validation.md" \
  "docs/plans/2026-06-09-output-helper-validation.md" \
  "docs/plans/2026-06-09-output-path-validation.md"; do
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

if ! grep -Fq "test_rejects_non_finite_numeric_fields" "$TESTS" || \
  ! grep -Fq "test_rejects_non_positive_price" "$TESTS" || \
  ! grep -Fq "test_rejects_non_positive_vendor_id" "$TESTS"; then
  printf '%s\n' "Parser tests must cover invalid numeric model inputs." >&2
  exit 1
fi

if ! grep -Fq "math.isfinite" "$PARSER" || ! grep -Fq "def positive_int" "$PARSER"; then
  printf '%s\n' "csv.py must validate finite positive numeric model inputs." >&2
  exit 1
fi

if ! grep -Fq "'vendor_id': positive_int(record['vendor_id'], 'vendor_id')" "$PARSER"; then
  printf '%s\n' "csv.py must validate vendor_id as a positive integer." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$README"; then
  printf '%s\n' "README must document the baseline guard." >&2
  exit 1
fi

if ! grep -Fq "make check" "$README"; then
  printf '%s\n' "README must document the root make check gate." >&2
  exit 1
fi

if ! grep -Fq "check: verify" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose make check as the repository verification wrapper." >&2
  exit 1
fi

if ! grep -Fq "build:" "$ROOT_DIR/Makefile" || \
  ! grep -Fq "verify: lint test build" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose build and include it in verification." >&2
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

if ! grep -Fq "vendor ID" "$README"; then
  printf '%s\n' "README must document positive vendor ID validation." >&2
  exit 1
fi

if ! grep -Fq "https://www.pricescope.com/results/ajax/" "$README"; then
  printf '%s\n' "README must document the HTTPS PriceScope endpoint." >&2
  exit 1
fi

if ! grep -Fq "explicit host" "$README" ||
  ! grep -Fq "embedded" "$README" ||
  ! grep -Fq "query strings or fragments" "$README"; then
  printf '%s\n' "README must document endpoint override credential and query restrictions." >&2
  exit 1
fi

if ! grep -Fq "blank output paths" "$README"; then
  printf '%s\n' "README must document scraper output path validation." >&2
  exit 1
fi

if ! grep -Fq "write helper also validates output paths" "$README"; then
  printf '%s\n' "README must document helper-level output path validation." >&2
  exit 1
fi

if ! grep -Fq "avoid executing untrusted input as code" "$VISION"; then
  printf '%s\n' "VISION.md must keep the parser safety direction visible." >&2
  exit 1
fi

if ! grep -Fq "Validate scraper endpoint overrides" "$VISION"; then
  printf '%s\n' "VISION.md must keep scraper endpoint validation visible." >&2
  exit 1
fi

if ! grep -Fq "Validate scraper output paths" "$VISION"; then
  printf '%s\n' "VISION.md must keep scraper output path validation visible." >&2
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

if ! grep -Fq "status: completed" "$CHECK_PLAN"; then
  printf '%s\n' "Check wrapper plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$ROOT_DIR/docs/plans/2026-06-09-scraper-argument-validation.md"; then
  printf '%s\n' "Scraper argument validation plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-scraper-argument-validation.md"; then
  printf '%s\n' "Scraper argument validation plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$ROOT_DIR/docs/plans/2026-06-09-scraper-endpoint-validation.md"; then
  printf '%s\n' "Scraper endpoint validation plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-scraper-endpoint-validation.md"; then
  printf '%s\n' "Scraper endpoint validation plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$OUTPUT_PLAN"; then
  printf '%s\n' "Scraper output path validation plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$OUTPUT_PLAN"; then
  printf '%s\n' "Scraper output path validation plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$OUTPUT_HELPER_PLAN"; then
  printf '%s\n' "Output helper validation plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$OUTPUT_HELPER_PLAN"; then
  printf '%s\n' "Output helper validation plan must record make check verification." >&2
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

if ! grep -Fq "urlparse(endpoint)" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq 'parsed.scheme.lower() != "https" or not parsed.netloc' "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must reject endpoint overrides without HTTPS and a host." >&2
  exit 1
fi

if ! grep -Fq "parsed.username or parsed.password" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must reject endpoint overrides with embedded credentials." >&2
  exit 1
fi

if ! grep -Fq "parsed.query or parsed.fragment" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must reject endpoint overrides with query strings or fragments." >&2
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

if ! grep -Fq "def validate_scrape_args" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must share scraper argument validation across CLI and helpers." >&2
  exit 1
fi

if ! grep -Fq "max_carat must be greater than min_carat" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must reject invalid carat ranges before scraping." >&2
  exit 1
fi

if ! grep -Fq "timeout must be positive" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must reject non-positive timeouts before scraping." >&2
  exit 1
fi

if ! grep -Fq "def validate_output_path" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must validate scraper output paths before scraping." >&2
  exit 1
fi

if ! grep -Fq "output path must not be blank" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must reject blank output paths before scraping." >&2
  exit 1
fi

if ! grep -Fq "path_text = os.fspath(path) if path is not None else" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "validate_output_path(path)" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must validate direct write helper output paths." >&2
  exit 1
fi

if ! grep -Fq "test_parse_args_rejects_invalid_carat_ranges" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover invalid carat range arguments." >&2
  exit 1
fi

if ! grep -Fq "test_parse_args_rejects_non_positive_timeout" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover non-positive timeout arguments." >&2
  exit 1
fi

if ! grep -Fq "test_collect_diamonds_validates_arguments_before_network" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover direct helper argument validation." >&2
  exit 1
fi

if ! grep -Fq "test_parse_args_rejects_blank_output_path" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover blank output path arguments." >&2
  exit 1
fi

if ! grep -Fq "test_write_diamonds_rejects_blank_output_path" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover direct helper output path validation." >&2
  exit 1
fi

if ! grep -Fq "test_pricescope_endpoint_rejects_embedded_credentials" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover credential-bearing endpoint overrides." >&2
  exit 1
fi

if ! grep -Fq "test_pricescope_endpoint_rejects_query_strings_and_fragments" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover query-string and fragment endpoint overrides." >&2
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
