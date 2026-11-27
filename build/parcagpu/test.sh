#!/usr/bin/env bash
# Run the patched parcagpu unit tests that need no GPU inside upstream's build toolchain image.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "Running parcagpu unit tests..."
docker buildx build \
  -f "$ROOT/build/parcagpu/test.Dockerfile" \
  --progress plain \
  "$ROOT/third_party/parcagpu"
