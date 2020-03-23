build_bazel:
	docker build -f bazel.Dockerfile -t tradingai/bazel:latest .

build_bazel_gpu:
	docker build -f bazel.gpu.Dockerfile -t tradingai/bazel:gpu-latest .