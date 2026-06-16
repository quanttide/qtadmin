#!/bin/bash
# Add Flutter to PATH if available
[ -d "$HOME/flutter/bin" ] && PATH="$HOME/flutter/bin:$PATH"
cd "$(cd "$(dirname "$0")" && pwd)"
dart pub get 2>&1 | tail -3
dart run build_runner build --delete-conflicting-outputs 2>&1
