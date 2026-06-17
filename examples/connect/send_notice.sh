#!/usr/bin/env bash
set -euo pipefail

# 发送飞书群通知并 @ 指定成员
# 用法:
#   ./send_notice.sh --chat "群名" --at "姓名" --notice "通知内容"
#   ./send_notice.sh --chat oc_xxx --at ou_xxx --notice "通知内容"

usage() {
  echo "用法: $0 --chat <群名|chat_id> --at <姓名|open_id> --notice <通知内容>"
  exit 1
}

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --chat)   CHAT="$2"; shift 2 ;;
    --at)     AT_USER="$2"; shift 2 ;;
    --notice) NOTICE="$2"; shift 2 ;;
    *) usage ;;
  esac
done

[[ -z "${CHAT:-}" || -z "${AT_USER:-}" || -z "${NOTICE:-}" ]] && usage

# 解析 chat_id
if [[ "$CHAT" =~ ^oc_ ]]; then
  CHAT_ID="$CHAT"
else
  echo "-> 搜索群: $CHAT"
  RESULT=$(lark-cli im +chat-search --query "$CHAT" --as user 2>/dev/null)
  CHAT_ID=$(echo "$RESULT" | jq -r '.data.chats[0].chat_id // empty')
  if [[ -z "$CHAT_ID" ]]; then
    echo "! 未找到群，尝试列出所有群..."
    CHAT_ID=$(lark-cli im +chat-list --as user 2>/dev/null | jq -r ".data.chats[] | select(.name==\"$CHAT\") | .chat_id" | head -1)
  fi
  [[ -z "$CHAT_ID" ]] && { echo "错误: 未找到群 '$CHAT'"; exit 1; }
fi

# 解析 open_id
if [[ "$AT_USER" =~ ^ou_ ]]; then
  OPEN_ID="$AT_USER"
else
  echo "-> 搜索成员: $AT_USER"
  OPEN_ID=$(lark-cli contact +search-user --query "$AT_USER" --as user 2>/dev/null | jq -r '.data.users[0].open_id // empty')
  [[ -z "$OPEN_ID" ]] && { echo "错误: 未找到成员 '$AT_USER'"; exit 1; }
fi

# 发送消息
echo "-> 发送通知至: $(lark-cli im +chat-list --as user 2>/dev/null | jq -r ".data.chats[] | select(.chat_id==\"$CHAT_ID\") | .name // \"$CHAT_ID\"")"
lark-cli im +messages-send \
  --chat-id "$CHAT_ID" \
  --markdown "<at user_id=\"$OPEN_ID\"></at>\n\n$NOTICE" \
  --as user > /dev/null

echo "✓ 已发送"
