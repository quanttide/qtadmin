// 量潮招聘示例
// 侧重于内部管理和量潮招聘相关的活动。
// 比如从内部讨论中获取招聘政策等。
//
// 招聘讨论分散在很多聊天记录中（群聊与单聊），
// 本示例演示完整的知识提取链路：
// 1. 通过 `connect::chat::LarkChatFetcher` 跨群搜索「招聘」讨论
// 2. 通过 `knowl::acquire` 用 LLM 从聊天记录中提取招聘政策

use std::fs;
use std::path::PathBuf;

use qtadmin_cli::connect::chat::LarkChatFetcher;
use qtadmin_cli::knowl::acquire;

/// 招聘政策提取提示词（knowl 模块 LLM 使用）
const POLICY_PROMPT: &str = r#"你是一个招聘政策提取工具。从聊天记录中提取招聘相关的政策与规则。

输出 JSON：
1. policies: 逐条政策（name, description, source），source 为原始消息片段
2. summary: 一句话总结当前招聘政策方向"#;

fn main() -> anyhow::Result<()> {
    // 1. 通过 connect 模块跨群搜索「招聘」聊天记录（lark-cli im +messages-search）
    let fetcher = LarkChatFetcher;
    let msgs = fetcher.search("招聘")?;

    println!("=== 招聘讨论（connect 模块跨群搜索，共 {} 条，展示前 10 条）===\n", msgs.len());
    for m in msgs.iter().take(10) {
        println!("{} | {} | {}", m.time, m.sender, m.content);
    }

    // 2. 通过 knowl 模块用 LLM 提取招聘政策
    let discussion = msgs
        .iter()
        .map(|m| format!("[{}] {}: {}", m.time, m.sender, m.content))
        .collect::<Vec<_>>()
        .join("\n");

    println!("\n=== knowl 模块提取招聘政策（LLM）===\n");
    let result = acquire::extract_from_text(&discussion, POLICY_PROMPT)?;

    if let Some(policies) = result["policies"].as_array() {
        println!("提取到 {} 项政策：\n", policies.len());
        for p in policies {
            let name = p["name"].as_str().unwrap_or("?");
            let description = p["description"].as_str().unwrap_or("");
            println!("- {}：{}", name, description);
        }
    }
    if let Some(summary) = result["summary"].as_str() {
        println!("\n总结：{}", summary);
    }

    // 3. 保存到本地数据目录（src/cli/data，与 knowl 产物同处）
    let output_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("data");
    fs::create_dir_all(&output_dir)?;
    let yaml = serde_yaml::to_string(&result)?;
    let output_path = output_dir.join("recruitment_policies.yaml");
    fs::write(&output_path, &yaml)?;
    println!("\n已保存: {}", output_path.display());

    Ok(())
}
