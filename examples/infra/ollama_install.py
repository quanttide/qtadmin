#!/usr/bin/env python3
"""
Ollama 安装脚本 - 支持断点续传
处理网络不稳定导致的 HTTP/2 PROTOCOL_ERROR 问题
"""

import os
import sys
import time
import logging
import requests
from pathlib import Path
from datetime import datetime

OLLAMA_URL = "https://ollama.ac.cn/install.sh"
SCRIPT_PATH = "/tmp/ollama_install.sh"
MAX_RETRIES = 3
CHUNK_SIZE = 8192

LOG_DIR = Path(__file__).parent.parent / "data" / "log"
LOG_FILE = LOG_DIR / "ollama_install.log"


def setup_logging():
    """设置日志"""
    LOG_DIR.mkdir(parents=True, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[
            logging.FileHandler(LOG_FILE, encoding="utf-8"),
            logging.StreamHandler(sys.stdout),
        ],
    )
    return logging.getLogger(__name__)


logger = setup_logging()


class Downloader:
    """支持断点续传的下载器"""

    def __init__(self, url: str, dest_path: str):
        self.url = url
        self.dest_path = dest_path
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "curl/8.0.1"
        })
        self.start_time = None
        self.total_bytes = 0

    def get_local_size(self) -> int:
        """获取本地文件大小"""
        if os.path.exists(self.dest_path):
            return os.path.getsize(self.dest_path)
        return 0

    def get_remote_size(self) -> int:
        """获取远程文件大小"""
        try:
            resp = self.session.head(self.url, timeout=30, allow_redirects=True)
            resp.raise_for_status()
            return int(resp.headers.get("content-length", 0))
        except Exception:
            return 0

    def download(self, resume: bool = True) -> bool:
        """下载文件，支持断点续传"""
        self.start_time = time.time()
        local_size = 0

        remote_size = self.get_remote_size()
        if remote_size > 0:
            self.total_bytes = remote_size
            logger.info(f"远程文件大小: {self._format_size(remote_size)}")

        if resume:
            local_size = self.get_local_size()
            if local_size > 0:
                logger.info(f"本地已有: {self._format_size(local_size)}")

        headers = {}
        if resume and local_size > 0 and remote_size > local_size:
            headers["Range"] = f"bytes={local_size}-"
            logger.info(f"断点续传: {self._format_size(local_size)} -> {self._format_size(remote_size)}")
        else:
            if local_size > 0:
                logger.info("删除旧文件，重新下载")
            if os.path.exists(self.dest_path):
                os.remove(self.dest_path)
            local_size = 0

        downloaded = local_size

        for attempt in range(1, MAX_RETRIES + 1):
            logger.info(f"尝试 {attempt}/{MAX_RETRIES}...")

            try:
                mode = "ab" if local_size > 0 and resume else "wb"
                with self.session.get(self.url, headers=headers, stream=True, timeout=60) as resp:
                    resp.raise_for_status()

                    if resp.status_code == 206:
                        logger.info("继续下载 (206 Partial Content)")
                    elif resp.status_code == 200:
                        logger.info("重新下载 (200 OK)")
                        downloaded = 0
                        mode = "wb"

                    if mode == "wb" and os.path.exists(self.dest_path):
                        os.remove(self.dest_path)

                    with open(self.dest_path, mode) as f:
                        for chunk in resp.iter_content(chunk_size=CHUNK_SIZE):
                            if chunk:
                                f.write(chunk)
                                downloaded += len(chunk)
                                self._log_progress(downloaded)

                if self._verify_download():
                    elapsed = time.time() - self.start_time
                    speed = downloaded / elapsed if elapsed > 0 else 0
                    logger.info(f"下载完成: {self._format_size(int(downloaded))}, 耗时: {elapsed:.1f}s, 速度: {self._format_size(int(speed))}/s")
                    return True

            except requests.exceptions.HTTPError as e:
                if e.response.status_code == 416:
                    logger.warning("范围请求不支持 (416)，删除重新下载")
                    if os.path.exists(self.dest_path):
                        os.remove(self.dest_path)
                    downloaded = 0
                    headers = {}
                    resume = False
                else:
                    logger.error(f"HTTP 错误: {e}")
            except requests.exceptions.Timeout:
                logger.warning("请求超时")
            except requests.exceptions.ConnectionError as e:
                logger.warning(f"连接错误: {str(e)[:80]}")
            except Exception as e:
                logger.error(f"下载错误: {e}")

            if attempt < MAX_RETRIES:
                wait_time = 2 ** attempt
                logger.info(f"等待 {wait_time} 秒后重试...")
                time.sleep(wait_time)

        return False

    def _log_progress(self, downloaded: int):
        """记录下载进度"""
        elapsed = time.time() - self.start_time
        speed = downloaded / elapsed if elapsed > 0 else 0

        if self.total_bytes > 0:
            percent = (downloaded / self.total_bytes) * 100
            bar_len = 30
            filled = int(bar_len * downloaded / self.total_bytes)
            bar = "=" * filled + "-" * (bar_len - filled)
            eta = self._estimate_eta(downloaded)
            logger.info(f"进度: [{bar}] {percent:.1f}% ({self._format_size(downloaded)}/{self._format_size(self.total_bytes)}) ETA: {eta}")
        else:
            logger.info(f"已下载: {self._format_size(int(downloaded))}, 速度: {self._format_size(int(speed))}/s")

    def _estimate_eta(self, downloaded: int) -> str:
        """估算剩余时间"""
        if downloaded == 0:
            return "N/A"
        elapsed = time.time() - self.start_time
        speed = downloaded / elapsed if elapsed > 0 else 0
        if speed == 0 or self.total_bytes == 0:
            return "N/A"
        remaining = int(self.total_bytes) - downloaded
        seconds = remaining / speed
        if seconds < 60:
            return f"{int(seconds)}s"
        elif seconds < 3600:
            return f"{int(seconds / 60)}m"
        return f"{int(seconds / 3600)}h"

    def _format_size(self, size: float) -> str:
        """格式化文件大小"""
        for unit in ["B", "KB", "MB", "GB"]:
            if size < 1024:
                return f"{size:.1f}{unit}"
            size /= 1024
        return f"{size:.1f}TB"

    def _verify_download(self) -> bool:
        """验证下载是否完成"""
        if not os.path.exists(self.dest_path):
            return False
        file_size = os.path.getsize(self.dest_path)
        return file_size >= 1000


