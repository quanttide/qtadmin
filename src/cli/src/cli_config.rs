use std::path::PathBuf;

// ── 环境变量键名 ──────────────────────────────────────────────────────

pub const ENV_PROFILE: &str = "QTRECURIT_PROFILE";

pub const ENV_DEEPSEEK_KEY: &str = "DEEPSEEK_API_KEY";

// ── 默认路径 ──────────────────────────────────────────────────────────

const DEFAULT_PROFILE_PATH: &str = "../../data/profile";
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

/// 获取 DeepSeek API Key
pub fn deepseek_api_key() -> Result<String, String> {
    std::env::var(ENV_DEEPSEEK_KEY).map_err(|_| format!("{ENV_DEEPSEEK_KEY} 环境变量未设置"))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::env;

    #[test]
    fn test_profile_root_env_var() {
        // default
        env::remove_var(ENV_PROFILE);
        assert_eq!(profile_root(), PathBuf::from(DEFAULT_PROFILE_PATH));

        // custom
        env::set_var(ENV_PROFILE, "/custom/profile");
        assert_eq!(profile_root(), PathBuf::from("/custom/profile"));

        // cleanup
        env::remove_var(ENV_PROFILE);
    }
}
