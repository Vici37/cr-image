test:
	crystal spec --profile --rand --error-trace

benchmark:
	crystal run scripts/benchmark.cr --release

.PHONY: docs
docs:
	crystal doc src/cr-image.cr
