test:
	crystal spec --profile --rand --error-trace

benchmark:
	crystal run bin/benchmark.cr --release --no-debug