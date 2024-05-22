
# test runs unit tests.
.PHONY: test
test:
	@scripts/build.sh test

# test-e2e runs end-to-end tests.
.PHONY: test-e2e
test-e2e:
	@scripts/build.sh test-e2e

# test-e2e-coverage-report generates an end-to-end test coverage report
# given Go coverage data.
test-e2e-coverage-report:
	@scripts/build.sh test-e2e-coverage-report
