#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

python3 "$ROOT_DIR/scripts/test-model-input.py"

python3 - "$ROOT_DIR/graph.py" <<'PY'
from pathlib import Path
import sys

source = Path(sys.argv[1]).read_text(encoding='utf-8')

required = (
    'def staged_prediction_pdf(destination):',
    "output_directory = os.path.realpath(os.path.dirname(destination) or '.')",
    'destination = os.path.join(output_directory, output_name)',
    'tempfile.mkstemp(',
    'dir=output_directory,',
    "if os.path.getsize(staged_path) == 0:",
    "raise ValueError('prediction PDF must be nonempty')",
    "with open(staged_path, 'rb+') as staged_file:",
    'os.fsync(staged_file.fileno())',
    'os.replace(staged_path, destination)',
    'os.unlink(staged_path)',
    "with staged_prediction_pdf('prediction.pdf') as staged_pdf:",
    'ro.r.pdf(staged_pdf)',
)
for contract in required:
    if contract not in source:
        raise SystemExit('Missing atomic prediction PDF contract: {0}'.format(contract))

with_start = source.index("with staged_prediction_pdf('prediction.pdf') as staged_pdf:")
pdf_open = source.index('ro.r.pdf(staged_pdf)', with_start)
plot = source.index('ro.r.plot(', pdf_open)
finally_block = source.index('        finally:', plot)
device_close = source.index("ro.r('dev.off()')", finally_block)
if not (with_start < pdf_open < plot < finally_block < device_close):
    raise SystemExit('R PDF staging and device-close ordering changed')

print('Atomic prediction PDF contract passed.')
PY
