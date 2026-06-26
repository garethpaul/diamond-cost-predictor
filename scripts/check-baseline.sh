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
FINITE_SCRAPER_ARG_PLAN="$ROOT_DIR/docs/plans/2026-06-09-scraper-finite-argument-validation.md"
BOOLEAN_NUMERIC_PLAN="$ROOT_DIR/docs/plans/2026-06-09-boolean-numeric-field-validation.md"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
CHECKOUT_CREDENTIAL_PLAN="$ROOT_DIR/docs/plans/2026-06-12-checkout-credential-boundary.md"
RESPONSE_LIMIT_PLAN="$ROOT_DIR/docs/plans/2026-06-10-scraper-response-limit.md"
EXACT_INTEGER_PLAN="$ROOT_DIR/docs/plans/2026-06-12-001-fix-exact-integer-fields-plan.md"
RANGE_WORK_LIMIT_PLAN="$ROOT_DIR/docs/plans/2026-06-12-scraper-range-work-limit.md"
STRICT_RESPONSE_UTF8_PLAN="$ROOT_DIR/docs/plans/2026-06-13-scraper-strict-response-utf8.md"
ATOMIC_OUTPUT_PLAN="$ROOT_DIR/docs/plans/2026-06-13-scraper-atomic-output.md"
RESPONSE_ORIGIN_PLAN="$ROOT_DIR/docs/plans/2026-06-13-scraper-response-origin.md"
MODEL_INPUT_PLAN="$ROOT_DIR/docs/plans/2026-06-13-model-input-row-validation.md"
MAKE_ROOT_PLAN="$ROOT_DIR/docs/plans/2026-06-14-make-root-override-protection.md"
MODEL_VERIFICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-diamond-model-verification.md"
PAGINATION_BOUNDARY_PLAN="$ROOT_DIR/docs/plans/2026-06-15-001-fix-pagination-boundary-plan.md"
NONNEGATIVE_TOTAL_PLAN="$ROOT_DIR/docs/plans/2026-06-15-scraper-nonnegative-result-total.md"
GRAPH_CLI_PLAN="$ROOT_DIR/docs/plans/2026-06-15-graph-cli-validation.md"
GRAPH_CATEGORY_RANGE_PLAN="$ROOT_DIR/docs/plans/2026-06-16-graph-category-range-validation.md"
MODEL_CATEGORY_RANGE_PLAN="$ROOT_DIR/docs/plans/2026-06-16-model-category-range-validation.md"
PREDICTION_PDF_PLAN="$ROOT_DIR/docs/plans/2026-06-25-atomic-prediction-pdf.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
MAKEFILE="$ROOT_DIR/Makefile"
PARSER="$ROOT_DIR/csv.py"
TESTS="$ROOT_DIR/scripts/test-safe-parsing.py"
SCRAPER_TESTS="$ROOT_DIR/scripts/test-psdownload.py"
MODEL_DOMAIN="$ROOT_DIR/model_domain.py"
MODEL_INPUT="$ROOT_DIR/model_input.py"
MODEL_INPUT_TESTS="$ROOT_DIR/scripts/test-model-input.py"
GRAPH="$ROOT_DIR/graph.py"

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
  ".github/workflows/check.yml" \
  "Makefile" \
  "csv.py" \
  "psdownload.py" \
  "model_domain.py" \
  "model_input.py" \
  "graph.py" \
  "lm.py" \
  "scripts/check-baseline.sh" \
  "scripts/test-safe-parsing.py" \
  "scripts/test-psdownload.py" \
  "scripts/test-model-input.py" \
  "scripts/test-prediction-pdf-atomic.sh" \
  "scripts/test-prediction-pdf-atomic-mutations.sh" \
  "docs/plans/2026-06-08-diamond-check-wrapper.md" \
  "docs/plans/2026-06-08-pricescope-https-baseline.md" \
  "docs/plans/2026-06-08-numeric-field-validation.md" \
  "docs/plans/2026-06-08-scraper-timeout-python3-baseline.md" \
  "docs/plans/2026-06-08-safe-diamond-parsing-baseline.md" \
  "docs/plans/2026-06-09-scraper-argument-validation.md" \
  "docs/plans/2026-06-09-scraper-endpoint-validation.md" \
  "docs/plans/2026-06-09-scraper-finite-argument-validation.md" \
  "docs/plans/2026-06-09-output-helper-validation.md" \
  "docs/plans/2026-06-09-boolean-numeric-field-validation.md" \
  "docs/plans/2026-06-10-ci-baseline.md" \
  "docs/plans/2026-06-12-checkout-credential-boundary.md" \
  "docs/plans/2026-06-10-scraper-response-limit.md" \
  "docs/plans/2026-06-12-001-fix-exact-integer-fields-plan.md" \
  "docs/plans/2026-06-12-scraper-range-work-limit.md" \
  "docs/plans/2026-06-13-scraper-strict-response-utf8.md" \
  "docs/plans/2026-06-13-scraper-response-origin.md" \
  "docs/plans/2026-06-13-model-input-row-validation.md" \
  "docs/plans/2026-06-14-make-root-override-protection.md" \
  "docs/plans/2026-06-15-001-fix-pagination-boundary-plan.md" \
  "docs/plans/2026-06-15-scraper-nonnegative-result-total.md" \
  "docs/plans/2026-06-15-graph-cli-validation.md" \
  "docs/plans/2026-06-16-graph-category-range-validation.md" \
  "docs/plans/2026-06-16-model-category-range-validation.md" \
  "docs/plans/2026-06-25-atomic-prediction-pdf-design.md" \
  "docs/plans/2026-06-25-atomic-prediction-pdf.md" \
  "docs/plans/2026-06-09-output-path-validation.md"; do
  require_file "$path"
