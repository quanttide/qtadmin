"""CLI、Provider、Studio 三方集成关系的 smoke test。"""


class TestIntegration:
    """验证各子项目入口文件存在。"""

    def test_cli_cargo_toml_exists(self):
        path = (
            __import__("pathlib").Path(__file__).parents[2]
            / "src"
            / "cli"
            / "Cargo.toml"
        )
        assert path.exists(), f"CLI Cargo.toml 不存在: {path}"

    def test_provider_go_mod_exists(self):
        path = (
            __import__("pathlib").Path(__file__).parents[2]
            / "src"
            / "provider"
            / "go.mod"
        )
        assert path.exists(), f"Provider go.mod 不存在: {path}"

    def test_studio_pubspec_exists(self):
        path = (
            __import__("pathlib").Path(__file__).parents[2]
            / "src"
            / "studio"
            / "pubspec.yaml"
        )
        assert path.exists(), f"Studio pubspec.yaml 不存在: {path}"
