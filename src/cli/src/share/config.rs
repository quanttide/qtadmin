use std::collections::HashMap;
use std::path::PathBuf;

use anyhow::{Context, Result};
use serde::Deserialize;

/// share.toml 顶层结构
#[derive(Debug, Deserialize)]
pub struct ShareConfig {
    /// key: project name, value: project config
    pub project: HashMap<String, ProjectConfig>,
}

/// 单个项目的配置
#[derive(Debug, Deserialize, Clone)]
pub struct ProjectConfig {
    /// 私仓源码路径（支持 ~ 展开）
    pub private_src: PathBuf,
    /// 公仓目标路径（支持 ~ 展开）
    pub public_dst: PathBuf,
    /// 指定同步的子目录/文件（空格分隔，可选）
    pub sync_src: Option<String>,
    /// 指定同步到公仓的子路径（可选）
    pub sync_dst: Option<String>,
    /// 编译验证命令（可选）
    pub build_cmd: Option<String>,
    /// 额外排除模式（空格分隔，可选）
    pub exclude: Option<String>,
}

/// 从 TOML 文件加载配置
pub fn load_config(path: &str) -> Result<ShareConfig> {
    let content =
        std::fs::read_to_string(path).with_context(|| format!("读取配置文件失败: {}", path))?;
    let config: ShareConfig =
        toml::from_str(&content).with_context(|| format!("解析配置文件失败: {}", path))?;
    // 展开 ~ 为 home 目录
    let config = expand_paths(config);
    Ok(config)
}

fn expand_home(path: &PathBuf) -> PathBuf {
    let s = path.to_string_lossy();
    if s.starts_with('~') {
        if let Ok(home) = std::env::var("HOME") {
            return PathBuf::from(s.replacen('~', &home, 1));
        }
    }
    path.clone()
}

fn expand_paths(mut config: ShareConfig) -> ShareConfig {
    for cfg in config.project.values_mut() {
        cfg.private_src = expand_home(&cfg.private_src);
        cfg.public_dst = expand_home(&cfg.public_dst);
    }
    config
}

/// 查找 share.toml（当前目录 → ~/.config/qtadmin/ → 项目根）
pub fn find_config() -> Result<String> {
    let candidates = [
        PathBuf::from("share.toml"),
        dirs::config_dir()
            .map(|d| d.join("qtadmin").join("share.toml"))
            .unwrap_or_default(),
        PathBuf::from("../../share.toml"),
    ];
    for p in &candidates {
        if p.exists() {
            return Ok(p.to_string_lossy().to_string());
        }
    }
    anyhow::bail!("未找到 share.toml，请在以下位置创建：{:?}", candidates);
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use std::io::Write;

    #[test]
    fn test_parse_valid_config() {
        let dir = tempfile::tempdir().unwrap();
        let path = dir.path().join("share.toml");
        let mut f = fs::File::create(&path).unwrap();
        writeln!(
            f,
            r#"
[project.demo]
private_src = "/home/user/private-repo"
public_dst = "/home/user/public-repo"
sync_src = "src data"
sync_dst = "examples/demo"
build_cmd = "cargo build"
exclude = "*.log tmp/"
"#
        )
        .unwrap();

        let cfg = load_config(path.to_str().unwrap()).unwrap();
        let demo = cfg.project.get("demo").unwrap();
        assert_eq!(demo.private_src, PathBuf::from("/home/user/private-repo"));
        assert_eq!(demo.sync_src.as_deref(), Some("src data"));
        assert_eq!(demo.sync_dst.as_deref(), Some("examples/demo"));
        assert_eq!(demo.build_cmd.as_deref(), Some("cargo build"));
        assert_eq!(demo.exclude.as_deref(), Some("*.log tmp/"));
    }

    #[test]
    fn test_expand_home() {
        let before = PathBuf::from("~/myrepo");
        let after = expand_home(&before);
        // should replace ~ with HOME
        if let Ok(home) = std::env::var("HOME") {
            assert_eq!(after, PathBuf::from(format!("{}/myrepo", home)));
        }
    }

    #[test]
    fn test_find_config_not_found() {
        let result = find_config();
        assert!(result.is_err());
    }

    #[test]
    fn test_find_config_success() {
        let dir = tempfile::tempdir().unwrap();
        let config_path = dir.path().join("share.toml");
        fs::write(
            &config_path,
            r#"[project.test]
private_src = "/tmp/src"
public_dst = "/tmp/dst"
"#
            .as_bytes(),
        )
        .unwrap();

        let orig_cwd = std::env::current_dir().unwrap();
        std::env::set_current_dir(dir.path()).unwrap();
        let result = find_config();
        std::env::set_current_dir(orig_cwd).unwrap();

        assert!(result.is_ok());
        assert!(result.unwrap().ends_with("share.toml"));
    }
}