done

if ! grep -Fq "COLOR_RANGE = (1, 6)" "$MODEL_DOMAIN" ||
  ! grep -Fq "CLARITY_RANGE = (1, 8)" "$MODEL_DOMAIN" ||
  ! grep -Fq "def supports_model_categories(color, clarity):" "$MODEL_DOMAIN" ||
  ! grep -Fq "from model_domain import supports_model_categories" "$PARSER" ||
  ! grep -Fq "if not supports_model_categories(record['color'], record['clarity']):" "$PARSER"; then
  printf '%s\n' "Conversion and model loading must share one category domain." >&2
  exit 1
fi

if ! grep -Fq "EXPECTED_FIELD_COUNT = 10" "$MODEL_INPUT" ||
  ! grep -Fq "from model_domain import CLARITY_RANGE, COLOR_RANGE" "$MODEL_INPUT" ||
  ! grep -Fq "def bounded_positive_int(value, field_name, allowed_range):" "$MODEL_INPUT" ||
  ! grep -Fq "bounded_positive_int(fields[3], 'color', COLOR_RANGE)" "$MODEL_INPUT" ||
  ! grep -Fq "bounded_positive_int(fields[4], 'clarity', CLARITY_RANGE)" "$MODEL_INPUT" ||
  ! grep -Fq "len(fields) != EXPECTED_FIELD_COUNT" "$MODEL_INPUT" ||
  ! grep -Fq "math.isfinite(number)" "$MODEL_INPUT" ||
  ! grep -Fq "number <= 0" "$MODEL_INPUT" ||
  ! grep -Fq "{0}:{1}: {2}" "$MODEL_INPUT" ||
  ! grep -Fq "model input must contain at least one row" "$MODEL_INPUT"; then
  printf '%s\n' "Model input rows must keep exact shape, numeric, and diagnostic validation." >&2
  exit 1
fi

for model_test in \
  "test_staged_prediction_pdf_atomically_replaces_existing_output" \
  "test_staged_prediction_pdf_preserves_existing_output_on_failure" \
  "test_staged_prediction_pdf_rejects_empty_output" \
  "test_graph_prediction_args_accept_none_or_four_valid_values" \
  "test_graph_prediction_args_reject_partial_and_extra_values" \
  "test_graph_prediction_args_reject_invalid_numeric_values" \
  "test_graph_prediction_output_rejects_nonfinite_and_negative_values" \
  "test_graph_prediction_output_accepts_zero_boundary" \
  "test_graph_rejects_invalid_prediction_args_before_input_or_rpy2" \
  "test_parse_model_row_returns_typed_model_fields" \
  "test_model_rows_accept_category_boundaries" \
  "test_rejects_out_of_range_model_categories" \
  "test_rejects_truncated_and_extra_rows" \
  "test_rejects_non_finite_carat" \
  "test_rejects_non_positive_model_values" \
  "test_rejects_non_integer_model_categories" \
  "test_load_model_rows_reports_path_and_line" \
  "test_load_model_rows_reports_out_of_range_category_line" \
  "test_load_model_rows_rejects_blank_rows" \
  "test_load_model_rows_rejects_empty_file" \
  "test_graph_rejects_invalid_input_before_rpy2_import"; do
  if ! grep -Fq "$model_test" "$MODEL_INPUT_TESTS"; then
    printf '%s\n' "Model input tests must retain case: $model_test" >&2
    exit 1
  fi
done

for prediction_pdf_contract in \
  "def staged_prediction_pdf(destination):" \
  "output_directory = os.path.realpath(os.path.dirname(destination) or '.')" \
  "destination = os.path.join(output_directory, output_name)" \
  "dir=output_directory," \
  "if os.path.getsize(staged_path) == 0:" \
  "os.fsync(staged_file.fileno())" \
  "os.replace(staged_path, destination)" \
  "os.unlink(staged_path)" \
  "with staged_prediction_pdf('prediction.pdf') as staged_pdf:" \
  "ro.r.pdf(staged_pdf)" \
  "ro.r('dev.off()')"; do
  if ! grep -Fq "$prediction_pdf_contract" "$GRAPH"; then
    printf '%s\n' "graph.py must retain atomic prediction PDF contract: $prediction_pdf_contract" >&2
    exit 1
  fi
done

if ! grep -Fq '$(ROOT)scripts/test-prediction-pdf-atomic.sh' "$MAKEFILE" ||
  ! grep -Fq '$(ROOT)scripts/test-prediction-pdf-atomic-mutations.sh' "$MAKEFILE"; then
  printf '%s\n' "Make test must retain atomic prediction PDF verification." >&2
  exit 1
fi

