#!/bin/bash
# Add Flutter to PATH if available
[ -d "$HOME/flutter/bin" ] && export PATH="$HOME/flutter/bin:$PATH"
cd "$(cd "$(dirname "$0")" && pwd)"
flutter pub get 2>&1 | tail -3
flutter pub run build_runner build --delete-conflicting-outputs 2>&1 | tail -5
echo "---BUILD DONE---"
flutter test 2>&1 | tail -20
