# Code Review Report

我来对这段 WiFi 网络诊断工具代码进行全面审查，找出潜在问题和改进建议。

## 代码审查报告

### 1. **严重问题 (Critical)**

#### 1.1 正则表达式匹配错误
```python
link_match = re.search(r"Link Quality[=:(\s]+(\d+)/(\d+)", stdout)
```
**问题**：正则表达式 `[=:(\s]+` 中的 `(` 被当作字面量而非分组符号，且逻辑混乱。

**修复**：
```python
link_match = re.search(r"Link Quality[=:\s]+(\d+)/(\d+)", stdout)
```

---

### 2. **中等问题 (Major)**

#### 2.1 硬编码命令依赖
代码假设系统使用 `NetworkManager` 和 `nmcli`，在以下环境会失效：
- 使用 `systemd-networkd` 的系统（如 Arch Linux 默认配置）
- 使用 `iwd` 替代 `wpa_supplicant` 的系统
- 最小化安装的容器/服务器环境

#### 2.2 `iwconfig` 已弃用
```python
stdout, _, _ = run_cmd(["iwconfig", interface])
```
`iwconfig` 属于已弃用的 `wireless-tools` 套件，现代系统推荐使用 `iw` 命令：
```bash
iw dev <interface> link  # 获取连接信息
iw dev <interface> station dump  # 获取信号统计
```

#### 2.3 信号强度判断阈值过于宽松
```python
if signal <= -70:  # 弱信号阈值
```
-70 dBm 实际上已经是较弱的信号，建议分级：
- -50 dBm 以上：优秀
- -60 到 -50：良好  
- -70 到 -60：一般
- 低于 -70：弱

---

### 3. **轻微问题 (Minor)**

#### 3.1 类型注解不一致
```python
def networkmanager_logs(minutes: int = 30) -> str:
    ...
    elif args.logs is not None:
        print(networkmanager_logs(args.logs))  # args.logs 可能是 None
```
`args.logs` 的类型是 `Optional[int]`，但函数参数要求 `int`。

#### 3.2 异常处理过于宽泛
```python
except Exception:
    return ""
```
会吞掉所有异常，包括 `KeyboardInterrupt`，建议至少记录日志。

#### 3.3 字符串匹配语言假设
```python
issues.append("未检测到无线网卡")
```
假设系统语言为中文，但在英文环境下 `iwconfig` 输出是英文，匹配会失败。

#### 3.4 重试次数阈值无依据
```python
if retry_count > 10:  # 为什么是 10？
```
10 次重试的阈值缺乏技术依据，且 `Tx excessive retries` 的计数器是累积值，不是实时指标。

---

### 4. **代码风格问题**

| 问题 | 位置 | 建议 |
|------|------|------|
| 魔法字符串 | `"wl"`, `"wlp"` | 提取为常量 `WIFI_PREFIXES = ("wl", "wlp", "wlan", "wifi")` |
| 重复代码 | `get_wifi_interface()` 调用多次 | 使用缓存或重构为类 |
| 输出格式混合 | `diagnose()` 直接打印 | 返回数据结构，格式化分离 |

---

### 5. **改进建议代码**

```python
import functools
from dataclasses import dataclass
from typing import Optional, List, Callable
import shutil

# 常量定义
WIFI_PREFIXES = ("wl", "wlp", "wlan", "wifi")
NMCLI_CMD = "nmcli"
IW_CMD = "iw"

@dataclass
class SignalInfo:
    ssid: Optional[str] = None
    frequency: Optional[float] = None  # GHz
    signal_dbm: Optional[int] = None
    # ... 其他字段

def command_exists(cmd: str) -> bool:
    """检查命令是否存在"""
    return shutil.which(cmd) is not None

def get_wifi_interface() -> Optional[str]:
    """改进的接口检测，支持多种命名规范"""
    interfaces = psutil.net_if_addrs().keys()
    wifi_interfaces = [
        iface for iface in interfaces 
        if any(iface.startswith(p) for p in WIFI_PREFIXES)
    ]
    
    # 优先返回已连接的接口
    if command_exists(NMCLI_CMD):
        # ... nmcli 检查逻辑 ...
        pass
    
    return wifi_interfaces[0] if wifi_interfaces else None

@functools.lru_cache(maxsize=1)
def get_cached_interface() -> Optional[str]:
    """缓存接口查询结果"""
    return get_wifi_interface()

def parse_signal_info_modern(interface: str) -> SignalInfo:
    """使用 iw 替代 iwconfig"""
    if not command_exists(IW_CMD):
        raise RuntimeError(f"命令 {IW_CMD} 未找到，请安装 iw 包")
    
    stdout, stderr, rc = run_cmd([IW_CMD, "dev", interface, "link"])
    if rc != 0:
        raise RuntimeError(f"获取信号信息失败: {stderr}")
    
    info = SignalInfo()
    # 解析 iw 输出（JSON 格式可用 `iw -j`）
    # ...
    return info
```

---

### 6. **测试建议**

当前代码缺乏单元测试，关键测试点：
1. 模拟 `iwconfig` 输出解析（中英文环境）
2. 无 WiFi 接口时的行为
3. 命令超时处理
4. 权限不足时的错误处理（需要 root 运行 `iw`）

---

### 总结

| 优先级 | 数量 | 关键修复项 |
|--------|------|-----------|
| 🔴 Critical | 1 | 修复正则表达式 `Link Quality` |
| 🟠 Major | 3 | 替换 `iwconfig` → `iw`，处理命令不存在情况 |
| 🟡 Minor | 4 | 类型注解、异常处理、国际化 |

代码整体结构清晰，但存在**技术债务**（`iwconfig` 已弃用）和**可移植性问题**（强依赖 NetworkManager）。
