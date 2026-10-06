#!/bin/sh
# Builds a self-contained macOS arm64 tarball.
#
# The canvas prebuilt addon ships its dylibs next to canvas.node and
# loads them via @loader_path. Bun extracts canvas.node to a temp dir
# at runtime, so the launcher points DYLD_LIBRARY_PATH at lib/.
#
# Usage:
#   sh scripts/build-macos.sh
#
# Output: dist/excalirender-darwin-arm64.tar.gz

set -eu

if [ "$(uname -s)" != "Darwin" ] || [ "$(uname -m)" != "arm64" ]; then
    echo "error: must run on macOS arm64" >&2
    exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CANVAS_RELEASE="$ROOT/node_modules/canvas/build/Release"
STAGING="$ROOT/dist/staging/excalirender"
OUT="$ROOT/dist/excalirender-darwin-arm64.tar.gz"

cd "$ROOT"

if [ ! -f "$CANVAS_RELEASE/canvas.node" ]; then
    echo "error: canvas.node missing, run 'bun install'" >&2
    exit 1
fi

rm -rf "$ROOT/dist/staging" "$OUT"
mkdir -p "$STAGING/bin" "$STAGING/lib"

bun build --compile --target=bun-darwin-arm64 ./src/index.ts \
    --outfile "$STAGING/bin/excalirender.bin"

cp "$CANVAS_RELEASE"/*.dylib "$STAGING/lib/"

cat > "$STAGING/bin/excalirender" <<'EOF'
#!/bin/sh
set -e
SELF="$(readlink -f "$0")"
SCRIPT_DIR="$(cd "$(dirname "$SELF")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
export DYLD_LIBRARY_PATH="$BASE_DIR/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"
exec "$SCRIPT_DIR/excalirender.bin" "$@"
EOF
chmod +x "$STAGING/bin/excalirender" "$STAGING/bin/excalirender.bin"

tar czf "$OUT" -C "$ROOT/dist/staging" excalirender
rm -rf "$ROOT/dist/staging"

echo "Built $OUT"
