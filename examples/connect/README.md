# 飞书群联系人搜索与通知

**Notice** 是 **Message** 的子集——Message 是通用聊天内容，Notice 是管理方对全体的单向知会。

```bash
# 一键发送（按群名和姓名搜索）
./send_notice.sh --chat "量潮科技" --at "刘婧怡" --notice "通知内容"

# 或直接指定 ID 跳过搜索
./send_notice.sh --chat oc_xxx --at ou_xxx --notice "通知内容"
```
