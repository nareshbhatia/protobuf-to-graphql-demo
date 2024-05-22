
# binary builds Go application binaries, including canonical linker and build flags.
.PHONY: binary
binary:
	@scripts/build.sh binary

# clean removes any previously created build artifacts.
.PHONY: clean
clean:
	@scripts/build.sh clean
