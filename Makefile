.PHONY: lint test verify check

PYTHON ?= python3

lint:
	./scripts/check-baseline.sh

test:
	$(PYTHON) scripts/test-safe-parsing.py
	$(PYTHON) scripts/test-psdownload.py

verify: lint test

check: verify
