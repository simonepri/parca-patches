# Runs the no-GPU parcagpu unit tests that the patches add, with the same CUDA headers and build toolchain images as upstream's Dockerfile.
ARG CUDA_HEADERS=ghcr.io/parca-dev/cuda-headers:12
ARG BUILDER=ghcr.io/parca-dev/parcagpu-builder:24.04

FROM ${CUDA_HEADERS} AS cuda-headers

FROM ${BUILDER}
COPY --from=cuda-headers /usr/local/cuda /usr/local/cuda
WORKDIR /src
COPY . .
RUN make PARCAGPU_VERSION=test test-profiling-access
