#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
STUDIO_BIN="$PROJECT_DIR/src/studio/build/linux/x64/release/bundle/qtadmin-studio"
VIDEO_OUT="$PROJECT_DIR/assets/videos/studio.mp4"

WINFO_FILE="/tmp/studio_win.txt"

cleanup() {
  echo ""
  echo "Stopping..."
  pkill -f "qtadmin-studio" 2>/dev/null || true
  pkill -f "ffmpeg.*x11grab" 2>/dev/null || true
  xdotool mousemove 0 0 2>/dev/null || true
  rm -f "$WINFO_FILE"
}
trap cleanup EXIT

cleanup
sleep 1

echo "Starting studio..."
"$STUDIO_BIN" &
sleep 4

# Find content window
WID=$(xdotool search --name "量潮管理后台" 2>/dev/null | tail -1)
if [ -z "$WID" ]; then
  echo "ERROR: Cannot find content window" >&2
  exit 1
fi
echo "Content Window ID: $WID"
xdotool getwindowgeometry "$WID"
echo "Window name: $(xdotool getwindowname "$WID")"

# Save geometry
eval "$(xdotool getwindowgeometry --shell "$WID")"
echo "CONTENT_X=$X CONTENT_Y=$Y CONTENT_W=$WIDTH CONTENT_H=$HEIGHT"
echo "$X $Y $WIDTH $HEIGHT" > "$WINFO_FILE"

# Activate window
xdotool windowactivate --sync "$WID"
xdotool windowraise "$WID"
sleep 1

# Record only the window area (pad to even dimensions for libx264)
echo "Recording window area to $VIDEO_OUT..."
ffmpeg -y -f x11grab -video_size "${WIDTH}x${HEIGHT}" -i ":0.0+${X},${Y}" \
  -framerate 30 -vf "pad=ceil(iw/2)*2:ceil(ih/2)*2" \
  -c:v libx264 -preset ultrafast -crf 18 -pix_fmt yuv420p "$VIDEO_OUT" &
FFMPEG_PID=$!
sleep 2

# Re-activate
xdotool windowactivate --sync "$WID"
xdotool windowraise "$WID"
sleep 0.5

# === Precise layout (window-relative from source code) ===
# SizedBox(4) + TenantSwitcher(h=60) -> center at y=34
# Divider: Padding(v=4) + Divider(h=1) + Padding(v=4) -> h=9 total
# NavIcon: h=64 each, centers at y=105, 169, 233, 297, 361, 425, 489
SIDEBAR_CX=36
TS_Y=34
NAV1_Y=105  # 全景图
NAV2_Y=169  # 思考
NAV3_Y=233  # 写作
NAV4_Y=297  # 量潮数据
NAV5_Y=361  # 量潮课堂
NAV6_Y=425  # 量潮咨询
NAV7_Y=489  # 量潮云

click_win() {
  xdotool windowactivate --sync "$WID" 2>/dev/null || true
  xdotool mousemove --window "$WID" "$1" "$2" click 1
  sleep "$3"
}

# ===== Interactions =====

# --- 量潮创始人 ---
click_win "$SIDEBAR_CX" "$NAV1_Y" 2   # 全景图
click_win "$SIDEBAR_CX" "$NAV2_Y" 2   # 思考
click_win "$SIDEBAR_CX" "$NAV3_Y" 2   # 写作(placeholder)
click_win "$SIDEBAR_CX" "$NAV1_Y" 2   # 回全景图

# 切换租户: PopupMenu offset(0,48), trigger bottom at 64, menu starts at 112
click_win "$SIDEBAR_CX" "$TS_Y" 1     # 点击租户切换
click_win 80 184 2                     # 菜单项2: 量潮科技(约112-160+48)

# --- 量潮科技 ---
click_win "$SIDEBAR_CX" "$NAV1_Y" 2   # 全景图
click_win "$SIDEBAR_CX" "$NAV4_Y" 2   # 量潮数据
click_win "$SIDEBAR_CX" "$NAV5_Y" 2   # 量潮课堂
click_win "$SIDEBAR_CX" "$NAV1_Y" 2   # 回全景图

# 点击内容区决策卡片
for i in 1 2 3; do
  click_win 500 $((300 + i * 80)) 1.5
done

click_win "$SIDEBAR_CX" "$NAV2_Y" 2   # 思考
click_win "$SIDEBAR_CX" "$NAV1_Y" 2   # 回全景图

# 鼠标移开
xdotool windowactivate --sync "$WID"
xdotool mousemove --window "$WID" 1200 700
sleep 1

# Stop
echo "Stopping recording..."
kill "$FFMPEG_PID" 2>/dev/null || true
sleep 2

echo "Done! Video saved to $VIDEO_OUT"
