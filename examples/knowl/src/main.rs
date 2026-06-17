use std::env;
use std::path::PathBuf;
use std::fs;

const SYSTEM_PROMPT: &str = r#"你是一个知识提取工具。从原始文档中提取业务规则并评估其可编码性。

输出 JSON，包含：
1. rules: 逐条规则（name, source, score, reason），score 为 1-5
2. rate: 可编码率（≥4分的规则占比）
3. ambiguities: 文档中的模糊点（category, description）
4. issues: 影响编码的具体问题（title, source, problem, suggestion）
5. observations: 值得记录的分析观察

评分标准：5=直接可编码，4=微调后可编码，3=需补充信息，2=模糊需重写，1=无法编码"#;

fn root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
}

fn read_sources() -> String {
    let assets = root().join("assets").join("business");
    let mut combined = String::new();

    let files = [
        ("bylaw", assets.join("bylaw.md")),
        ("handbook", assets.join("handbook.md")),
        ("tutorial", assets.join("tutorial.md")),
        ("profile", assets.join("profile").join("index.md")),
    ];

    for (name, path) in &files {
        if let Ok(content) = fs::read_to_string(path) {
            combined.push_str(&format!("=== {} ===\n{}\n\n", name, content));
        }
    }

    combined
}

async fn extract_with_llm(text: &str) -> Result<serde_json::Value, Box<dyn std::error::Error>> {
    let api_key = env::var("DEEPSEEK_API_KEY")?;

    let client = reqwest::Client::new();
    let resp = client
        .post("https://api.deepseek.com/chat/completions")
        .header("Authorization", format!("Bearer {}", api_key))
        .header("Content-Type", "application/json")
        .json(&serde_json::json!({
            "model": "deepseek-chat",
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": format!("从以下原始文档中提取知识：\n\n{}", text)}
            ],
            "response_format": {"type": "json_object"}
        }))
        .send()
        .await?;

    let body: serde_json::Value = resp.json().await?;
    let content = body["choices"][0]["message"]["content"]
        .as_str()
        .ok_or("LLM 返回格式异常")?;

    Ok(serde_json::from_str(content)?)
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let combined = read_sources();
    println!("读取 4 份原始文件，共 {} 字符", combined.len());

    let data = extract_with_llm(&combined).await?;

    let output_dir = root().join("data");
    fs::create_dir_all(&output_dir)?;
    let yaml = serde_yaml::to_string(&data)?;
    fs::write(output_dir.join("extracted.yaml"), &yaml)?;

    let rules = data["rules"].as_array().map(|a| a.len()).unwrap_or(0);
    let rate = data["rate"].as_f64().unwrap_or(0.0);
    let ambiguities = data["ambiguities"].as_array().map(|a| a.len()).unwrap_or(0);
    let issues = data["issues"].as_array().map(|a| a.len()).unwrap_or(0);

    println!("规则数: {}", rules);
    println!("可编码率: {:.0}%", rate * 100.0);
    println!("模糊点: {} 条", ambiguities);
    println!("编码问题: {} 个", issues);
    println!("\n输出: {:?}", output_dir.join("extracted.yaml"));

    Ok(())
}
