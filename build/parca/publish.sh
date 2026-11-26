#!/usr/bin/env bash
# Build the patched Parca server image for linux/amd64 and linux/arm64 and push it to GHCR.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
IMAGE="${PARCA_IMAGE:?PARCA_IMAGE is not set; run through mise}"
TAG="${PARCA_IMAGE_TAG:?PARCA_IMAGE_TAG is not set; run through mise}"

echo "Publishing Parca image $IMAGE:$TAG..."
docker buildx build --platform linux/amd64,linux/arm64 \
  -f "$ROOT/build/parca/Dockerfile" \
  --build-arg "VERSION=$TAG" \
  -t "$IMAGE:$TAG" \
  -t "$IMAGE:latest" \
  --push \
  "$ROOT/third_party/parca"
