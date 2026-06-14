#!/bin/bash
# Add Flutter to PATH if available
[ -d "$HOME/flutter/bin" ] && PATH="$HOME/flutter/bin:$PATH"
cd "$(cd "$(dirname "$0")" && pwd)"
dart test 2>&1
