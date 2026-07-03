use std::io::Write;
use std::path::PathBuf;

use predicates::prelude::PredicateBooleanExt;

/// 设置临时 share.toml 环境
fn setup_share_env() -> (tempfile::TempDir, PathBuf, PathBuf) {
    let root = tempfile::tempdir().unwrap();
    let private = root.path().join("private");
    let public = root.path().join("public");

    std::fs::create_dir_all(&private).unwrap();
    std::fs::create_dir_all(&public).unwrap();

    // 创建源文件
    std::fs::write(
        private.join("main.rs"),
        "fn main() { println!(\"hello\"); }\n",
    )
    .unwrap();
    std::fs::write(private.join("Cargo.toml"), "[package]\nname = \"demo\"\n").unwrap();
    std::fs::create_dir_all(private.join("src")).unwrap();
    std::fs::write(private.join("src").join("lib.rs"), "pub fn greet() {}\n").unwrap();

    // 创建 share.toml
    let mut cfg = std::fs::File::create(root.path().join("share.toml")).unwrap();
    write!(
        cfg,
        r#"[project.test]
private_src = "{}"
public_dst = "{}"
sync_src = "."
sync_dst = "examples/demo"
"#,
        private.to_string_lossy(),
        public.to_string_lossy(),
    )
    .unwrap();

    (root, private, public)
}

#[test]
fn test_share_help() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["share", "--help"]).assert().success().stdout(
        predicates::str::contains("代码脱敏发布")
            .and(predicates::str::contains("PROJECT"))
            .and(predicates::str::contains("--dry-run")),
    );
}

#[test]
fn test_share_missing_project() {
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args(["share", "nonexistent"])
        .assert()
        .failure()
        .stderr(predicates::str::contains("未找到 share.toml"));
}

#[test]
fn test_share_config_not_found() {
    // 不带 share.toml 时运行
    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.args([
        "share",
        "test",
        "--no-decide",
        "--no-llm",
        "--no-build",
        "--no-commit",
    ])
    .assert()
    .failure()
    .stderr(predicates::str::contains("未找到 share.toml"));
}

#[test]
fn test_share_copy_files() {
    let (root, _private, public) = setup_share_env();

    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.current_dir(root.path());
    cmd.args([
        "share",
        "test",
        "--no-decide",
        "--no-llm",
        "--no-build",
        "--no-commit",
    ])
    .assert()
    .success()
    .stdout(predicates::str::contains("复制").and(predicates::str::contains("完成")));

    // 验证文件已复制到公仓
    let demo_dir = public.join("examples").join("demo");
    assert!(demo_dir.exists(), "目标目录应存在");
    assert!(demo_dir.join("main.rs").exists(), "main.rs 应被复制");
    assert!(demo_dir.join("Cargo.toml").exists(), "Cargo.toml 应被复制");
    assert!(
        demo_dir.join("src").join("lib.rs").exists(),
        "src/lib.rs 应被复制"
    );
}

#[test]
fn test_share_copy_with_static_sanitize() {
    let (root, private, _public) = setup_share_env();

    // 在源文件中加入敏感内容
    std::fs::write(
        private.join("secret.rs"),
        "let email = \"admin@internal.com\";\nlet ip = \"10.0.0.1\";\n",
    )
    .unwrap();

    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.current_dir(root.path());
    cmd.args([
        "share",
        "test",
        "--no-decide",
        "--no-llm",
        "--no-build",
        "--no-commit",
    ])
    .assert()
    .success()
    .stdout(predicates::str::contains("脱敏").and(predicates::str::contains("个替换")));
}

#[test]
fn test_share_dry_run() {
    let (root, private, _public) = setup_share_env();

    std::fs::write(
        private.join("secret.rs"),
        "let key = \"sk-proj-abcdefghijklmnopqrstuvwx\";\n",
    )
    .unwrap();

    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.current_dir(root.path());
    cmd.args([
        "share",
        "test",
        "--no-decide",
        "--no-llm",
        "--no-build",
        "--no-commit",
        "--dry-run",
    ])
    .assert()
    .success()
    .stdout(predicates::str::contains("脱敏").and(predicates::str::contains("=>")));

    // dry-run 模式下文件不应被修改
    let content = std::fs::read_to_string(private.join("secret.rs")).unwrap();
    assert!(
        content.contains("sk-proj-abcdefghijklmnopqrstuvwx"),
        "dry-run 不应修改源文件"
    );
}

