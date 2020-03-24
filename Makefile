build_bazel:
	docker build -f bazel.Dockerfile -t tradingai/bazel:latest .

build_bazel_gpu:
	docker build -f bazel.gpu.Dockerfile -t tradingai/bazel:gpu-latest .

build_ml:
	docker build -f ml.Dockerfile -t tradingai/ml:latest .

build_ml_gpu:
	docker build -f ml.gpu.Dockerfile -t tradingai/ml:gpu-latest .
