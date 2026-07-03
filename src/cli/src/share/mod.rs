mod commit;
mod config;
mod copy;
mod decide;
mod sanitize;

use std::env;
use std::path::PathBuf;

use anyhow::Result;
use clap::Args;
use quanttide_agent::llm::LLM;

/// 将私仓代码脱敏后发布到公仓
#[derive(Args)]
pub struct ShareArgs {
    /// 配置中的项目名
    pub project: String,

    /// 版本号（可选）
    pub version: Option<String>,

    /// 仅预览脱敏内容，不写入文件
    #[arg(long, default_value_t = false)]
    pub dry_run: bool,

    /// 跳过 LLM 判断目标位置，使用配置中的 sync_dst
    #[arg(long, default_value_t = false)]
    pub no_decide: bool,

    /// 跳过 LLM 脱敏，仅使用静态规则
    #[arg(long, default_value_t = false)]
    pub no_llm: bool,

    /// 跳过编译验证
    #[arg(long, default_value_t = false)]
    pub no_build: bool,

    /// 跳过 git commit
    #[arg(long, default_value_t = false)]
    pub no_commit: bool,
}

pub fn run(args: &ShareArgs) -> Result<()> {
    // Step 0: 加载配置
    let config_path = config::find_config()?;
    let cfg = config::load_config(&config_path)?;
    let project = cfg
        .project
        .get(&args.project)
        .ok_or_else(|| anyhow::anyhow!("配置中找不到项目 [{}]", args.project))?;

    let src = &project.private_src;
    let dst = &project.public_dst;
    let sync_src = project.sync_src.as_deref();
    let mut sync_dst = project.sync_dst.as_deref().map(|s| s.to_string());
    let build_cmd = project.build_cmd.as_deref();
    let exclude = project.exclude.as_deref();

    // 初始化 LLM
    let llm = init_llm();

    // Step 1: LLM 判断目标位置
    if sync_dst.is_none() && !args.no_decide && llm.is_some() {
        println!("\n=== LLM 判断目标位置 ===");
        let destination = decide::decide_destination(src, dst, sync_src, llm.as_ref().unwrap())?;
        sync_dst = Some(destination);
    }

    // Step 2: 复制
    let sync_dst_str = sync_dst.as_deref();
    println!("\n=== 复制: {} → {} ===", src.display(), dst.display());
    let dst_dir = copy::rsync_copy(src, dst, sync_src, sync_dst_str, exclude)?;

    // Step 3: 脱敏
    println!("\n=== 脱敏 ===");
    sanitize::sanitize(
        &dst_dir,
        args.dry_run,
        llm.as_ref().filter(|_| !args.no_llm),
    )?;

    // Step 4: 编译验证
    if let Some(cmd) = build_cmd {
        if !args.no_build {
            run_build(cmd, dst)?;
        }
    }

    // Step 5: Git commit
    if !args.no_commit {
        let version = args.version.as_deref();
        commit::git_commit(
            dst,
            sync_dst_str,
            version,
            llm.as_ref().filter(|_| !args.no_llm),
        )?;
    }

    println!("\n=== 完成 ===");
    println!("目标: {}", dst_dir.display());
    println!("\n下一步:");
    println!("  cd {} && git push --tags", dst.display());

    Ok(())
}

fn init_llm() -> Option<LLM> {
    let api_key = env::var("DEEPSEEK_API_KEY")
        .or_else(|_| env::var("AI_REVIEW_API_KEY"))
        .ok()?;
    let base_url =
        env::var("AI_REVIEW_BASE_URL").unwrap_or_else(|_| "https://api.deepseek.com".to_string());
    let model = env::var("AI_REVIEW_MODEL").unwrap_or_else(|_| "deepseek-chat".to_string());

    // 验证 key 是否有效
    if api_key.is_empty() || api_key == "sk-xxx" {
        return None;
    }

    Some(LLM::new(&model, &base_url, &api_key))
}

fn run_build(cmd: &str, work_dir: &PathBuf) -> Result<()> {
    println!("\n=== 编译验证: {} ===", cmd);
    let status = std::process::Command::new("sh")
        .args(["-c", cmd])
        .current_dir(work_dir)
        .status()
        .map_err(|e| anyhow::anyhow!("执行构建命令失败: {}", e))?;

    if !status.success() {
        anyhow::bail!("编译失败，发布中止");
    }
    println!("  ✓ 编译通过");
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run_build_success() {
        let dir = tempfile::tempdir().unwrap();
        let result = run_build("echo hello", &dir.path().to_path_buf());
        assert!(result.is_ok());
    }

    #[test]
    fn test_run_build_failure() {
        let dir = tempfile::tempdir().unwrap();
        let result = run_build("exit 1", &dir.path().to_path_buf());
        assert!(result.is_err());
    }

    #[test]
    fn cleanup_env() {
        env::remove_var("DEEPSEEK_API_KEY");
        env::remove_var("AI_REVIEW_API_KEY");
        env::remove_var("AI_REVIEW_BASE_URL");
        env::remove_var("AI_REVIEW_MODEL");
    }

    #[test]
    fn test_init_llm_no_key() {
        cleanup_env();
        assert!(init_llm().is_none());
    }

    #[test]
    fn test_init_llm_empty_key() {
        cleanup_env();
        env::set_var("DEEPSEEK_API_KEY", "");
        assert!(init_llm().is_none());
    }

    #[test]
    fn test_init_llm_sk_xxx() {
        cleanup_env();
        env::set_var("DEEPSEEK_API_KEY", "sk-xxx");
        assert!(init_llm().is_none());
    }

    #[test]
    fn test_init_llm_deepseek_key() {
        cleanup_env();
        env::set_var("DEEPSEEK_API_KEY", "sk-real-key-12345");
        assert!(init_llm().is_some());
    }

    #[test]
    fn test_init_llm_review_key_fallback() {
        cleanup_env();
        env::set_var("AI_REVIEW_API_KEY", "sk-review-key");
        assert!(init_llm().is_some());
    }
}
