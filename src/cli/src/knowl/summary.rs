//! 知识总结（knowl summary）
//!
//! 与 extract（本体抽取，结构化产物）解耦：summary 忠实总结现有知识，
//! 不添加知识之外的推断或建议。

use std::fs;
use std::path::Path;

use anyhow::{Context, Result};
use quanttide_agent::llm::{CompleteOptions, LLM};
use quanttide_agent::message::Message;

/// 知识总结提示词：按主题归纳现有知识，状态作为条目属性标注
const SUMMARY_PROMPT: &str = r#"你是一个知识总结工具。忠实总结给定的结构化知识，不添加知识之外的推断或建议。

按主题归纳知识，输出 Markdown 总结，包含：
1. 知识概况：条目总数与覆盖的主题清单
2. 主题归纳：按主题分组，每个主题下汇总相关条目的要点，每条标注状态（settled/evolving/draft）
3. 主题间关联：主题之间的关联与依赖"#;

/// 从结构化知识（JSON Value）总结为 Markdown。
pub fn summarize(data: &serde_json::Value) -> Result<String> {
    let api_key = std::env::var("DEEPSEEK_API_KEY")?;
    let llm = LLM::new("deepseek-chat", "https://api.deepseek.com", &api_key);

    let input = serde_yaml::to_string(data)?;
    let messages = vec![
        Message::new("system", SUMMARY_PROMPT),
        Message::new("user", &format!("总结以下结构化知识：\n\n{}", input)),
    ];

    let options = CompleteOptions {
        max_tokens: Some(2048),
        temperature: Some(0.3),
        ..Default::default()
    };

    let resp = llm.complete(&messages, options)?;
    Ok(resp.content)
}

#[derive(clap::Args)]
pub struct SummaryArgs {
    /// 输入知识文件路径（YAML）
    #[arg(long, short = 'i', required = true)]
    pub input: String,

    /// 输出目录
    #[arg(long, short = 'o', default_value = "output")]
    pub output: String,
}

pub fn run(args: &SummaryArgs) -> Result<()> {
    let raw = fs::read_to_string(&args.input)
        .with_context(|| format!("读取文件失败: {}", args.input))?;
    let data: serde_json::Value = serde_yaml::from_str(&raw)?;

    let summary = summarize(&data)?;

    let output_dir = Path::new(&args.output);
    fs::create_dir_all(output_dir)?;
    let path = output_dir.join("summary.md");
    fs::write(&path, &summary)?;
    println!("总结: {}", path.display());

    Ok(())
}
