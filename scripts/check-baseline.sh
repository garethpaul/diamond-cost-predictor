#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PSDOWNLOAD="$ROOT_DIR/psdownload.py"

if ! grep -Fq 'DEFAULT_PRICESCOPE_AJAX_URL = "https://www.pricescope.com/results/ajax/"' "$PSDOWNLOAD"; then
  printf '%s\n' "psdownload.py must default to the HTTPS Pricescope AJAX endpoint." >&2
  exit 1
fi

if grep -Fq '"http://www.pricescope.com/results/ajax/?"' "$PSDOWNLOAD"; then
  printf '%s\n' "psdownload.py must not use the old plain-HTTP endpoint." >&2
  exit 1
fi

if ! grep -Fq 'PRICESCOPE_AJAX_URL' "$PSDOWNLOAD"; then
  printf '%s\n' "psdownload.py must expose an environment endpoint override." >&2
  exit 1
fi

if ! grep -Fq 'endpoint.lower().startswith("https://")' "$PSDOWNLOAD"; then
  printf '%s\n' "psdownload.py must reject non-HTTPS configured endpoints." >&2
  exit 1
fi

if ! grep -Fq 'urllib.urlencode(query)' "$PSDOWNLOAD"; then
  printf '%s\n' "psdownload.py must build request URLs with urllib.urlencode." >&2
  exit 1
fi

if ! grep -Fq 'except IOError as e' "$PSDOWNLOAD"; then
  printf '%s\n' "psdownload.py must surface download I/O failures." >&2
  exit 1
fi

if ! grep -Fq 'PRICESCOPE_AJAX_URL' "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the configurable endpoint." >&2
  exit 1
fi

printf '%s\n' "Diamond downloader baseline checks passed."
