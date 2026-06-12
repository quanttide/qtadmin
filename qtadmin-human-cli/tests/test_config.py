"""Tests for the config module."""

import os

from qtadmin.config import ConfigManager


def test_default_config(tmp_path):
    """New config has sensible defaults."""
    path = tmp_path / "config.json"
    cfg = ConfigManager(str(path))
    assert cfg.get("provider_url") == "http://127.0.0.1:8000"
    assert cfg.get("lark_path") == "lark-cli"


def test_set_and_get(tmp_path):
    """set() persists and get() retrieves values."""
    path = tmp_path / "config.json"
    cfg = ConfigManager(str(path))
    cfg.set("provider_url", "http://example.com:9000")
    assert cfg.get("provider_url") == "http://example.com:9000"


def test_set_lark_path(tmp_path):
    """set lark-cli path."""
    path = tmp_path / "config.json"
    cfg = ConfigManager(str(path))
    cfg.set("lark_path", "/usr/local/bin/lark")
    assert cfg.get("lark_path") == "/usr/local/bin/lark"


def test_config_persists(tmp_path):
    """Config is persisted to disk and reloadable."""
    path = tmp_path / "config.json"
    cfg1 = ConfigManager(str(path))
    cfg1.set("provider_url", "http://server:8000")

    cfg2 = ConfigManager(str(path))
    assert cfg2.get("provider_url") == "http://server:8000"


def test_config_show_all(tmp_path):
    """show() returns all config as dict."""
    path = tmp_path / "config.json"
    cfg = ConfigManager(str(path))
    cfg.set("provider_url", "http://x:8000")
    cfg.set("lark_path", "/bin/lark")
    data = cfg.show()
    assert data["provider_url"] == "http://x:8000"
    assert data["lark_path"] == "/bin/lark"


def test_config_invalid_json(tmp_path):
    """Corrupted config file falls back to defaults."""
    path = tmp_path / "config.json"
    path.write_text("{invalid json}")
    cfg = ConfigManager(str(path))
    assert cfg.get("provider_url") == "http://127.0.0.1:8000"


def test_config_missing_file(tmp_path):
    """Missing config file falls back to defaults."""
    path = tmp_path / "nonexistent" / "config.json"
    cfg = ConfigManager(str(path))
    assert cfg.get("provider_url") == "http://127.0.0.1:8000"
