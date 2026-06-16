#!/usr/bin/env python3
"""
量潮招聘数据统计脚本

使用 lark-cli 获取 HR 邮箱投递数据，统计岗位分布和投递趋势。

用法：
    python3 stats.py                    # 统计本月数据
    python3 stats.py --days 7           # 统计最近 7 天
    python3 stats.py --start 2026-06-01 --end 2026-06-16
"""

import json
import subprocess
import sys
from collections import defaultdict
from datetime import datetime, timedelta


def fetch_all_mailbox():
    """获取 HR 邮箱所有邮件"""
    msgs = []
    token = None
    for _ in range(20):
        cmd = [
            "lark-cli",
            "mail",
            "+triage",
            "--mailbox",
            "hr@quanttide.com",
            "--max",
            "50",
            "--format",
            "json",
        ]
        if token:
            cmd.extend(["--page-token", token])
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
        if r.returncode != 0:
            break
        data = json.loads(r.stdout)
        batch = data.get("messages", [])
        if not batch:
            break
        msgs.extend(batch)
        token = data.get("page_token")
        if not token:
            break
    return msgs


def classify(subject):
    """根据邮件主题判断岗位分类"""
    if not subject:
        return None
    if (
        "技术实习生" in subject
        or "技术实习" in subject
        or "后端开发" in subject
        or "AI应用" in subject
    ):
        if "全栈" in subject or "后端" in subject or "AI应用" in subject:
            return "全栈工程师"
        return "数据工程师"
    if "新媒体运营" in subject or ("运营" in subject and "数据" not in subject):
        return "新媒体运营"
    if "商务" in subject or "BD" in subject:
        return "商务经理"
    if "PM" in subject or "项目经理" in subject:
        return "项目经理"
    if "产品" in subject:
        return "产品经理"
    if "课程助教" in subject or "助教" in subject:
        return "课程助教"
    if "销售" in subject:
        return "销售经理"
    if "HR" in subject or "人力资源" in subject:
        return "人事经理"
    if "数据" in subject:
        return "数据工程师"
    return None


def filter_by_date(msgs, start_date=None, end_date=None):
    """按日期范围过滤"""
    if not start_date and not end_date:
        # 默认本月
        now = datetime.now()
        start_date = now.replace(day=1).strftime("%Y-%m-%d")
        end_date = now.strftime("%Y-%m-%d")

    result = []
    for m in msgs:
        date_str = m.get("date", "")[:10]
        if start_date and date_str < start_date:
            continue
        if end_date and date_str > end_date:
            continue
        result.append(m)
    return result


def print_report(msgs, title):
    """打印报告"""
    total = len(msgs)
    positions = defaultdict(int)
    unnamed = 0
    daily = defaultdict(int)

    for m in msgs:
        subj = m.get("subject", "").strip()
        if not subj:
            unnamed += 1
        cat = classify(subj)
        if cat:
            positions[cat] += 1
        else:
            unnamed += 1
        date_str = m.get("date", "")[:10]
        daily[date_str] += 1

    identified = total - unnamed

    print(f"# {title}")
    print()
    print(f"{total} 封投递。")
    print(
        f"其中可识别岗位 {identified} 封（{identified * 100 // total}%），其余为自动回复、空主题等。"
    )
    print()

    print("## 岗位分布")
    print()
    print("| 岗位 | 人数 |")
    print("|------|------|")
    for p, n in sorted(positions.items(), key=lambda x: -x[1]):
        print(f"| {p} | {n} |")
    print()

    print("## 投递趋势")
    print()
    print("| 日期 | 投递数 |")
    print("|------|--------|")
    for d in sorted(daily.keys()):
        print(f"| {d} | {daily[d]} |")
    print()


if __name__ == "__main__":
    print_report(fetch_all_mailbox(), "量潮招聘数据统计")
