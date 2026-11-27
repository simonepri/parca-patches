#!/usr/bin/env bash
# Build the patched parcagpu image from upstream's Dockerfile runtime stage for linux/amd64 and linux/arm64 and push it to GHCR.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMAGE="${PARCAGPU_IMAGE:?PARCAGPU_IMAGE is not set; run through mise}"
TAG="${PARCAGPU_IMAGE_TAG:?PARCAGPU_IMAGE_TAG is not set; run through mise}"

echo "Publishing parcagpu image $IMAGE:$TAG..."
docker buildx build --platform linux/amd64,linux/arm64 \
  -f "$ROOT/third_party/parcagpu/Dockerfile" \
  --target runtime \
  --build-arg "PARCAGPU_VERSION=$TAG" \
  --label "org.opencontainers.image.source=https://github.com/simonepri/parca-patches" \
  --label "org.opencontainers.image.description=parcagpu with upstream fixes applied as patches." \
  --label "org.opencontainers.image.licenses=Apache-2.0" \
  -t "$IMAGE:$TAG" \
  -t "$IMAGE:latest" \
  --push \
  "$ROOT/third_party/parcagpu"
