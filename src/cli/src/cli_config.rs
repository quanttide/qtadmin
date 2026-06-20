use std::path::PathBuf;

// ── 环境变量键名 ──────────────────────────────────────────────────────

/// profile 仓库路径
pub const ENV_PROFILE: &str = "QTRECURIT_PROFILE";
/// 招聘配置路径（兼容旧版 TOML）
pub const ENV_CONFIG: &str = "QTRECURIT_CONFIG";
/// 招聘数据目录
pub const ENV_DATA: &str = "QTRECURIT_DATA";
/// DeepSeek API Key
pub const ENV_DEEPSEEK_KEY: &str = "DEEPSEEK_API_KEY";

// ── 默认路径 ──────────────────────────────────────────────────────────

/// 从当前工作目录到 profile 仓库的默认相对路径
const DEFAULT_PROFILE_PATH: &str = "../../data/profile";

/// 手册目录的默认相对路径
pub const DEFAULT_HANDBOOK_DIR: &str = "docs/handbook";

// ── 加载函数 ──────────────────────────────────────────────────────────

/// 获取 profile 仓库根目录路径
pub fn profile_root() -> PathBuf {
    if let Ok(path) = std::env::var(ENV_PROFILE) {
        PathBuf::from(path)
    } else {
        PathBuf::from(DEFAULT_PROFILE_PATH)
    }
}

/// 获取分类规则 JSON 路径
pub fn profile_rules_path() -> PathBuf {
    profile_root().join("connect").join("rules.json")
}

/// 获取质量评估标准 JSON 路径
pub fn profile_quality_path() -> PathBuf {
    profile_root().join("asset").join("quality.json")
}

/// 获取 DeepSeek API Key
pub fn deepseek_api_key() -> Result<String, String> {
    std::env::var(ENV_DEEPSEEK_KEY).map_err(|_| format!("{ENV_DEEPSEEK_KEY} 环境变量未设置"))
}
