use std::path::PathBuf;
use std::process::Command;

use anyhow::{Context, Result};
use clap::Args;

/// 手册内容质量状态评估
#[derive(Args)]
pub struct StatusArgs {
    /// 输出 JSON 路径
    #[arg(short, long, default_value = "p40-results.json")]
    pub output: String,

    /// 输出 Markdown 报告路径
    #[arg(short = 'r', long, default_value = "p40-report.md")]
    pub report: String,

    /// 断点续评
    #[arg(long)]
    pub resume: bool,

    /// 快速模式：仅评估 index.md
    #[arg(long)]
    pub quick: bool,

    /// 限制评估文件数量
    #[arg(long)]
    pub limit: Option<usize>,
}

pub fn run(args: &StatusArgs) -> Result<()> {
    let script_dir = find_script_dir()?;
    let script_path = script_dir.join("p40-evaluate.py");

    if !script_path.exists() {
        anyhow::bail!("评估脚本不存在: {}", script_path.display());
    }

    let mut cmd = Command::new("python3");
    cmd.arg(&script_path)
        .arg("--output")
        .arg(&args.output)
        .arg("--report")
        .arg(&args.report);

    if args.resume {
        cmd.arg("--resume");
    }
    if args.quick {
        cmd.arg("--quick");
    }
    if let Some(limit) = args.limit {
        cmd.arg("--limit").arg(limit.to_string());
    }

    let status = cmd
        .status()
        .context("无法启动 p40 评估脚本，请确认已安装 python3 且 DEEPSEEK_API_KEY 已设置")?;

    if !status.success() {
        anyhow::bail!("评估脚本异常退出: {}", status);
    }

    Ok(())
}

fn find_script_dir() -> Result<PathBuf> {
    let candidates = [
        "examples/default/examples",
        "../examples/default/examples",
        "../../examples/default/examples",
    ];
    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    for rel in &candidates {
        let candidate = manifest_dir.join(rel);
        if candidate.join("p40-evaluate.py").exists() {
            return Ok(candidate);
        }
    }
    anyhow::bail!("找不到 p40-evaluate.py，请确保 examples 子模块已初始化")
}
