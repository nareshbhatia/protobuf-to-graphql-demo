# Lint Install Binary installs golangci-lint locally to:
# $(go env GOPATH)/bin/golangci-lint
# Local installation is optional, as this will fallback to the docker installation
.PHONY: lint-install-binary
lint-install-binary:
	@scripts/build.sh lint-install-binary

.PHONY: lint
lint:
	@scripts/build.sh lint

.PHONY: lint-fix
lint-fix:
	@scripts/build.sh lint-fix

# Format all Go code
.PHONY: fmt
fmt:
	@scripts/build.sh fmt
