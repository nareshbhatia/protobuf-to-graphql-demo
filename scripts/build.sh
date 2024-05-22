#!/bin/bash

# Setting shell options that ensure failures aren't hidden.
set -eo pipefail

# PROJECT_ROOT_DIR is the root directory of the repository.
PROJECT_ROOT_DIR="$(git rev-parse --show-toplevel)"
readonly PROJECT_ROOT_DIR

APP_NAME=protobuf-to-graphql-demo
APP_BUILDER_NAME=${APP_NAME}-builder

LINT_BASE_COMMAND=golangci-lint

# Disable cgo by default
# https://dave.cheney.net/2016/01/18/cgo-is-not-go
CGO_ENABLED=${CGO_ENABLED:-0}

# abort causes the script to return a non-zero exit code, printing a given error.
abort() {
  printf >&2 "\n--- Error: %s\n\n" "$*" && exit 1
}

# clean removes build artifacts.
function clean() {
  echo "--- Cleaning"
  rm -rf "${BIN_DIR}"
}

# verify_go_format verifies that Go code was previously formatted following recommended conventions.
function verify_go_format() {
  go_format
  echo "--- Verifying Go code was formatted..."

  fail_if_git_repo_unclean ./

  echo "--- Go code is already formatted!"
}

# go_format applies Go code formatting given recommended conventions.
function go_format() {
  echo "--- Formatting Go code..."

  command -v goimports &>/dev/null || go install golang.org/x/tools/cmd/goimports
  command -v gci &>/dev/null || go install github.com/daixiang0/gci@v0.11.2

  # Format Go code with goimports
  # Note that we exclude auto-generated files (protobuf, etc.)

  # -l: list files whose formatting differs from goimport's
  # -e: report all errors
  # -w: write result to (source) file instead of stdout
  find . -type f -name '*.go' -not -name '*.pb.go' -exec \
    goimports -l -e -w {} \;

  # github.com/daixiang0/gci
  { gci write --skip-generated --skip-vendor . 2>&1; } >/dev/null

  echo "--- Formatted Go code!"
}

# verify_go_mod_tidy verifies that 'go mod tidy' has been previously run
function verify_go_mod_tidy() {
  go_mod_tidy

  echo "--- Verifying that Go module file is clean..."
  fail_if_git_repo_unclean ./

  echo "--- Go module file is clean!"
}

# runs 'go mod tidy'
function go_mod_tidy() {
  go mod tidy
}

# Installs golangci binary
function lint_install_binary() {
  command -v go &>/dev/null || abort "go is required"
  GOPATH="$(command go env GOPATH)"

  command -v curl &>/dev/null || abort "curl is required"
  echo "--- Installing Lint binary ..."
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "${GOPATH}/bin" "${LINT_VERSION}"
}

function lint_fix() {
  echo "--- Linting with --fix ..."

  ${LINT_BASE_COMMAND} run ./... --fix
}

# Runs lint checks
function lint() {
  echo "--- Linting ..."

  ${LINT_BASE_COMMAND} run ./... -v --timeout 5m

  fail_if_git_repo_unclean ./

  echo "--- Successfully linted files!"
}

# go_unit_test runs unit tests via the 'go test' command with canonical options.
function go_unit_test() {
  command -v go &>/dev/null || abort "go is required"

  echo "--- Running unit tests..."
  go test \
    -v \
    -cover \
    -covermode=atomic \
    -coverprofile=coverage.unit.txt \
    -timeout 60s \
    -race \
    -short ./...
}

# go_e2e_test runs end-to-end tests via the 'go test' command with canonical options.
function go_e2e_test() {
  command -v go &>/dev/null || abort "go is required"

  echo "--- Running end-to-end tests..."
  go test -v -timeout 5m -race -cover -count=1 ./e2e --tags=e2e
}

# test-e2e-coverage-report generates an end-to-end test coverage report
# given Go coverage data.
function go_test_e2e_coverage_report() {
  echo "--- Generating end-to-end test coverage report..."
  go tool covdata textfmt -i=./coverage/integration -o coverage.e2e.txt
}

# Command & options input handler

while test $# -ne 0; do
  case "$1" in
  check-fmt)
    verify_go_format
    exit
    ;;
  go-mod-tidy)
    go_mod_tidy
    exit
    ;;
  check-go-mod-tidy)
    verify_go_mod_tidy
    exit
    ;;
  clean)
    clean
    exit
    ;;
  fmt)
    go_format
    exit
    ;;
  lint-install-binary)
    shift
    lint_install_binary
    exit
    ;;
  lint-fix)
    shift
    lint_fix
    exit
    ;;
  lint)
    shift
    lint
    exit
    ;;
  test)
    go_unit_test
    exit
    ;;
  test-e2e)
    go_e2e_test
    exit
    ;;
  test-e2e-coverage-report)
    go_test_e2e_coverage_report
    exit
    ;;
  *)
    abort "unknown command '$1'"
    ;;
  esac
  shift
done
