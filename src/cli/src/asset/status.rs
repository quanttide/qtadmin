use std::path::PathBuf;
use std::process::Command;

use anyhow::Result;
use clap::Args;

/// 查看数字资产当前状态
#[derive(Args)]
pub struct StatusArgs {
    /// 资产仓库路径
    #[arg(default_value = ".")]
    pub repo_path: String,
}

pub fn run(args: &StatusArgs) -> Result<()> {
    let repo_path = PathBuf::from(&args.repo_path).canonicalize()?;

    if !repo_path.join(".git").exists() {
        anyhow::bail!("不是 Git 仓库: {}", repo_path.display());
    }

    println!("📂 资产仓库: {}", repo_path.display());
    println!();

    // 仓库基本信息
    let remote = run_git(&repo_path, &["remote", "get-url", "origin"]);
    let branch = run_git(&repo_path, &["rev-parse", "--abbrev-ref", "HEAD"]);
    let last_commit = run_git(&repo_path, &["log", "--oneline", "-1"]);

    println!("  远程: {remote}");
    println!("  分支: {branch}");
    println!("  最新: {last_commit}");

    // 未提交变更
    let status_out = run_git(&repo_path, &["status", "--short"]);
    let changed = status_out.lines().count();
    if changed > 0 {
        println!();
        println!("  ⚠️  有 {changed} 个文件未提交:");
        for line in status_out.lines().take(10) {
            println!("    {line}");
        }
        if changed > 10 {
            println!("    ... 还有 {} 个", changed - 10);
        }
    } else {
        println!();
        println!("  ✅ 工作区干净");
    }

    // 文件统计
    let file_count = run_git(&repo_path, &["ls-files", "*.md"]).lines().count();
    let total_files = run_git(&repo_path, &["ls-files"]).lines().count();
    println!();
    println!(
        "  文件: {} 个（其中 {file_count} 个 Markdown）",
        total_files
    );

    // 最后提交时间
    let last_date = run_git(&repo_path, &["log", "-1", "--format=%ci"]);
    println!("  最后提交: {last_date}");

    Ok(())
}

fn run_git(repo: &PathBuf, args: &[&str]) -> String {
    Command::new("git")
        .args(args)
        .current_dir(repo)
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .map(|s| s.trim().to_string())
        .unwrap_or_default()
}
