## ubuntu base images
- [bazel.Dockerfile](bazel.Dockerfile): `tradingai/bazel:latest`
  - ubuntu
  - golang
  - python
  - bazel
- [bazel.gpu.Dockerfile](bazel.gpu.Dockerfile): `tradingai/bazel:gpu-latest`
  - nvidia/cuda
  - golang
  - python
  - bazel

## machine learning dev images
- [ml.Dockerfile](ml.Dockerfile): `tradingai/ml:latest`
  - ubuntu
  - golang
  - python
  - bazel
  - mpi
  - pytorch
  - tensorflow
  - tensorboard
- [ml.gpu.Dockerfile](ml.gpu.Dockerfile): `tradingai/ml:gpu-latest`
  - nvidia/cuda
  - golang
  - python
  - bazel
  - pytorch
  - tensorflow
  - tensorboard