if ! grep -Fq "output is staged beside the destination" "$README" ||
  ! grep -Fq "Publish model PDFs with same-directory atomic replacement" "$VISION" ||
  ! grep -Fq 'prediction.pdf` must be staged, checked as nonempty, and atomically replaced' "$ROOT_DIR/AGENTS.md" ||
  ! grep -Fq "Published prediction PDFs only after same-directory staging" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Maintained guidance must document atomic prediction PDF publication." >&2
  exit 1
fi

prediction_pdf_status=$(sed -n 's/^\*\*Status:\*\* //p' "$PREDICTION_PDF_PLAN")
case "$prediction_pdf_status" in
  "Pending hosted verification")
    if ! grep -Fq "Exact-head hosted checks remain pending." "$PREDICTION_PDF_PLAN"; then
      printf '%s\n' "Pending prediction PDF plan must record pending hosted checks." >&2
      exit 1
    fi
    ;;
  Completed)
    for prediction_pdf_evidence in \
      "Exact-head hosted Check and CodeQL passed." \
      "eight hostile atomic prediction PDF mutations were rejected"; do
      if ! grep -Fq "$prediction_pdf_evidence" "$PREDICTION_PDF_PLAN"; then
        printf '%s\n' "Completed prediction PDF plan must retain evidence: $prediction_pdf_evidence" >&2
        exit 1
      fi
    done
    ;;
  *)
    printf '%s\n' "Prediction PDF plan must be pending hosted verification or completed." >&2
    exit 1
    ;;
esac

if ! grep -Fq "No R model or prediction PDF execution is claimed." "$PREDICTION_PDF_PLAN"; then
  printf '%s\n' "Prediction PDF plan must retain the local R runtime nonclaim." >&2
  exit 1
fi

for graph_cli_contract in \
  "def parse_prediction_args(argv):" \
  "from model_input import CLARITY_RANGE, COLOR_RANGE, load_model_rows" \
  "def validate_category(value, field_name, allowed_range):" \
  "if len(argv) != 5:" \
  "math.isfinite(carat)" \
  "math.isfinite(price)" \
  "validate_category(color, 'color', COLOR_RANGE)" \
  "validate_category(clarity, 'clarity', CLARITY_RANGE)" \
  "def validate_prediction_price(value):" \
  "not math.isfinite(number) or number < 0" \
  "prediction_args = parse_prediction_args(argv)" \
  "ypred = validate_prediction_price("; do
  if ! grep -Fq "$graph_cli_contract" "$GRAPH"; then
    printf '%s\n' "graph.py must retain CLI validation contract: $graph_cli_contract" >&2
    exit 1
  fi
done

if [ "$(grep -c '^status: completed$' "$MODEL_CATEGORY_RANGE_PLAN")" -ne 1 ]; then
  printf '%s\n' "Model category range plan must record completed status exactly once." >&2
  exit 1
fi
for model_category_evidence in \
  'focused model/graph tests passed' \
  'external-directory make check passed' \
  'isolated hostile mutations were rejected' \
  'Exact diff' \
  '20729749d2dda535db8285c7b2f38a5af658a3b2' \
  'push run `27645252397`' \
  'pull-request run `27645266318`'; do
  if ! grep -Fq "$model_category_evidence" "$MODEL_CATEGORY_RANGE_PLAN"; then
    printf '%s\n' "Model category range plan must preserve completed evidence: $model_category_evidence" >&2
    exit 1
  fi
done

for graph_category_test in \
  "for color, clarity in ((1, 1), (4, 5), (6, 8)):" \
  "['graph.py', '0.75', '7', '5', '1250']" \
  "['graph.py', '0.75', '4', '9', '1250']" \
  "prediction color must be between 1 and 6"; do
  if ! grep -Fq "$graph_category_test" "$MODEL_INPUT_TESTS"; then
    printf '%s\n' "Graph tests must retain category boundary contract: $graph_category_test" >&2
    exit 1
  fi
done

if [ ! -f "$GRAPH_CLI_PLAN" ] || \
  ! grep -Fq "status: completed" "$GRAPH_CLI_PLAN" || \
  ! grep -Fq "## Status: Completed" "$GRAPH_CLI_PLAN" || \
  ! grep -Fq "make check" "$GRAPH_CLI_PLAN" || \
  ! grep -Fq "hostile mutations were rejected" "$GRAPH_CLI_PLAN" || \
  ! grep -Fq "R/rpy2 model execution was not exercised" "$GRAPH_CLI_PLAN"; then
  printf '%s\n' "Graph CLI validation plan must record completed verification." >&2
  exit 1
fi

if [ "$(grep -c '^status: completed$' "$GRAPH_CATEGORY_RANGE_PLAN")" -ne 1 ]; then
  printf '%s\n' "Graph category range plan must record completed status exactly once." >&2
  exit 1
fi
for graph_category_evidence in \
  'focused model/graph tests passed' \
  'external-directory make check passed' \
  'Six isolated hostile mutations were rejected' \
  'Exact diff'; do
  if ! grep -Fq "$graph_category_evidence" "$GRAPH_CATEGORY_RANGE_PLAN"; then
    printf '%s\n' "Graph category range plan must preserve completed evidence: $graph_category_evidence" >&2
    exit 1
  fi
done

