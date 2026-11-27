#!/usr/bin/env bash
# Fetch the pinned upstream parcagpu commit and its proton submodule into third_party/parcagpu and apply patches/parcagpu on top of it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
UPSTREAM="${PARCAGPU_UPSTREAM:?PARCAGPU_UPSTREAM is not set; run through mise}"
TARGET="$ROOT/third_party/parcagpu"
PATCH_DIR="$ROOT/patches/parcagpu"

if [ ! -d "$TARGET/.git" ]; then
  mkdir -p "$TARGET"
  echo "Fetching parcagpu $UPSTREAM..."
  git -C "$TARGET" init --quiet
  git -C "$TARGET" remote add origin https://github.com/parca-dev/parcagpu.git
  git -C "$TARGET" fetch --quiet --depth 1 origin "$UPSTREAM"
  git -C "$TARGET" -c advice.detachedHead=false checkout --quiet FETCH_HEAD
  git -C "$TARGET" submodule update --init --recursive --depth 1
fi

cd "$TARGET"
stamp=".git/applied-patches"
shopt -s nullglob
patches=("$PATCH_DIR"/*.patch)
shopt -u nullglob

want=$( (printf "%s\n" "$UPSTREAM"; cat ${patches[@]+"${patches[@]}"}) | git hash-object --stdin)

if [ -f "$stamp" ] && [ "$(cat "$stamp")" = "$want" ]; then
  echo "Patches already applied to third_party/parcagpu"
  exit 0
fi

if [ -f "$stamp" ] || [ -n "$(git status --porcelain)" ]; then
  echo "third_party/parcagpu has other patches or local changes; delete it to re-apply" >&2
  exit 1
fi

for p in ${patches[@]+"${patches[@]}"}; do
  echo "Applying patch $(basename "$p")..."
  git apply --whitespace=nowarn "$p"
done

echo "$want" > "$stamp"
echo "parcagpu patches successfully applied."
