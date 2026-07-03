use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{Context, Result};

/// 默认排除模式
const DEFAULT_EXCLUDES: &[&str] = &[
    ".git",
    ".git/",
    "target/",
    "data/",
    "node_modules/",
    ".cursor",
    ".venv/",
    "__pycache__/",
    "*.pyc",
    ".coverage",
    ".pytest_cache/",
    ".DS_Store",
];

/// 使用 rsync 复制源码到目标路径
pub fn rsync_copy(
    src: &Path,
    dst: &Path,
    sync_src: Option<&str>,
    sync_dst: Option<&str>,
    exclude: Option<&str>,
) -> Result<PathBuf> {
    // 构建目标目录
    let dst_dir = match sync_dst {
        Some(sub) => dst.join(sub),
        None => dst.to_path_buf(),
    };
    std::fs::create_dir_all(&dst_dir)
        .with_context(|| format!("创建目标目录失败: {}", dst_dir.display()))?;

    // 构建排除参数
    let mut excludes: Vec<String> = DEFAULT_EXCLUDES.iter().map(|s| s.to_string()).collect();
    if let Some(extra) = exclude {
        for pattern in extra.split_whitespace() {
            excludes.push(pattern.to_string());
        }
    }

    // 构建 rsync 命令
    let mut cmd = Command::new("rsync");
    cmd.arg("-av");
    for e in &excludes {
        cmd.arg("--exclude");
        cmd.arg(e);
    }

    if let Some(items) = sync_src {
        for item in items.split_whitespace() {
            let item = item.trim_end_matches('/');
            let full_src = src.join(item);
            if full_src.exists() {
                cmd.arg(full_src.to_string_lossy().as_ref());
            }
        }
    } else {
        cmd.arg(format!("{}/", src.display()));
    }

    cmd.arg(format!("{}/", dst_dir.display()));

    let status = cmd
        .status()
        .with_context(|| format!("执行 rsync 失败: {} → {}", src.display(), dst_dir.display()))?;

    if !status.success() {
        anyhow::bail!("rsync 返回非零退出码: {}", status);
    }

    Ok(dst_dir)
}

/// 查找需要脱敏的源文件
pub fn find_source_files(dir: &Path) -> Vec<PathBuf> {
    let mut files = Vec::new();
    let extensions = [".rs", ".py", ".md", ".toml", ".json", ".yaml", ".yml"];

    for entry in walkdir::WalkDir::new(dir) {
        let entry = match entry {
            Ok(e) => e,
            Err(_) => continue,
        };

        let path = entry.path();

        // 跳过目录
        if path.is_dir() {
            continue;
        }

        // 跳过排除目录
        if should_skip(path) {
            continue;
        }

        // 匹配扩展名
        if let Some(ext) = path.extension() {
            let ext_str = format!(".{}", ext.to_string_lossy().to_lowercase());
            if extensions.contains(&ext_str.as_str()) {
                files.push(path.to_path_buf());
            }
        }
    }

    files
}

fn should_skip(path: &Path) -> bool {
    for ancestor in path.ancestors().skip(1) {
        let name = match ancestor.file_name().map(|n| n.to_string_lossy()) {
            Some(n) => n.to_string(),
            None => continue,
        };
        if name == ".git" || name == "target" || name == "node_modules" {
            return true;
        }
    }
    false
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn create_test_file(dir: &Path, rel: &str, content: &str) -> PathBuf {
        let path = dir.join(rel);
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).unwrap();
        }
        fs::write(&path, content).unwrap();
        path
    }

    #[test]
    fn test_find_source_files_basic() {
        let dir = tempfile::tempdir().unwrap();
        create_test_file(dir.path(), "src/main.rs", "fn main() {}");
        create_test_file(dir.path(), "README.md", "# Hello");
        create_test_file(dir.path(), "Cargo.toml", "[package]");
        create_test_file(dir.path(), "data/secret.txt", "secret");

        let files = find_source_files(dir.path());
        let names: Vec<String> = files
            .iter()
            .map(|f| f.file_name().unwrap().to_string_lossy().to_string())
            .collect();

        assert!(names.contains(&"main.rs".to_string()));
        assert!(names.contains(&"README.md".to_string()));
        assert!(names.contains(&"Cargo.toml".to_string()));
        assert!(!names.contains(&"secret.txt".to_string())); // .txt excluded
    }

    #[test]
    fn test_find_source_files_skip_hidden() {
        let dir = tempfile::tempdir().unwrap();
        create_test_file(dir.path(), ".git/config", "[core]");
        create_test_file(dir.path(), "src/main.rs", "fn main() {}");

        let files = find_source_files(dir.path());
        assert!(!files.iter().any(|f| f.to_string_lossy().contains(".git")));
    }

    #[test]
    fn test_rsync_copy_basic() {
        let src = tempfile::tempdir().unwrap();
        let dst = tempfile::tempdir().unwrap();
        create_test_file(src.path(), "src/main.rs", "fn main() {}");
        create_test_file(src.path(), "Cargo.toml", "[package]");

        let result = rsync_copy(src.path(), dst.path(), None, None, None).unwrap();
        assert!(result.join("src/main.rs").exists());
        assert!(result.join("Cargo.toml").exists());
    }

    #[test]
    fn test_rsync_copy_with_sync_src() {
        let src = tempfile::tempdir().unwrap();
        let dst = tempfile::tempdir().unwrap();
        create_test_file(src.path(), "src/main.rs", "fn main() {}");
        create_test_file(src.path(), "data/file.txt", "data");

        let result = rsync_copy(src.path(), dst.path(), Some("src"), None, None).unwrap();
        assert!(result.join("src/main.rs").exists());
        assert!(!result.join("data/file.txt").exists());
    }

    #[test]
    fn test_rsync_copy_with_sync_dst() {
        let src = tempfile::tempdir().unwrap();
        let dst = tempfile::tempdir().unwrap();
        create_test_file(src.path(), "main.rs", "fn main() {}");

        let result =
            rsync_copy(src.path(), dst.path(), None, Some("examples/myapp"), None).unwrap();
        assert_eq!(result, dst.path().join("examples/myapp"));
        assert!(result.join("main.rs").exists());
    }

    #[test]
    fn test_rsync_copy_with_exclude() {
        let src = tempfile::tempdir().unwrap();
        let dst = tempfile::tempdir().unwrap();
        create_test_file(src.path(), "keep.rs", "fn main() {}");
        create_test_file(src.path(), "secret.log", "sensitive");

        let result = rsync_copy(src.path(), dst.path(), None, None, Some("*.log")).unwrap();
        assert!(result.join("keep.rs").exists());
        assert!(!result.join("secret.log").exists());
    }

    #[test]
    fn test_rsync_copy_failure() {
        // destination dir exists, but source doesn't -> rsync fails
        let dst = tempfile::tempdir().unwrap();
        let result = rsync_copy(
            std::path::Path::new("/tmp/nonexistent_rsync_source_test_xyz"),
            dst.path(),
            None, // sync_src=None, so it passes the source dir itself
            None,
            None,
        );
        assert!(result.is_err());
    }
}