if ! grep -Fq "graph prediction arguments require exactly four finite-positive values" "$README" || \
  ! grep -Fq "Graph prediction arguments must be validated before model input or R execution" "$ROOT_DIR/SECURITY.md" || \
  ! grep -Fq "Validate graph prediction arguments before model execution" "$VISION" || \
  ! grep -Fq "Validated graph prediction CLI values before model input and R execution" "$ROOT_DIR/CHANGES.md" || \
  ! grep -Fq '`graph.py` must validate optional prediction arguments before model input or rpy2' "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Project guidance must document graph CLI validation." >&2
  exit 1
fi

for graph_category_doc in "$README" "$VISION" "$ROOT_DIR/SECURITY.md" "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fqi "color 1 through 6" "$graph_category_doc" ||
    ! grep -Fqi "clarity 1 through 8" "$graph_category_doc"; then
    printf '%s\n' "Maintained guidance must document graph category ranges: $graph_category_doc" >&2
    exit 1
  fi
done

for model_category_doc in "$README" "$VISION" "$ROOT_DIR/SECURITY.md" "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fqi "training rows" "$model_category_doc" ||
    ! grep -Fqi "color 1 through 6" "$model_category_doc" ||
    ! grep -Fqi "clarity 1 through 8" "$model_category_doc"; then
    printf '%s\n' "Maintained guidance must document model-row category ranges: $model_category_doc" >&2
    exit 1
  fi
done

load_marker='rows = load_model_rows("output.csv")'
rpy_marker='    import rpy2'
if [ "$(grep -Fc "$load_marker" "$GRAPH")" -ne 1 ] ||
  [ "$(grep -Fxc "$rpy_marker" "$GRAPH")" -ne 1 ]; then
  printf '%s\n' "graph.py must retain one validated input load and deferred rpy2 import." >&2
  exit 1
fi
load_line=$(grep -nF "$load_marker" "$GRAPH" | cut -d: -f1)
rpy_line=$(grep -nFx "$rpy_marker" "$GRAPH" | cut -d: -f1)
if [ -z "$load_line" ] || [ -z "$rpy_line" ] || [ "$load_line" -ge "$rpy_line" ]; then
  printf '%s\n' "graph.py must validate output.csv before loading rpy2." >&2
  exit 1
fi
parse_line=$(grep -nF "prediction_args = parse_prediction_args(argv)" "$GRAPH" | cut -d: -f1)
if [ -z "$parse_line" ] || [ "$parse_line" -ge "$load_line" ]; then
  printf '%s\n' "graph.py must validate prediction arguments before opening model input." >&2
  exit 1
fi

if ! grep -Fq "validates every output.csv row" "$README" ||
  ! grep -Fq "Validate generated model rows before R execution" "$VISION" ||
  ! grep -Fq "Validated generated model rows" "$ROOT_DIR/CHANGES.md" ||
  ! grep -Fq "producer's exact ten-field shape" "$ROOT_DIR/AGENTS.md" ||
  ! grep -Fq "R2. Every row must contain exactly ten comma-separated fields." "$MODEL_INPUT_PLAN"; then
  printf '%s\n' "Model input validation documentation and plan contracts must remain checked in." >&2
  exit 1
fi

for model_plan_contract in \
  "status: completed" \
  "## Status: Completed" \
  "make verify" \
  "9 tests" \
  "isolated hostile mutations were rejected" \
  "No R model or PDF execution is claimed"; do
  if ! grep -Fq "$model_plan_contract" "$MODEL_INPUT_PLAN"; then
    printf '%s\n' "Model input plan must record completed verification: $model_plan_contract" >&2
    exit 1
  fi
done

workflow_count=$(find "$ROOT_DIR/.github/workflows" -type f \( -name '*.yml' -o -name '*.yaml' \) | wc -l | tr -d ' ')
checkout_count=$(grep -Ec '^[[:space:]]*-[[:space:]]*uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10' "$CI_WORKFLOW" || true)
credential_boundary_count=$(grep -Ec '^[[:space:]]*persist-credentials:[[:space:]]*false([[:space:]]|$)' "$CI_WORKFLOW" || true)
if [ "$workflow_count" -ne 1 ] || [ "$checkout_count" -ne 1 ] || [ "$credential_boundary_count" -ne 1 ]; then
  printf '%s\n' "GitHub Actions must keep one workflow with one pinned, credential-free checkout." >&2
  exit 1
fi

if ! grep -Fq "actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$CI_WORKFLOW" ||
  ! grep -Fq "actions/setup-python@a309ff8b426b58ec0e2a45f0f869d46889d02405" "$CI_WORKFLOW" ||
  ! grep -Fq 'python-version: ["3.10", "3.12", "3.14"]' "$CI_WORKFLOW" ||
  ! grep -Fq "run: make check" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions workflow must pin actions and run make check across supported Python releases." >&2
  exit 1
fi

if ! grep -Fq "permissions:" "$CI_WORKFLOW" || ! grep -Fq "contents: read" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions workflow must keep repository access read-only." >&2
  exit 1
fi

if ! grep -Fq "workflow_dispatch:" "$CI_WORKFLOW" || ! grep -Fq "timeout-minutes: 5" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions workflow must support bounded manual verification." >&2
  exit 1
fi

if ! grep -Fq "runs-on: ubuntu-24.04" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions must use the stable Ubuntu 24.04 runner." >&2
  exit 1
