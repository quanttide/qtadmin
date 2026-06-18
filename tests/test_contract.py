"""契约文件结构验证测试。"""

import json


class TestContractStructure:
    """验证契约 JSON 文件结构正确。"""

    def test_recruitment_is_valid_json(self, contract_dir):
        path = contract_dir / "recruitment.json"
        assert path.exists(), f"契约文件不存在: {path}"
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        assert isinstance(data, dict), "顶层应为对象"

    def test_recruitment_has_required_keys(self, recruitment_contract):
        required = {"version", "schema", "positions", "candidates"}
        assert required.issubset(recruitment_contract.keys()), (
            f"缺少必要字段: {required - recruitment_contract.keys()}"
        )

    def test_recruitment_version_is_semver(self, recruitment_contract):
        version = recruitment_contract.get("version", "")
        parts = version.split(".")
        assert len(parts) == 3, f"版本号格式错误: {version}"

    def test_recruitment_positions_is_list(self, recruitment_contract):
        positions = recruitment_contract.get("positions", [])
        assert isinstance(positions, list), "positions 应为数组"
