#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
export CLANG_MODULE_CACHE_PATH="$ROOT_DIR/.build/module-cache"
mkdir -p "$CLANG_MODULE_CACHE_PATH"

BIN_PATH=$(swift build --show-bin-path)
exec "$BIN_PATH/App"