fi

if ! grep -Fq 'ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' "$MAKEFILE" ||
  [ "$(grep -o '\$(ROOT)' "$MAKEFILE" | wc -l | tr -d ' ')" -ne 15 ]; then
  printf '%s\n' "Make verification must resolve scripts and Python files from the repository root." >&2
  exit 1
fi

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
  ! grep -Fq "test_rejects_boolean_numeric_fields" "$TESTS" || \
  ! grep -Fq "test_rejects_boolean_integer_fields" "$TESTS" || \
  ! grep -Fq "test_rejects_fractional_integer_fields" "$TESTS" || \
  ! grep -Fq "test_rejects_non_finite_integer_fields_as_value_errors" "$TESTS" || \
  ! grep -Fq "test_accepts_integral_float_integer_fields" "$TESTS" || \
  ! grep -Fq "test_rejects_non_positive_price" "$TESTS" || \
  ! grep -Fq "test_rejects_non_positive_vendor_id" "$TESTS"; then
  printf '%s\n' "Parser tests must cover invalid numeric model inputs." >&2
  exit 1
fi

if ! grep -Fq "math.isfinite" "$PARSER" || ! grep -Fq "def positive_int" "$PARSER"; then
  printf '%s\n' "csv.py must validate finite positive numeric model inputs." >&2
  exit 1
fi

if ! grep -Fq "value.is_integer()" "$PARSER" ||
  ! grep -Fq "except (TypeError, ValueError, OverflowError)" "$PARSER"; then
  printf '%s\n' "csv.py must reject fractional or non-finite float values in integer fields." >&2
  exit 1
fi

if ! grep -Fq "isinstance(value, bool)" "$PARSER"; then
  printf '%s\n' "csv.py must reject boolean literals for numeric model inputs." >&2
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

if ! grep -Fq "GitHub Actions" "$README" ||
  ! grep -Fq "docs/plans/2026-06-10-ci-baseline.md" "$README" ||
  ! grep -Fq "GitHub Actions" "$VISION" ||
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project docs must record the GitHub Actions CI baseline." >&2
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

if ! grep -Fxq 'override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' "$MAKEFILE"; then
  printf '%s\n' "Makefile must protect its repository root from caller overrides." >&2
  exit 1
fi

for plan_contract in \
  'status: completed' \
  '## Status: Completed' \
  '## Work Completed' \
  '## Verification Completed' \
  'Python 3.12.8 and Python 3.14.0' \
  'Three isolated hostile mutations were rejected'; do
  if ! grep -Fq "$plan_contract" "$MAKE_ROOT_PLAN"; then
    printf '%s\n' "Make-root plan must keep completed evidence: $plan_contract" >&2
    exit 1
  fi
done

for required_model_path in "$ROOT_DIR/MODEL_VERIFICATION.md" "$MODEL_VERIFICATION_PLAN"; do
  if [ ! -f "$required_model_path" ]; then
    printf '%s\n' "Required model verification file is missing: ${required_model_path#"$ROOT_DIR/"}" >&2
    exit 1
  fi
done

for model_contract in \
  'commit SHA and pull request' \
  'source permits the planned access' \
  'Source terms review' \
  'Live HTTPS source' \
  'Bounded scrape' \
  'Atomic dataset publication' \
  'Dataset provenance' \
  'Model row validation' \
  'R/rpy2 environment' \
  'Deterministic evaluation split' \
  'Model fit' \
  'Holdout accuracy' \
  'Residual review' \
  'Prediction PDF' \
  'Reproducible rerun' \
  'Do not convert `not run` into passing evidence.' \
  'scraped proprietary rows, account data, source cookies' \
  'every source, dataset, R, model, metric, residual, and artifact row as unexecuted'; do
  if ! grep -Fq "$model_contract" "$ROOT_DIR/MODEL_VERIFICATION.md"; then
    printf '%s\n' "Model checklist must keep contract: $model_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'MODEL_VERIFICATION.md' "$README" || \
   ! grep -Fq 'explicit unexecuted rows' "$README" || \
   ! grep -Fq 'diamond model verification matrix' "$VISION" || \
   ! grep -Fq 'kept explicitly unexecuted' "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' 'Project guidance must document the unexecuted model matrix.' >&2
  exit 1
fi

for model_plan_contract in \
  'Status: Completed' \
  'make check' \
  'hostile mutations' \
  'No live PriceScope access, R/rpy2 environment, model fit, evaluation metrics, residual review, prediction PDF, or reproducibility run was executed'; do
  if ! grep -Fq "$model_plan_contract" "$MODEL_VERIFICATION_PLAN"; then
    printf '%s\n' "Model verification plan must keep completion evidence: $model_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "ast.literal_eval" "$README"; then
  printf '%s\n' "README must document the safe parsing baseline." >&2
  exit 1
fi

if ! grep -Fq "finite positive" "$README"; then
  printf '%s\n' "README must document numeric field validation." >&2
  exit 1
fi

if ! grep -Fq "boolean literals" "$README"; then
  printf '%s\n' "README must document boolean numeric field rejection." >&2
  exit 1
fi

if ! grep -Fq "exact positive integers" "$README"; then
  printf '%s\n' "README must document exact integer field validation." >&2
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

