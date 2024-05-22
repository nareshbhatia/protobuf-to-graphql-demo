.PHONY: proto-gen
proto-gen:
	@echo "--- Generating protobuf outputs..."
	@buf generate proto

.PHONY: proto-lint
proto-lint:
	@echo "--- Linting protobufs..."
	@buf lint proto

.PHONY: proto-mod
proto-mod:
	@echo "--- Updating buf modules..."
	@buf mod update proto

.PHONY: proto-fmt
proto-fmt:
	@echo "--- Formatting protobufs..."
	@buf format proto -w

.PHONY: proto-bcd
proto-bcd:
ifeq ($(strip $(DEFAULT_BRANCH)),)
	@echo "Please set push to remote branch to run breaking change detection."
	@exit 1
endif
	@echo "--- Checking for breaking changes against ${DEFAULT_BRANCH} branch..."
	@$(BCD_CMD); \
	if [ $$? -eq 0 ]; then \
		echo "  OK"; \
	else \
		$(BCD_CMD) 2>&1 | grep -q "Failure: no .proto target files found"; \
		if [ $$? -eq 0 ]; then \
			echo "  OK (no previous module)"; \
		else \
			echo "  FAIL"; \
			exit 1; \
		fi \
    fi
