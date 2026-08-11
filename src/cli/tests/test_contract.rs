use std::path::PathBuf;

const CONTRACT_PATH: &str = "../../tests/contract/recruitment.json";

#[test]
fn test_contract_recruitment_fields() {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join(CONTRACT_PATH);
    assert!(path.exists(), "契约文件不存在: {}", path.display());

    let content = std::fs::read_to_string(&path).unwrap();
    let value: serde_json::Value = serde_json::from_str(&content).unwrap();

    // Top-level fields
    assert_eq!(value["month"], "2026-06");
    let positions = value["positions"].as_array().unwrap();
    assert_eq!(positions.len(), 8);

    // Each position must have all required fields
    for (_i, pos) in positions.iter().enumerate() {
        let name = pos["name"].as_str().unwrap_or("?");
        assert!(
            pos.get("headcount").and_then(|v| v.as_i64()).is_some(),
            "岗位 '{}' 缺少 headcount 字段",
            name
        );
        assert!(
            pos.get("filled").and_then(|v| v.as_i64()).is_some(),
            "岗位 '{}' 缺少 filled 字段",
            name
        );
        assert!(
            pos.get("in_progress").and_then(|v| v.as_i64()).is_some(),
            "岗位 '{}' 缺少 in_progress 字段",
            name
        );
        assert!(
            pos.get("note").is_some(),
            "岗位 '{}' 缺少 note 字段",
            name
        );
    }

    // Headcount sums to 10
    let total: i64 = positions.iter().map(|p| p["headcount"].as_i64().unwrap()).sum();
    assert_eq!(total, 10, "总编制应为 10，实际为 {total}");
}

#[test]
fn test_contract_recruitment_roundtrip() {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join(CONTRACT_PATH);
    let content = std::fs::read_to_string(&path).unwrap();
    let value: serde_json::Value = serde_json::from_str(&content).unwrap();

    // Serialize back and compare — ensures no lossy conversion
    let serialized = serde_json::to_string_pretty(&value).unwrap();
    let parsed_back: serde_json::Value = serde_json::from_str(&serialized).unwrap();

    assert_eq!(value, parsed_back, "JSON roundtrip 应保持相同");
}
