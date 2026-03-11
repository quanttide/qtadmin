#!/usr/bin/env python3
"""
Ollama 安装脚本测试 - 断点续传版
"""

import os
import sys
import tempfile
import pytest
from unittest.mock import patch, MagicMock
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "examples"))
from ollama_install import (
    Downloader,
    run_cmd,
    download_script,
    verify_script,
    run_install_script,
    configure_ollama,
    cleanup,
)


class TestDownloader:
    """测试 Downloader 类"""

    def test_get_local_size_no_file(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            dest = os.path.join(tmpdir, "test.sh")
            downloader = Downloader("http://example.com/test.sh", dest)
            assert downloader.get_local_size() == 0

    def test_get_local_size_with_file(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            dest = os.path.join(tmpdir, "test.sh")
            with open(dest, "w") as f:
                f.write("test content")
            downloader = Downloader("http://example.com/test.sh", dest)
            assert downloader.get_local_size() == 12

    def test_verify_download_too_small(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            dest = os.path.join(tmpdir, "test.sh")
            with open(dest, "w") as f:
                f.write("small")
            downloader = Downloader("http://example.com/test.sh", dest)
            assert downloader._verify_download() is False

    def test_verify_download_valid(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            dest = os.path.join(tmpdir, "test.sh")
            with open(dest, "w") as f:
                f.write("#!/bin/bash\necho hello\n" * 100)
            downloader = Downloader("http://example.com/test.sh", dest)
            assert downloader._verify_download() is True

    @patch("ollama_install.requests.Session")
    def test_download_success(self, mock_session):
        with tempfile.TemporaryDirectory() as tmpdir:
            dest = os.path.join(tmpdir, "test.sh")
            mock_resp = MagicMock()
            mock_resp.status_code = 200
            mock_resp.iter_content = lambda chunk_size: [b"test content\n"]
            mock_session.return_value.get.return_value.__enter__ = MagicMock(
                return_value=mock_resp
            )
            mock_session.return_value.get.return_value.__exit__ = MagicMock(
                return_value=False
            )

            downloader = Downloader("http://example.com/test.sh", dest)
            result = downloader.download(resume=False)
            assert result is True

    @patch("ollama_install.requests.Session")
    def test_download_retry_on_error(self, mock_session):
        with tempfile.TemporaryDirectory() as tmpdir:
            dest = os.path.join(tmpdir, "test.sh")

            mock_resp_error = MagicMock()
            mock_resp_error.status_code = 500

            mock_resp_success = MagicMock()
            mock_resp_success.status_code = 200
            mock_resp_success.iter_content = lambda chunk_size: [b"test content\n"]

            mock_session.return_value.get.side_effect = [
                mock_resp_error,
                mock_resp_success,
            ]
            mock_session.return_value.get.return_value.__enter__ = lambda s: mock_resp_success
            mock_session.return_value.get.return_value.__exit__ = lambda s, *args: False

            downloader = Downloader("http://example.com/test.sh", dest)
            with patch("time.sleep"):
                result = downloader.download(resume=False)
                assert result is True


class TestRunCmd:
    """测试 run_cmd 函数"""

    def test_run_cmd_success(self):
        returncode, stdout, stderr = run_cmd(["echo", "hello"])
        assert returncode == 0
        assert stdout.strip() == "hello"

    def test_run_cmd_failure(self):
        returncode, stdout, stderr = run_cmd(["ls", "/nonexistent_path_12345"])
        assert returncode != 0


class TestVerifyScript:
    """测试 verify_script 函数"""

    def test_verify_script_not_exists(self):
        with patch("ollama_install.SCRIPT_PATH", "/nonexistent/script.sh"):
            result = verify_script()
            assert result is False

    def test_verify_script_too_small(self):
        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".sh") as f:
            f.write("small")
            temp_path = f.name

        with patch("ollama_install.SCRIPT_PATH", temp_path):
            result = verify_script()
            assert result is False

        os.unlink(temp_path)

    def test_verify_script_valid(self):
        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".sh") as f:
            f.write("#!/bin/bash\necho 'ollama'\n")
            temp_path = f.name

        with patch("ollama_install.SCRIPT_PATH", temp_path):
            result = verify_script()
            assert result is True

        os.unlink(temp_path)


class TestRunInstallScript:
    """测试 run_install_script 函数"""

    @patch("ollama_install.run_cmd")
    def test_install_already_exists(self, mock_run_cmd):
        mock_run_cmd.return_value = (0, "/usr/bin/ollama", "")

        with patch("builtins.input", return_value="n"):
            result = run_install_script()

        assert result is True

    @patch("ollama_install.run_cmd")
    def test_install_success(self, mock_run_cmd):
        mock_run_cmd.side_effect = [
            (1, "", "ollama not found"),
            (0, "Installing...", ""),
        ]

        with patch("builtins.input", return_value="y"):
            with patch("os.chmod", return_value=None):
                result = run_install_script()

        assert result is True


class TestConfigureOllama:
    """测试 configure_ollama 函数"""

    def test_configure_ollama_not_available(self):
        with patch("ollama_install.run_cmd") as mock_run_cmd:
            mock_run_cmd.return_value = (1, "", "command not found")
            result = configure_ollama()
            assert result is False

    @patch("ollama_install.run_cmd")
    @patch("ollama_install.os.path.exists", return_value=False)
    def test_configure_success(self, mock_exists, mock_run_cmd):
        mock_run_cmd.return_value = (0, "ollama version 0.1.0", "")

        with patch("builtins.open", MagicMock()):
            result = configure_ollama()

        assert result is True


class TestCleanup:
    """测试 cleanup 函数"""

    @patch("ollama_install.os.path.exists", return_value=False)
    def test_cleanup_no_file(self, mock_exists):
        result = cleanup()
        assert result is True


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
