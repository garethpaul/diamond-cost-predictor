#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PSDOWNLOAD="$ROOT_DIR/psdownload.py"

if ! grep -Fq 'DOWNLOAD_TIMEOUT_SECONDS = 10' "$PSDOWNLOAD"; then
  printf '%s\n' "psdownload.py must define an explicit download timeout." >&2
  exit 1
fi

if ! grep -Fq 'urllib2.urlopen(url, timeout=DOWNLOAD_TIMEOUT_SECONDS)' "$PSDOWNLOAD"; then
  printf '%s\n' "psdownload.py must pass the timeout to urlopen." >&2
  exit 1
fi

if grep -Fq 'urllib.urlopen((' "$PSDOWNLOAD"; then
  printf '%s\n' "psdownload.py must not call urllib.urlopen without a timeout." >&2
  exit 1
fi

if ! grep -Fq 'except socket.timeout as e' "$PSDOWNLOAD"; then
  printf '%s\n' "psdownload.py must surface socket timeout failures." >&2
  exit 1
fi

if ! grep -Fq 'except urllib2.URLError as e' "$PSDOWNLOAD"; then
  printf '%s\n' "psdownload.py must surface urllib2 URL failures." >&2
  exit 1
fi

printf '%s\n' "Diamond downloader timeout baseline checks passed."
