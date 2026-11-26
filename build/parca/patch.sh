#!/usr/bin/env bash
# Clone the pinned upstream Parca release into third_party/parca and apply patches/parca on top of it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
UPSTREAM="${PARCA_UPSTREAM:?PARCA_UPSTREAM is not set; run through mise}"
TARGET="$ROOT/third_party/parca"
PATCH_DIR="$ROOT/patches/parca"

if [ ! -d "$TARGET/.git" ]; then
  mkdir -p "$ROOT/third_party"
  echo "Cloning Parca $UPSTREAM..."
  git -c advice.detachedHead=false clone --depth 1 --branch "$UPSTREAM" https://github.com/parca-dev/parca.git "$TARGET"
fi

cd "$TARGET"
stamp=".git/applied-patches"
shopt -s nullglob
patches=("$PATCH_DIR"/*.patch)
shopt -u nullglob

want=$( (printf "%s\n" "$UPSTREAM"; cat ${patches[@]+"${patches[@]}"}) | git hash-object --stdin)

if [ -f "$stamp" ] && [ "$(cat "$stamp")" = "$want" ]; then
  echo "Patches already applied to third_party/parca"
  exit 0
fi

if [ -f "$stamp" ] || [ -n "$(git status --porcelain)" ]; then
  echo "third_party/parca has other patches or local changes; delete it to re-apply" >&2
  exit 1
fi

for p in ${patches[@]+"${patches[@]}"}; do
  echo "Applying patch $(basename "$p")..."
  git apply --whitespace=nowarn "$p"
done

echo "$want" > "$stamp"
echo "Parca patches successfully applied."