if ! grep -Fq "non-finite or non-positive carat values and timeouts" "$README"; then
  printf '%s\n' "README must document finite scraper argument validation." >&2
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

if ! grep -Fq "Validate scraper numeric arguments as finite values" "$VISION"; then
  printf '%s\n' "VISION.md must keep finite scraper argument validation visible." >&2
  exit 1
fi

if ! grep -Fq "Reject boolean literals in numeric diamond fields" "$VISION"; then
  printf '%s\n' "VISION.md must keep boolean numeric field validation visible." >&2
  exit 1
fi

if ! grep -Fq "Require vendor IDs and prices to be exact positive integers" "$VISION"; then
  printf '%s\n' "VISION.md must keep exact integer field validation visible." >&2
  exit 1
fi

if ! grep -Fq "Bound each scraper invocation to a narrow carat span" "$VISION"; then
  printf '%s\n' "VISION.md must keep bounded scraper work visible." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$RANGE_WORK_LIMIT_PLAN" ||
  ! grep -Fq "make check" "$RANGE_WORK_LIMIT_PLAN"; then
  printf '%s\n' "Scraper range work-limit plan must remain completed and verified." >&2
  exit 1
fi

if ! grep -Fq "Exact Integer Field Validation" "$EXACT_INTEGER_PLAN" ||
  ! grep -Fq "scripts/test-safe-parsing.py" "$EXACT_INTEGER_PLAN"; then
  printf '%s\n' "Exact integer field plan must document parser regression coverage." >&2
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

if ! grep -Fq "Status: Completed" "$FINITE_SCRAPER_ARG_PLAN"; then
  printf '%s\n' "Finite scraper argument validation plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$FINITE_SCRAPER_ARG_PLAN"; then
  printf '%s\n' "Finite scraper argument validation plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$BOOLEAN_NUMERIC_PLAN"; then
  printf '%s\n' "Boolean numeric field validation plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$BOOLEAN_NUMERIC_PLAN"; then
  printf '%s\n' "Boolean numeric field validation plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$CI_PLAN" ||
  ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "CI baseline plan must be completed and record make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$CHECKOUT_CREDENTIAL_PLAN" ||
  ! grep -Fq "make check" "$CHECKOUT_CREDENTIAL_PLAN"; then
  printf '%s\n' "Checkout credential boundary plan must record completed make check verification." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$RESPONSE_LIMIT_PLAN" ||
  ! grep -Fq "make check" "$RESPONSE_LIMIT_PLAN"; then
  printf '%s\n' "Scraper response limit plan must be completed and record verification." >&2
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

response_origin_body=$(awk '/^def response_origin\(url\):/ { capture = 1 } /^def validate_response_origin\(request_url, response_url\):/ { exit } capture { print }' "$ROOT_DIR/psdownload.py")
for origin_contract in \
  'parsed.scheme.lower() != "https"' \
  'or not parsed.hostname' \
  'parsed.username or parsed.password' \
  'port = parsed.port or 443'; do
  if ! printf '%s\n' "$response_origin_body" | grep -Fq "$origin_contract"; then
    printf '%s\n' "psdownload.py response_origin must keep contract: $origin_contract" >&2
    exit 1
  fi
done

for origin_contract in \
  'def response_origin(url):' \
  'def validate_response_origin(request_url, response_url):' \
  'validate_response_origin(url, response.geturl())' \
  'response origin was not trusted'; do
  if ! grep -Fq "$origin_contract" "$ROOT_DIR/psdownload.py"; then
    printf '%s\n' "psdownload.py must keep response-origin contract: $origin_contract" >&2
    exit 1
  fi
done

origin_validation_line=$(grep -nF 'validate_response_origin(url, response.geturl())' "$ROOT_DIR/psdownload.py" | cut -d: -f1)
response_read_line=$(grep -nF 'payload = response.read(MAX_RESPONSE_BYTES + 1)' "$ROOT_DIR/psdownload.py" | cut -d: -f1)
if [ -z "$origin_validation_line" ] || [ -z "$response_read_line" ] ||
  [ "$origin_validation_line" -ge "$response_read_line" ]; then
  printf '%s\n' "Response origin validation must run before reading the body." >&2
  exit 1
fi

if ! grep -Fq "MAX_RESPONSE_BYTES = 2 * 1024 * 1024" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "response.read(MAX_RESPONSE_BYTES + 1)" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "len(payload) > MAX_RESPONSE_BYTES" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must bound each remote page response before decoding." >&2
  exit 1
fi

if ! grep -Fq 'decoded = payload.decode("utf-8")' "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "except UnicodeDecodeError:" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "response was not valid UTF-8" "$ROOT_DIR/psdownload.py" ||
  grep -Fq 'decode("utf-8", "replace")' "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must reject malformed UTF-8 pages without replacement decoding." >&2
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

if ! grep -Fq "MAX_CARAT_SPAN = 0.5" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "max_carat - min_carat > MAX_CARAT_SPAN" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "next_value <= current" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "Scraper ranges must keep bounded spans and advancing steps." >&2
  exit 1
fi

if ! grep -Fq "math.isfinite(min_carat)" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "math.isfinite(max_carat)" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "math.isfinite(timeout)" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "psdownload.py must reject non-finite scraper arguments before scraping." >&2
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