#[test]
fn test_share_git_commit() {
    let (root, _private, public) = setup_share_env();

    // 先初始化公仓为 git 仓库
    std::process::Command::new("git")
        .args(["init"])
        .current_dir(&public)
        .output()
        .unwrap();
    std::process::Command::new("git")
        .args(["config", "user.email", "test@test.com"])
        .current_dir(&public)
        .output()
        .unwrap();
    std::process::Command::new("git")
        .args(["config", "user.name", "Test"])
        .current_dir(&public)
        .output()
        .unwrap();

    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.current_dir(root.path());
    cmd.args(["share", "test", "--no-decide", "--no-llm", "--no-build"])
        .assert()
        .success()
        .stdout(predicates::str::contains("git:").and(predicates::str::contains("已提交")));

    // 验证 git 提交
    let log = std::process::Command::new("git")
        .args(["log", "--oneline", "-1"])
        .current_dir(&public)
        .output()
        .unwrap();
    let output = String::from_utf8_lossy(&log.stdout);
    assert!(
        output.contains("opensource:"),
        "应有 git 提交记录: {}",
        output
    );
}

#[test]
fn test_share_version_tag() {
    let (root, _private, public) = setup_share_env();

    std::process::Command::new("git")
        .args(["init"])
        .current_dir(&public)
        .output()
        .unwrap();
    std::process::Command::new("git")
        .args(["config", "user.email", "test@test.com"])
        .current_dir(&public)
        .output()
        .unwrap();
    std::process::Command::new("git")
        .args(["config", "user.name", "Test"])
        .current_dir(&public)
        .output()
        .unwrap();

    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.current_dir(root.path());
    cmd.args([
        "share",
        "test",
        "v0.1.0",
        "--no-decide",
        "--no-llm",
        "--no-build",
    ])
    .assert()
    .success()
    .stdout(predicates::str::contains("已打 tag"));

    // 验证 tag
    let tag = std::process::Command::new("git")
        .args(["tag", "-l"])
        .current_dir(&public)
        .output()
        .unwrap();
    let output = String::from_utf8_lossy(&tag.stdout);
    assert!(output.contains("v0.1.0"), "应有 version tag: {}", output);
}

#[test]
fn test_share_project_not_in_config() {
    let root = tempfile::tempdir().unwrap();
    let mut cfg = std::fs::File::create(root.path().join("share.toml")).unwrap();
    writeln!(
        cfg,
        r#"[project.other]
private_src = "/tmp"
public_dst = "/tmp"
"#
    )
    .unwrap();

    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.current_dir(root.path());
    cmd.args([
        "share",
        "missing-project",
        "--no-decide",
        "--no-llm",
        "--no-build",
        "--no-commit",
    ])
    .assert()
    .failure()
    .stderr(predicates::str::contains("配置中找不到项目"));
}

#[test]
fn test_share_llm_sanitize_via_cli() {
    let api_key = std::env::var("DEEPSEEK_API_KEY").unwrap_or_default();
    if api_key.is_empty() || api_key == "sk-xxx" {
        eprintln!("  skip: DEEPSEEK_API_KEY not set");
        return;
    }

    let (root, private, _public) = setup_share_env();

    // 在源文件中加入 LLM 可检测的敏感内容
    std::fs::write(
        private.join("config.rs"),
        "let internal_url = \"https://internal.company.com/api\";\n",
    )
    .unwrap();

    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.current_dir(root.path());
    cmd.args([
        "share",
        "test",
        "--no-decide",
        "--no-build",
        "--no-commit",
        // 不传 --no-llm，使用真实 LLM
    ])
    .assert()
    .success()
    .stdout(predicates::str::contains("脱敏"));
}

#[test]
fn test_share_llm_commit_via_cli() {
    let api_key = std::env::var("DEEPSEEK_API_KEY").unwrap_or_default();
    if api_key.is_empty() || api_key == "sk-xxx" {
        eprintln!("  skip: DEEPSEEK_API_KEY not set");
        return;
    }

    let (root, _private, public) = setup_share_env();

    // 初始化公仓 git
    std::process::Command::new("git")
        .args(["init"])
        .current_dir(&public)
        .output()
        .unwrap();
    std::process::Command::new("git")
        .args(["config", "user.email", "test@test.com"])
        .current_dir(&public)
        .output()
        .unwrap();
    std::process::Command::new("git")
        .args(["config", "user.name", "Test"])
        .current_dir(&public)
        .output()
        .unwrap();

    let mut cmd = assert_cmd::Command::cargo_bin("qtadmin").unwrap();
    cmd.current_dir(root.path());
    cmd.args([
        "share",
        "test",
        "--no-decide",
        "--no-llm",
        "--no-build",
        // 不传 --no-commit，使用 LLM 生成 commit 信息
    ])
    .assert()
    .success()
    .stdout(predicates::str::contains("git:"));

    // 验证确有 commit
    let log = std::process::Command::new("git")
        .args(["log", "--oneline", "-1"])
        .current_dir(&public)
        .output()
        .unwrap();
    let output = String::from_utf8_lossy(&log.stdout);
    assert!(!output.is_empty(), "应有 git 提交");
}
