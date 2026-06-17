use anyhow::Result;
use std::env;
use std::fs;
use std::path::PathBuf;

use quanttide_agent::llm::{CompleteOptions, LLM};
use quanttide_agent::message::Message;

const SYSTEM_PROMPT: &str = r#"你是一个知识提取工具。从原始文档中提取业务规则并评估其可编码性。

输出 JSON，包含：
1. rules: 逐条规则（name, source, score, reason），score 为 1-5
2. rate: 可编码率（≥4分的规则占比）
3. ambiguities: 文档中的模糊点（category, description）
4. issues: 影响编码的具体问题（title, source, problem, suggestion）
5. observations: 值得记录的分析观察

评分标准：5=直接可编码，4=微调后可编码，3=需补充信息，2=模糊需重写，1=无法编码"#;

#[derive(clap::Args)]
pub struct AcquireArgs {
    /// 输入文件路径
    #[arg(long, default_value = "")]
    pub input: String,

    /// 输出目录
    #[arg(long, default_value = "data")]
    pub output: String,
}

fn default_sources() -> Vec<(String, PathBuf)> {
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let assets = root.join("assets").join("business");
    vec![
        ("bylaw".into(), assets.join("bylaw.md")),
        ("handbook".into(), assets.join("handbook.md")),
        ("tutorial".into(), assets.join("tutorial.md")),
        ("profile".into(), assets.join("profile").join("index.md")),
    ]
}

fn read_text(path: &PathBuf) -> String {
    fs::read_to_string(path).unwrap_or_default()
}

pub fn run(args: &AcquireArgs) -> Result<()> {
    let combined = if args.input.is_empty() {
        let mut text = String::new();
        for (name, path) in default_sources() {
            text.push_str(&format!("=== {} ===\n{}\n\n", name, read_text(&path)));
        }
        text
    } else {
        read_text(&PathBuf::from(&args.input))
    };

    println!("共 {} 字符", combined.len());

    let api_key = env::var("DEEPSEEK_API_KEY")?;
    let llm = LLM::new("deepseek-chat", "https://api.deepseek.com", &api_key);

    let messages = vec![
        Message::new("system", SYSTEM_PROMPT),
        Message::new("user", &format!("从以下原始文档中提取知识：\n\n{}", combined)),
    ];

    let options = CompleteOptions {
        response_format: Some(serde_json::json!({"type": "json_object"})),
        ..Default::default()
    };

    let resp = llm.complete(&messages, options)?;
    let content = quanttide_agent::llm::parse_structured_output(&resp.content)
        .map_err(|e| anyhow::anyhow!("解析失败: {}", e))?;

    let output_dir = PathBuf::from(&args.output);
    fs::create_dir_all(&output_dir)?;
    let yaml = serde_yaml::to_string(&content)?;
    fs::write(output_dir.join("extracted.yaml"), &yaml)?;

    let rules = content["rules"].as_array().map(|a| a.len()).unwrap_or(0);
    let rate = content["rate"].as_f64().unwrap_or(0.0);
    let ambiguities = content["ambiguities"].as_array().map(|a| a.len()).unwrap_or(0);
    let issues = content["issues"].as_array().map(|a| a.len()).unwrap_or(0);

    println!("规则数: {}", rules);
    println!("可编码率: {:.0}%", rate * 100.0);
    println!("模糊点: {} 条", ambiguities);
    println!("编码问题: {} 个", issues);
    println!("输出: {:?}", output_dir.join("extracted.yaml"));

    Ok(())
}
