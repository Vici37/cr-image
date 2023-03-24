test:
	crystal spec --profile --rand --error-trace

benchmark:
	crystal run scripts/benchmark.cr --release

.PHONY: docs
docs:
	crystal doc src/docs.cr --project-name="Crystal Image" --source-refname=$(shell git rev-parse HEAD)