def run_cmd(cmd: list[str], timeout: int = 60):
    """执行命令"""
    import subprocess
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Command timeout"
    except Exception as e:
        return -1, "", str(e)


def download_script() -> bool:
    """下载安装脚本"""
    logger.info(f"=" * 50)
    logger.info(f"[1/5] 下载安装脚本: {OLLAMA_URL}")
    downloader = Downloader(OLLAMA_URL, SCRIPT_PATH)
    return downloader.download(resume=True)


def verify_script() -> bool:
    """验证脚本完整性"""
    logger.info(f"[2/5] 验证脚本: {SCRIPT_PATH}")

    if not os.path.exists(SCRIPT_PATH):
        logger.error("脚本文件不存在")
        return False

    file_size = os.path.getsize(SCRIPT_PATH)
    if file_size < 1000:
        logger.error(f"文件太小 ({file_size} bytes)，可能下载不完整")
        return False

    logger.info(f"文件大小: {file_size} bytes")

    try:
        with open(SCRIPT_PATH, "r") as f:
            content = f.read(500)
        if "ollama" not in content.lower():
            logger.warning("文件内容可能不正确")
            return False
        logger.info(f"内容预览:\n{content[:200]}")
    except Exception as e:
        logger.error(f"读取文件错误: {e}")
        return False

    return True


def run_install_script() -> bool:
    """执行安装脚本"""
    logger.info(f"[3/5] 执行安装脚本 (需要 sudo)")

    returncode, stdout, stderr = run_cmd(["which", "ollama"])
    if returncode == 0:
        logger.info(f"Ollama 已安装在: {stdout.strip()}")
        response = input("  重新安装? [y/N]: ").strip().lower()
        if response != 'y':
            logger.info("跳过安装")
            return True

    os.chmod(SCRIPT_PATH, 0o755)
    logger.info("执行 sudo sh install.sh ...")
    returncode, stdout, stderr = run_cmd(["sudo", "sh", SCRIPT_PATH], timeout=300)

    logger.info(stdout)
    if stderr:
        logger.warning(f"stderr: {stderr}")

    if returncode == 0:
        logger.info("安装成功")
        return True
    logger.error(f"安装失败 (code: {returncode})")
    return False


def configure_ollama() -> bool:
    """配置 Ollama 环境变量"""
    logger.info("[4/5] 配置环境变量")

    returncode, stdout, stderr = run_cmd(["ollama", "--version"])
    if returncode != 0:
        logger.error("ollama 命令不可用")
        return False

    logger.info(f"当前版本: {stdout.strip()}")

    env_configs = [
        ("OLLAMA_HOST", "0.0.0.0:11434"),
        ("OLLAMA_KEEP_ALIVE", "12h"),
    ]

    shell_config = os.path.expanduser("~/.bashrc")
    backup_config = shell_config + ".bak"

    if os.path.exists(shell_config):
        import shutil
        shutil.copy(shell_config, backup_config)
        logger.info(f"备份配置到: {backup_config}")

    with open(shell_config, "a") as f:
        f.write("\n# Ollama 配置\n")
        for key, value in env_configs:
            line = f'export {key}="{value}"\n'
            f.write(line)
            logger.info(f"添加: {key}={value}")

    logger.info(f"配置已添加到: {shell_config}")
    return True


def cleanup() -> bool:
    """清理安装脚本"""
    logger.info("[5/5] 清理")

    if os.path.exists(SCRIPT_PATH):
        os.remove(SCRIPT_PATH)
        logger.info(f"删除: {SCRIPT_PATH}")
    else:
        logger.info("无需清理")

    return True


def main():
    logger.info("=" * 50)
    logger.info("Ollama 自动安装脚本 (断点续传版)")
    logger.info("=" * 50)
    logger.info(f"日志文件: {LOG_FILE}")

    steps = [
        ("下载", download_script),
        ("验证", verify_script),
        ("安装", run_install_script),
        ("配置", configure_ollama),
        ("清理", cleanup),
    ]

    for name, func in steps:
        if not func():
            logger.error(f"[{name}] 步骤失败，退出")
            sys.exit(1)

    logger.info("=" * 50)
    logger.info("安装完成!")
    logger.info("=" * 50)
    logger.info("\n后续步骤:")
    logger.info("  1. 执行: source ~/.bashrc")
    logger.info("  2. 启动: ollama serve")
    logger.info("  3. 拉取模型: ollama run qwen:7b")


if __name__ == "__main__":
    main()
