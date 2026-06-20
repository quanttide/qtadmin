#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
STUDIO_DIR="$PROJECT_DIR/src/studio"

echo "Building Linux bundle..."
cd "$STUDIO_DIR"
flutter build linux

echo ""
echo "Running..."
exec ./build/linux/x64/release/bundle/qtadmin-studio
