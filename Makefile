PROJECT_ROOT_DIR := $(shell git rev-parse --show-toplevel)

# Help
.PHONY: default
default:
	@echo "Please specify a build target. The choices are:"
	@echo "    init:               Perform a one-time initialization"
	@echo "    binary:             Create Go binaries"
	@echo "    clean:              Clean build directory"
	@echo "    proto-gen:          Regenerate protobuf files"
	@echo "    proto-lint:         Lint protobuf files"
	@echo "    proto-fmt:          Format protobuf files"
	@echo "    proto-mod:          Update buf modules"
	@echo "    proto-bcd:          Runs breaking change detection for your protos"
	@echo "    fmt:                Format all Go code"
	@echo "    lint:               Run lint checks"
	@echo "    test:               Run unit tests"
	@echo "    test-e2e:           Run end-to-end tests"
	@echo "    release-dry-run:    Release dry run"
	@false

.PHONY: init
init:
	@echo "Initializing project..."
	@go get github.com/golang/protobuf@v1.5.4
	@make proto-mod
	@make proto-fmt
	@make proto-gen
	@go mod tidy
	@go test ./...
	@echo -e "\n# Ignore buf cache directory\n.cache/" >> .gitignore

# Include all sub-makefiles
include mk/*
