test:
	crystal spec --profile --rand --error-trace

benchmark:
	crystal run scripts/benchmark.cr --release --no-debug