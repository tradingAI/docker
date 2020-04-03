![CI](https://github.com/tradingAI/docker/workflows/CI/badge.svg)
## 阿里云镜象加速
- [加速Dockerfiles](https://github.com/iminders/docker)
- [阿里云镜象搜索](https://cr.console.aliyun.com/cn-hangzhou/instances/images) `tradingai`
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
