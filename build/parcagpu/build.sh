#!/usr/bin/env bash
# Build the patched parcagpu image from upstream's Dockerfile runtime stage for the local platform and load it into the local Docker daemon.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TAG="${PARCAGPU_IMAGE_TAG:?PARCAGPU_IMAGE_TAG is not set; run through mise}"

echo "Building parcagpu image: local/parcagpu:$TAG..."
docker buildx build \
  -f "$ROOT/third_party/parcagpu/Dockerfile" \
  --target runtime \
  --build-arg "PARCAGPU_VERSION=$TAG" \
  --label "org.opencontainers.image.source=https://github.com/simonepri/parca-patches" \
  --label "org.opencontainers.image.description=parcagpu with upstream fixes applied as patches." \
  --label "org.opencontainers.image.licenses=Apache-2.0" \
  -t "local/parcagpu:$TAG" \
  --load \
  "$ROOT/third_party/parcagpu"
echo "Built parcagpu image: local/parcagpu:$TAG"
