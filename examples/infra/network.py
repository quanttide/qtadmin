"""
Network status analyzer - WiFi diagnostics and troubleshooting
"""

import argparse
import re
import subprocess
from typing import Optional

import psutil


def run_cmd(cmd: list[str], timeout: int = 10) -> tuple[str, str, int]:
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return result.stdout, result.stderr, result.returncode
    except subprocess.TimeoutExpired:
        return "", "Command timeout", 1
    except Exception as e:
        return "", str(e), 1


def get_wifi_interface() -> str:
    try:
        interfaces = psutil.net_if_addrs().keys()

        for iface in interfaces:
            if iface.startswith("wl") or iface.startswith("wlp"):
                result = subprocess.run(
                    ["nmcli", "-t", "-f", "DEVICE,STATE", "device", "status"],
                    capture_output=True,
                    text=True,
                    timeout=5,
                )
                if result.returncode == 0:
                    for line in result.stdout.strip().split("\n"):
                        parts = line.split(":")
                        if (
                            len(parts) >= 2
                            and parts[0] == iface
                            and parts[1] == "connected"
                        ):
                            return iface

        for iface in interfaces:
            if iface.startswith("wl") or iface.startswith("wlp"):
                return iface

        return ""
    except Exception:
        return ""


def check_wifi_signal() -> str:
    interface = get_wifi_interface()
    if not interface:
        return "未检测到无线网卡"
    stdout, _, _ = run_cmd(["iwconfig", interface])
    return stdout


def list_wifi_networks() -> str:
    stdout, _, _ = run_cmd(["nmcli", "device", "wifi", "list"])
    return stdout


def active_connections() -> str:
    stdout, _, _ = run_cmd(["nmcli", "connection", "show", "--active"])
    return stdout


def networkmanager_logs(minutes: int = 30) -> str:
    since = f"{minutes} min ago"
    stdout, _, _ = run_cmd(
        [
            "journalctl",
            "-u",
            "NetworkManager",
            "--since",
            since,
            "-g",
            "(disconnected|connected|supplicant|link down)",
        ]
    )
    return stdout


def check_common_issues() -> list[str]:
    interface = get_wifi_interface()
    issues = []

    if not interface:
        issues.append("未检测到无线网卡")
        return issues

    stdout, _, _ = run_cmd(["iwconfig", interface])

    retry_match = re.search(r"Retry.*?(\d+)", stdout)
    if retry_match:
        retry_count = int(retry_match.group(1))
        if retry_count > 10:
            issues.append(
                f"高重试次数 ({retry_count}) → 建议更换 WiFi 通道 (1, 6, 或 11)"
            )

    level_match = re.search(r"Signal level[=:]([-\d]+)", stdout)
    if level_match:
        signal = int(level_match.group(1))
        if signal <= -70:
            issues.append(f"弱信号 ({signal} dBm) → 建议移动设备或使用 WiFi 扩展器")

    return issues


def parse_signal_info() -> dict:
    interface = get_wifi_interface()
    info = {}

    if not interface:
        return info

    stdout, _, _ = run_cmd(["iwconfig", interface])

    if not stdout:
        return info

    essid_match = re.search(r'ESSID:"([^"]+)"', stdout)
    if essid_match:
        info["ssid"] = essid_match.group(1)

    freq_match = re.search(r"Frequency[:\s]+(\d+\.?\d*)\s*GHz", stdout)
    if freq_match:
        info["frequency"] = freq_match.group(1)

    bitrate_match = re.search(r"Bit Rate[=:]([\d.]+)\s*Mb/s", stdout)
    if bitrate_match:
        info["bitrate"] = bitrate_match.group(1)

    link_match = re.search(r"Link Quality[=:(\s]+(\d+)/(\d+)", stdout)
    if link_match:
        info["link_quality"] = f"{link_match.group(1)}/{link_match.group(2)}"

    signal_match = re.search(r"Signal level[=:]([-\d]+)\s*dBm", stdout)
    if signal_match:
        info["signal_dbm"] = int(signal_match.group(1))

    retry_match = re.search(r"Tx excessive retries:(\d+)", stdout)
    if retry_match:
        info["tx_retries"] = int(retry_match.group(1))

    return info


def diagnose():
    info = parse_signal_info()

    ssid = info.get("ssid", "N/A")
    freq = info.get("frequency", "N/A")
    signal_dbm = info.get("signal_dbm", 0)
    link = info.get("link_quality", "N/A")
    bitrate = info.get("bitrate", "N/A")
    retries = info.get("tx_retries", 0)

    rows = [
        ("当前网络", "WiFi名称", f"{ssid} ({freq}GHz)", "-"),
        (
            "信号强度",
            "信号强度",
            f"{signal_dbm} dBm ⚠️ 弱"
            if signal_dbm <= -70
            else f"{signal_dbm} dBm ✅ 正常",
            "移动设备或使用 WiFi 扩展器" if signal_dbm <= -70 else "-",
        ),
        ("链接质量", "连接质量", link, "-"),
        ("传输速率", "传输速率", f"{bitrate} Mb/s", "-"),
        (
            "传输重试",
            "重试次数",
            f"{retries} 次 ⚠️ 高" if retries > 10 else f"{retries} 次 ✅ 正常",
            "更换 WiFi 信道 (1, 6, 11)" if retries > 10 else "-",
        ),
    ]

    print("**网络状态诊断**")
    print()
    print(
        "| 名称     | 描述    | 状态                     | 建议                               |"
    )
    print(
        "|----------|---------|--------------------------|------------------------------------|"
    )
    for row in rows:
        name, desc, status, *_ = row
        suggestion = row[3] if len(row) > 3 else "-"
        print(f"| {name:<8} | {desc:<7} | {status:<24} | {suggestion:<34} |")
    print()


def main():
    parser = argparse.ArgumentParser(
        description="网络状态分析工具 - WiFi 诊断和故障排除"
    )
    parser.add_argument("--diagnose", "-d", action="store_true", help="运行完整诊断")
    parser.add_argument(
        "--signal", "-s", action="store_true", help="检查 WiFi 信号质量"
    )
    parser.add_argument("--list", "-l", action="store_true", help="列出可用 WiFi 网络")
    parser.add_argument("--active", "-a", action="store_true", help="显示活跃连接")
    parser.add_argument(
        "--logs",
        "-L",
        type=int,
        default=None,
        nargs="?",
        help="查看 NetworkManager 日志 (分钟, 默认 30)",
    )

    args = parser.parse_args()

    if args.diagnose:
        diagnose()
    elif args.signal:
        print(check_wifi_signal())
    elif args.list:
        print(list_wifi_networks())
    elif args.active:
        print(active_connections())
    elif args.logs is not None:
        print(networkmanager_logs(args.logs))
    else:
        diagnose()


if __name__ == "__main__":
    main()