if ! grep -Fq "test_parse_args_rejects_excessive_carat_span" "$SCRAPER_TESTS" ||
  ! grep -Fq "test_drange_rejects_invalid_or_non_advancing_steps" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover bounded spans and non-advancing steps." >&2
  exit 1
fi

if ! grep -Fq "test_parse_args_rejects_non_finite_carat_ranges" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover non-finite carat range arguments." >&2
  exit 1
fi

if ! grep -Fq "test_parse_args_rejects_non_positive_timeout" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover non-positive timeout arguments." >&2
  exit 1
fi

if ! grep -Fq "test_parse_args_rejects_non_finite_timeout" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover non-finite timeout arguments." >&2
  exit 1
fi

if ! grep -Fq "test_collect_diamonds_validates_arguments_before_network" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover direct helper argument validation." >&2
  exit 1
fi

if ! grep -Fq "RESULTS_PER_PAGE = 25" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "RESULTS_PER_PAGE * (page - 1) >= total_for_query" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "Scraper pagination must stop at exact 25-row result boundaries." >&2
  exit 1
fi

for pagination_test in \
  "test_collect_diamonds_stops_at_exact_page_boundaries" \
  "test_collect_diamonds_requests_a_positive_partial_page" \
  "test_collect_diamonds_keeps_bounded_fallback_for_malformed_total" \
  "requested_pages_for_total"; do
  if ! grep -Fq "$pagination_test" "$SCRAPER_TESTS"; then
    printf '%s\n' "Scraper tests must retain pagination request-count coverage: $pagination_test" >&2
    exit 1
  fi
done

if ! grep -Fq "stops pagination at exact 25-row result boundaries" "$README" ||
  ! grep -Fq "Avoid redundant scraper page requests at exact result boundaries" "$VISION" ||
  ! grep -Fq "Stopped redundant PriceScope page requests at exact 25-row result boundaries" "$ROOT_DIR/CHANGES.md" ||
  ! grep -Fq "must stop at exact reported result boundaries" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "must not request a page whose start offset equals the reported result total" "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Project guidance must record the exact pagination boundary." >&2
  exit 1
fi

for pagination_plan_contract in \
  'status: completed' \
  '## Status: Completed' \
  '## Work Completed' \
  '## Verification Completed' \
  'hostile mutations were rejected' \
  'Live PriceScope access was not executed'; do
  if ! grep -Fq "$pagination_plan_contract" "$PAGINATION_BOUNDARY_PLAN"; then
    printf '%s\n' "Pagination boundary plan must keep completed evidence: $pagination_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "return total if total >= 0 else fallback" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "Scraper result totals must reject negative cardinalities." >&2
  exit 1
fi

for result_total_test in \
  "test_parse_total_accepts_zero_and_rejects_negative_counts" \
  "test_collect_diamonds_keeps_bounded_fallback_for_negative_total"; do
  if ! grep -Fq "$result_total_test" "$SCRAPER_TESTS"; then
    printf '%s\n' "Scraper tests must retain result-total integrity case: $result_total_test" >&2
    exit 1
  fi
done

if ! grep -Fq "rejects negative reported result totals" "$README" || \
  ! grep -Fq "Reject negative upstream result totals" "$VISION" || \
  ! grep -Fq "Rejected negative PriceScope result totals" "$ROOT_DIR/CHANGES.md" || \
  ! grep -Fq "Reported scraper result totals must never be negative" "$ROOT_DIR/SECURITY.md" || \
  ! grep -Fq "must reject negative reported result totals" "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Project guidance must record nonnegative scraper result totals." >&2
  exit 1
fi

for result_total_plan_contract in \
  'status: completed' \
  '## Status: Completed' \
  '## Work Completed' \
  '## Verification Completed' \
  'hostile mutations were rejected' \
  'Live PriceScope access was not executed'; do
  if ! grep -Fq "$result_total_plan_contract" "$NONNEGATIVE_TOTAL_PLAN"; then
    printf '%s\n' "Nonnegative result-total plan must keep completed evidence: $result_total_plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "test_parse_args_rejects_blank_output_path" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover blank output path arguments." >&2
  exit 1
fi

if ! grep -Fq "test_write_diamonds_rejects_blank_output_path" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover direct helper output path validation." >&2
  exit 1
fi

if ! grep -Fq "tempfile.mkstemp(" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "dir=output_directory" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "diamond_file.flush()" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "os.fsync(diamond_file.fileno())" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "os.replace(temporary_path, destination)" "$ROOT_DIR/psdownload.py" ||
  ! grep -Fq "os.unlink(temporary_path)" "$ROOT_DIR/psdownload.py"; then
  printf '%s\n' "Scraper output must use same-directory durable staging and atomic replacement." >&2
  exit 1
fi

if ! grep -Fq "test_write_diamonds_atomically_replaces_output_in_destination_directory" "$SCRAPER_TESTS" ||
  ! grep -Fq "test_write_diamonds_preserves_output_when_record_conversion_fails" "$SCRAPER_TESTS" ||
  ! grep -Fq "test_write_diamonds_preserves_output_when_atomic_replace_fails" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover atomic output, failure preservation, and cleanup." >&2
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

