"""
OpenClaw 会话分析模块
从 .openclaw 导出对话记录为 Markdown 格式
"""

import os
import json
from datetime import datetime
from pathlib import Path
from typing import Optional

OPENCLAW_DIR = Path.home() / ".openclaw"
OUTPUT_DIR = Path(__file__).parent.parent.parent / "data" / "agent" / "openclaw" / "sessions"


def load_session(session_path: Path) -> Optional[dict]:
    """加载单个会话文件"""
    messages = []
    meta = {}

    with open(session_path, "r", encoding="utf-8") as f:
        for line in f:
            if not line.strip():
                continue
            try:
                event = json.loads(line)
                if event.get("type") == "session":
                    meta = {
                        "id": event.get("id"),
                        "timestamp": event.get("timestamp"),
                        "cwd": event.get("cwd"),
                    }
                messages.append(event)
            except json.JSONDecodeError:
                continue

    if not meta:
        return None

    return {"meta": meta, "messages": messages}


def parse_message(msg: dict) -> dict:
    """解析单条消息"""
    msg_type = msg.get("type")
    result = {
        "id": msg.get("id"),
        "timestamp": msg.get("timestamp"),
        "type": msg_type,
    }

    if msg_type == "message":
        content = msg.get("message", {})
        result["role"] = content.get("role")
        result["content"] = extract_content(content.get("content", []))
        result["stop_reason"] = content.get("stopReason")
        result["error"] = content.get("errorMessage")

    elif msg_type == "toolCall":
        result["tool"] = msg.get("name")
        result["arguments"] = msg.get("arguments")

    elif msg_type == "toolResult":
        result["tool"] = msg.get("toolName")
        result["content"] = extract_content(msg.get("content", []))
        result["is_error"] = msg.get("isError")

    elif msg_type == "model_change":
        result["provider"] = msg.get("provider")
        result["model"] = msg.get("modelId")

    return result


def extract_content(content_list: list) -> str:
    """从内容列表提取文本"""
    if not content_list:
        return ""

    texts = []
    for item in content_list:
        if isinstance(item, dict):
            if item.get("type") == "text":
                texts.append(item.get("text", ""))
            elif item.get("type") == "toolUse":
                texts.append(f"[Tool: {item.get('name')}]")
        elif isinstance(item, str):
            texts.append(item)

    return "\n".join(texts)


def format_timestamp(ts: str) -> str:
    """格式化时间戳"""
    if not ts:
        return ""
    try:
        dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        return dt.strftime("%Y-%m-%d %H:%M")
    except ValueError:
        return ts


def format_session(session: dict) -> str:
    """将会话格式化为 Markdown"""
    meta = session["meta"]
    messages = session["messages"]

    # 提取关键信息
    session_id = meta.get("id", "unknown")
    start_time = format_timestamp(meta.get("timestamp"))
    cwd = meta.get("cwd", "")

    # 提取模型信息
    model_info = None
    for msg in messages:
        if msg.get("type") == "model_change":
            model_info = f"{msg.get('modelId')} ({msg.get('provider')})"
            break

    # 构建对话表格
    rows = []
    tool_calls = []
    errors = []

    for msg in messages:
        parsed = parse_message(msg)
        ts = format_timestamp(parsed.get("timestamp", ""))

        if parsed["type"] == "message":
            role = parsed.get("role", "")
            content = parsed.get("content", "")
            error = parsed.get("error")

            if role == "user":
                role_icon = "👤"
                role_name = "用户"
            elif role == "assistant":
                role_icon = "🤖"
                role_name = "AI"
            else:
                role_icon = "📎"
                role_name = role

            # 处理错误
            if error:
                content = f"⏱️ {error}"
                errors.append(f"- {ts}: {error}")
            elif not content:
                content = "(空回复)"

            # 截断过长内容
            if len(content) > 200:
                content = content[:200] + "..."

            rows.append(f"| {ts} | {role_icon} {role_name} | {content} |")

        elif parsed["type"] == "toolCall":
            tool = parsed.get("tool")
            args = parsed.get("arguments", "")
            if isinstance(args, dict):
                args = json.dumps(args, ensure_ascii=False)[:100]
            tool_calls.append(f"- `{tool}`: {args}")

    # 生成 Markdown
    md = []
    md.append(f"# 会话: {session_id}")
    md.append("")
    md.append(f"**开始时间**: {start_time}")
    if cwd:
        md.append(f"**工作目录**: `{cwd}`")
    if model_info:
        md.append(f"**模型**: {model_info}")
    md.append("")

    # 对话
    md.append("---")
    md.append("")
    md.append("## 对话")
    md.append("")
    md.append("| 时间 | 角色 | 内容 |")
    md.append("|------|------|------|")
    md.extend(rows)
    md.append("")

    # 工具调用
    if tool_calls:
        md.append("---")
        md.append("")
        md.append("## 工具调用")
        md.append("")
        md.extend(tool_calls)
        md.append("")

    # 错误
    if errors:
        md.append("---")
        md.append("")
        md.append("## 错误")
        md.append("")
        md.extend(errors)
        md.append("")

    return "\n".join(md)


def export_session(session_path: Path, output_dir: Path) -> Path:
    """导出会话到文件"""
    session = load_session(session_path)
    if not session:
        return None

    meta = session["meta"]
    session_id = meta.get("id", "unknown")
    timestamp = meta.get("timestamp", "")

    # 生成文件名
    try:
        dt = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
        date_str = dt.strftime("%Y-%m-%d")
    except ValueError:
        date_str = "unknown"

    filename = f"{date_str}_{session_id[:8]}.md"
    output_path = output_dir / filename

    # 写入文件
    content = format_session(session)
    output_path.write_text(content, encoding="utf-8")

    return output_path


def export_all(agent: str = "dev") -> list[Path]:
    """导出所有会话"""
    sessions_dir = OPENCLAW_DIR / "agents" / agent / "sessions"
    if not sessions_dir.exists():
        print(f"目录不存在: {sessions_dir}")
        return []

    # 获取所有会话文件
    session_files = sorted(
        sessions_dir.glob("*.jsonl"),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )

    exported = []
    for session_file in session_files:
        if session_file.name == "sessions.json":
            continue

        output_path = export_session(session_file, OUTPUT_DIR)
        if output_path:
            exported.append(output_path)
            print(f"导出: {output_path.name}")

    return exported


def generate_index(sessions: list[Path]) -> Path:
    """生成索引文件"""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    lines = ["# OpenClaw 会话索引", ""]

    for session_file in sessions:
        # 读取文件获取元信息
        content = session_file.read_text(encoding="utf-8")
        lines.append(f"- [{session_file.stem}]({session_file.name})")

    index_path = OUTPUT_DIR / "index.md"
    index_path.write_text("\n".join(lines), encoding="utf-8")

    return index_path


def main():
    print(f"OpenClaw 会话导出工具")
    print(f"=" * 40)
    print(f"源目录: {OPENCLAW_DIR}")
    print(f"输出目录: {OUTPUT_DIR}")
    print()

    # 导出 dev 代理的会话
    exported = export_all(agent="dev")

    if exported:
        # 生成索引
        index_path = generate_index(exported)
        print(f"\n索引: {index_path.name}")
        print(f"共导出 {len(exported)} 个会话")
    else:
        print("未找到会话文件")


if __name__ == "__main__":
    main()
