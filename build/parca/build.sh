#!/usr/bin/env bash
# Build the patched Parca server image for the local platform and load it into the local Docker daemon.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TAG="${PARCA_IMAGE_TAG:?PARCA_IMAGE_TAG is not set; run through mise}"

echo "Building Parca image: local/parca:$TAG..."
docker buildx build \
  -f "$ROOT/build/parca/Dockerfile" \
  --build-arg "VERSION=$TAG" \
  -t "local/parca:$TAG" \
  --load \
  "$ROOT/third_party/parca"
echo "Built Parca image: local/parca:$TAG"
