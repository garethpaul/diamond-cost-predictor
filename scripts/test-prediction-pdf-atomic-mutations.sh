#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/prediction-pdf-atomic.XXXXXX")

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT HUP INT TERM

mkdir "$TMP_DIR/candidate"
(cd "$ROOT_DIR" && tar --exclude=.git -cf - .) | (cd "$TMP_DIR/candidate" && tar -xf -)

if ! "$TMP_DIR/candidate/scripts/test-prediction-pdf-atomic.sh" >"$TMP_DIR/control.out" 2>&1; then
  printf '%s\n' "Unmodified candidate failed the atomic prediction PDF contract." >&2
  cat "$TMP_DIR/control.out" >&2
  exit 1
fi

expect_rejected() {
  name=$1
  old=$2
  new=$3

  rm -rf "$TMP_DIR/repo"
  cp -R "$TMP_DIR/candidate" "$TMP_DIR/repo"
  python3 - "$TMP_DIR/repo/graph.py" "$old" "$new" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
old = sys.argv[2]
new = sys.argv[3]
source = path.read_text(encoding='utf-8')
if old not in source:
    raise SystemExit('Mutation source was not found: {0}'.format(old))
path.write_text(source.replace(old, new, 1), encoding='utf-8')
PY

  if "$TMP_DIR/repo/scripts/test-prediction-pdf-atomic.sh" >"$TMP_DIR/$name.out" 2>&1; then
    printf '%s\n' "Hostile atomic prediction PDF mutation was accepted: $name" >&2
    cat "$TMP_DIR/$name.out" >&2
    exit 1
  fi

  printf '%s\n' "Rejected hostile atomic prediction PDF mutation: $name"
}

expect_rejected cross-directory-staging 'dir=output_directory,' 'dir=None,'
expect_rejected followed-destination-symlink "output_directory = os.path.realpath(os.path.dirname(destination) or '.')" 'output_directory = os.path.dirname(os.path.realpath(destination))'
expect_rejected empty-output-accepted 'if os.path.getsize(staged_path) == 0:' 'if os.path.getsize(staged_path) < 0:'
expect_rejected missing-durable-flush 'os.fsync(staged_file.fileno())' 'staged_file.flush()'
expect_rejected non-atomic-publication 'os.replace(staged_path, destination)' 'os.rename(staged_path, destination)'
expect_rejected leaked-staging-file 'os.unlink(staged_path)' 'print(staged_path)'
expect_rejected direct-destination-write 'ro.r.pdf(staged_pdf)' "ro.r.pdf('prediction.pdf')"
expect_rejected missing-device-finally '        finally:' '        except Exception:'

printf '%s\n' "Atomic prediction PDF hostile mutation tests passed."
