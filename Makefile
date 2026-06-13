.PHONY: build lint test verify check

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PYTHON ?= python3

lint:
	$(ROOT)scripts/check-baseline.sh

test:
	$(PYTHON) $(ROOT)scripts/test-safe-parsing.py
	$(PYTHON) $(ROOT)scripts/test-psdownload.py
	$(PYTHON) $(ROOT)scripts/test-model-input.py

build:
	$(PYTHON) -m py_compile $(ROOT)csv.py $(ROOT)psdownload.py $(ROOT)model_input.py $(ROOT)graph.py $(ROOT)lm.py $(ROOT)scripts/test-safe-parsing.py $(ROOT)scripts/test-psdownload.py $(ROOT)scripts/test-model-input.py

verify: lint test build

check: verify
