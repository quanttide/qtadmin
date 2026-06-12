"""Configuration management for qtadmin CLI."""

import json
import os

_DEFAULTS = {
    "provider_url": "http://127.0.0.1:8000",
    "lark_path": "lark-cli",
    "mailbox": "",
}


class ConfigManager:
    """Manages qtadmin config stored as JSON."""

    def __init__(self, path: str | None = None) -> None:
        self._path = path or os.path.expanduser("~/.config/qtadmin/config.json")
        self._data: dict[str, str] = {}

    def _load(self) -> None:
        try:
            with open(self._path) as f:
                raw = json.load(f)
            if isinstance(raw, dict):
                self._data = {k: str(v) for k, v in raw.items()}
                return
        except (FileNotFoundError, json.JSONDecodeError, OSError):
            pass
        self._data = {}

    def _save(self) -> None:
        os.makedirs(os.path.dirname(self._path), exist_ok=True)
        with open(self._path, "w") as f:
            json.dump(self._data, f, indent=2, ensure_ascii=False)

    def get(self, key: str) -> str:
        """Get a config value, falling back to defaults."""
        self._load()
        if key not in self._data:
            return _DEFAULTS.get(key, "")
        return self._data[key]

    def set(self, key: str, value: str) -> None:
        """Set a config value and persist."""
        self._load()
        self._data[key] = value
        self._save()

    def show(self) -> dict[str, str]:
        """Return all config as dict (merged with defaults)."""
        self._load()
        merged = dict(_DEFAULTS)
        merged.update(self._data)
        return merged
