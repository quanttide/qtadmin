#!/bin/bash
#
# Ollama 安装脚本入口
# 用法: ./install_ollama.sh
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PYTHON_SCRIPT="$PROJECT_DIR/examples/ollama_install.py"

if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "错误: 找不到 $PYTHON_SCRIPT"
    exit 1
fi

echo "调用 Python 安装脚本..."
python3 "$PYTHON_SCRIPT" "$@"