if ! grep -Fq "test_read_lines_accepts_bounded_utf8_response" "$SCRAPER_TESTS" ||
  ! grep -Fq "test_read_lines_rejects_oversized_response" "$SCRAPER_TESTS" ||
  ! grep -Fq "test_read_lines_rejects_malformed_utf8_response" "$SCRAPER_TESTS" ||
  ! grep -Fq "caf\\u00e9 \\u6771\\u4eac" "$SCRAPER_TESTS" ||
  ! grep -Fq "self.assertNotIn('private-tail', output.getvalue())" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover bounded, oversized, and malformed UTF-8 page responses." >&2
  exit 1
fi

if ! grep -Fq "test_read_lines_rejects_untrusted_response_origins_before_body_read" "$SCRAPER_TESTS" ||
  ! grep -Fq "test_response_origin_normalizes_default_https_port" "$SCRAPER_TESTS" ||
  ! grep -Fq "self.assertEqual(response.read_calls, 0)" "$SCRAPER_TESTS" ||
  ! grep -Fq "https://other.test/redirected" "$SCRAPER_TESTS" ||
  ! grep -Fq "http://example.test/redirected" "$SCRAPER_TESTS" ||
  ! grep -Fq "https://example.test:444/redirected" "$SCRAPER_TESTS" ||
  ! grep -Fq "https://user:secret@example.test/redirected" "$SCRAPER_TESTS" ||
  ! grep -Fq "https://example.test:invalid/redirected" "$SCRAPER_TESTS" ||
  ! grep -Fq "https://example.test:443/redirected?next=1" "$SCRAPER_TESTS"; then
  printf '%s\n' "Scraper tests must cover same-origin and pre-read redirect rejection." >&2
  exit 1
fi

if ! grep -Fq "strict UTF-8" "$README" ||
  ! grep -Fq "Rejected malformed UTF-8" "$ROOT_DIR/CHANGES.md" ||
  ! grep -Fq "Reject malformed UTF-8" "$VISION" ||
  ! grep -Fq "strict UTF-8" "$ROOT_DIR/SECURITY.md"; then
  printf '%s\n' "Project docs must record strict scraper response decoding." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$STRICT_RESPONSE_UTF8_PLAN" ||
  ! grep -Fq "Python 3.12.8 and Python 3.14.0" "$STRICT_RESPONSE_UTF8_PLAN" ||
  ! grep -Fq "Eleven hostile mutations were rejected" "$STRICT_RESPONSE_UTF8_PLAN" ||
  ! grep -Fq "no live PriceScope" "$STRICT_RESPONSE_UTF8_PLAN"; then
  printf '%s\n' "Strict response UTF-8 plan must record completed local verification and network limits." >&2
  exit 1
fi

if ! grep -Fq "atomic replacement" "$README" ||
  ! grep -Fq "Published scraper output atomically" "$ROOT_DIR/CHANGES.md" ||
  ! grep -Fq "Publish scraper output atomically" "$VISION" ||
  ! grep -Fq "atomic replacement" "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Project docs must record atomic scraper output publication." >&2
  exit 1
fi

if [ "$(grep -Fc "final response origin" "$README")" -ne 2 ] ||
  ! grep -Fq "final scraper response" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "Validated final scraper response origins" "$ROOT_DIR/CHANGES.md" ||
  ! grep -Fq "Validate final scraper response origins" "$VISION" ||
  ! grep -Fq "final response origin" "$ROOT_DIR/AGENTS.md"; then
  printf '%s\n' "Project docs must record final scraper response-origin validation." >&2
  exit 1
fi

for plan_contract in \
  'status: completed' \
  '## Status: Completed' \
  '## Work Completed' \
  '## Verification Completed' \
  'Python 3.12.8 and Python 3.14.0' \
  'Ten isolated hostile mutations were rejected'; do
  if ! grep -Fq "$plan_contract" "$RESPONSE_ORIGIN_PLAN"; then
    printf '%s\n' "Response-origin plan must keep completed evidence: $plan_contract" >&2
    exit 1
  fi
done

if ! grep -Fq "status: completed" "$ATOMIC_OUTPUT_PLAN" ||
  ! grep -Fq "Python 3.12.8 and Python 3.14.0" "$ATOMIC_OUTPUT_PLAN" ||
  ! grep -Fq "hostile mutations were rejected" "$ATOMIC_OUTPUT_PLAN" ||
  ! grep -Fq "no live PriceScope" "$ATOMIC_OUTPUT_PLAN"; then
  printf '%s\n' "Atomic output plan must record completed local verification and network limits." >&2
  exit 1
fi

for ignored in "diamonds.txt" "prediction.pdf"; do
  if ! grep -Fq "$ignored" "$ROOT_DIR/.gitignore"; then
    printf '%s\n' ".gitignore must ignore generated $ignored" >&2
    exit 1
  fi
done

python3 -m py_compile "$PARSER" "$TESTS" "$SCRAPER_TESTS" "$ROOT_DIR/psdownload.py" "$MODEL_DOMAIN" "$MODEL_INPUT" "$ROOT_DIR/graph.py" "$ROOT_DIR/lm.py"
python3 "$TESTS"
python3 "$SCRAPER_TESTS"

printf '%s\n' "Diamond safe parsing baseline checks passed."
