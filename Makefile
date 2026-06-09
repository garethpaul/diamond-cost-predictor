.PHONY: build lint test verify check

PYTHON ?= python3

lint:
	./scripts/check-baseline.sh

test:
	$(PYTHON) scripts/test-safe-parsing.py
	$(PYTHON) scripts/test-psdownload.py

build:
	$(PYTHON) -m py_compile csv.py psdownload.py graph.py lm.py scripts/test-safe-parsing.py scripts/test-psdownload.py

verify: lint test build

check: verify
