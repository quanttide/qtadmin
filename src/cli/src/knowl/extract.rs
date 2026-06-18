use anyhow::{Context, Result};
use chrono::Local;
use quanttide_agent::llm::{parse_structured_output, CompleteOptions, LLM};
use quanttide_agent::message::Message;
use serde_json::Value;
use std::collections::{BTreeSet, HashSet};
use std::env;
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};

// ── Schema 编译 ──

const TYPE_MAP: &[(&str, &str)] = &[
    ("string", "string"),
    ("integer", "integer"),
    ("float", "number"),
    ("boolean", "boolean"),
    ("object", "object"),
    ("array", "array"),
    ("enum", "string"),
];

fn map_type(ftype: &str) -> &str {
    TYPE_MAP
        .iter()
        .find(|(k, _)| *k == ftype)
        .map(|(_, v)| *v)
        .unwrap_or("string")
}

fn compile_field(field: &Value) -> Value {
    let ftype = field["type"].as_str().unwrap_or("string");
    let desc = field["description"].as_str().unwrap_or("");
    let mut prop = serde_json::Map::new();

    if !desc.is_empty() {
        prop.insert("description".into(), Value::String(desc.into()));
    }

    match ftype {
        "enum" => {
            prop.insert("type".into(), Value::String("string".into()));
            if let Some(vals) = field.get("values").and_then(|v| v.as_array()) {
                prop.insert(
                    "enum".into(),
                    Value::Array(vals.iter().map(|v| v.clone()).collect()),
                );
            }
        }
        "array" => {
            prop.insert("type".into(), Value::String("array".into()));
            if let Some(items) = field.get("items") {
                if let Some(sub_fields) = items.get("fields").and_then(|v| v.as_array()) {
                    let mut item_schema = serde_json::Map::new();
                    item_schema.insert("type".into(), Value::String("object".into()));
                    item_schema.insert("additionalProperties".into(), Value::Bool(false));
                    let mut props = serde_json::Map::new();
                    for sf in sub_fields {
                        let name = sf["name"].as_str().unwrap_or("");
                        props.insert(name.into(), compile_field(sf));
                    }
                    item_schema.insert("properties".into(), Value::Object(props));
                    prop.insert("items".into(), Value::Object(item_schema));
                } else if items.get("name").is_some() {
                    prop.insert("items".into(), compile_field(items));
                } else {
                    prop.insert("items".into(), serde_json::json!({"type": "string"}));
                }
            } else {
                prop.insert("items".into(), serde_json::json!({"type": "string"}));
            }
        }
        "object" => {
            prop.insert("type".into(), Value::String("object".into()));
            let mut props = serde_json::Map::new();
            if let Some(sub_fields) = field.get("fields").and_then(|v| v.as_array()) {
                for sf in sub_fields {
                    let name = sf["name"].as_str().unwrap_or("");
                    props.insert(name.into(), compile_field(sf));
                }
            }
            prop.insert("properties".into(), Value::Object(props));
            prop.insert("additionalProperties".into(), Value::Bool(false));
        }
        _ => {
            let schema_type = map_type(ftype);
            prop.insert("type".into(), Value::String(schema_type.into()));
            if ftype.contains("| null") {
                prop.insert(
                    "type".into(),
                    Value::Array(vec![
                        Value::String(schema_type.into()),
                        Value::String("null".into()),
                    ]),
                );
            }
            if let Some(range) = field.get("range").and_then(|v| v.as_array()) {
                if let Some(min) = range.first().and_then(|v| v.as_f64()) {
                    prop.insert("minimum".into(), Value::from(min));
                }
                if range.len() > 1 {
                    if let Some(max) = range.get(1).and_then(|v| v.as_f64()) {
                        prop.insert("maximum".into(), Value::from(max));
                    }
                }
            }
        }
    }

    if !prop.contains_key("type") {
        prop.insert("type".into(), Value::String("string".into()));
    }
    Value::Object(prop)
}

fn compile_schema(model_data: &Value, top_key: &str) -> Result<Value> {
    let model = model_data
        .get(top_key)
        .context(format!("模型声明未找到顶层 key '{}'", top_key))?;

    let desc = model.get("description").and_then(|v| v.as_str()).unwrap_or("");
    let mut schema = serde_json::Map::new();
    schema.insert("type".into(), Value::String("object".into()));
    schema.insert("description".into(), Value::String(desc.into()));
    schema.insert("additionalProperties".into(), Value::Bool(false));

    let mut properties = serde_json::Map::new();
    if let Some(fields) = model.get("fields").and_then(|v| v.as_array()) {
        for field in fields {
            let name = field["name"].as_str().unwrap_or("");
            properties.insert(name.into(), compile_field(field));
        }
    }
    schema.insert("properties".into(), Value::Object(properties));

    Ok(Value::Object(schema))
}

fn format_schema_for_prompt(schema: &Value) -> String {
    let mut lines = vec!["输出 JSON 格式（严格遵循以下 schema）：".to_string()];

    fn fmt_prop(name: &str, prop: &Value, depth: usize, lines: &mut Vec<String>) {
        let pad = "  ".repeat(depth);
        let ptype = prop.get("type");
        let desc = prop.get("description").and_then(|v| v.as_str()).unwrap_or("");

        let ptype_str = match ptype {
            Some(Value::String(s)) => s.clone(),
            Some(Value::Array(arr)) => arr
                .iter()
                .filter_map(|v| v.as_str())
                .collect::<Vec<_>>()
                .join(" | "),
            _ => "string".into(),
        };

        let mut line = format!("{}- {}: {}", pad, name, ptype_str);
        if !desc.is_empty() {
            line.push_str(&format!("  # {}", desc));
        }
        lines.push(line);

        if ptype_str == "object" || ptype_str.contains("object") {
            if let Some(props) = prop.get("properties").and_then(|v| v.as_object()) {
                for (sub_name, sub_prop) in props {
                    fmt_prop(sub_name, sub_prop, depth + 1, lines);
                }
            }
        } else if ptype_str == "array" {
            if let Some(items) = prop.get("items") {
                let items_type = items
                    .get("type")
                    .and_then(|v| v.as_str())
                    .unwrap_or("string");
                let items_type_str = items
                    .get("type")
                    .and_then(|v| v.as_array())
                    .map(|arr| {
                        arr.iter()
                            .filter_map(|v| v.as_str())
                            .collect::<Vec<_>>()
                            .join(" | ")
                    })
                    .unwrap_or_else(|| items_type.to_string());

                if items_type == "object" {
                    lines.push(format!("{}  items: object", pad));
                    if let Some(props) = items.get("properties").and_then(|v| v.as_object()) {
                        for (sub_name, sub_prop) in props {
                            fmt_prop(sub_name, sub_prop, depth + 2, lines);
                        }
                    }
                } else if items_type_str != "string" {
                    lines.push(format!("{}  items: {}", pad, items_type_str));
                } else if let Some(enum_vals) = items.get("enum").and_then(|v| v.as_array()) {
                    let vals: Vec<String> = enum_vals
                        .iter()
                        .filter_map(|v| v.as_str())
                        .map(|s| s.to_string())
                        .collect();
                    lines.push(format!("{}  items: enum [{}]", pad, vals.join(", ")));
                }
            }
        }

        if let Some(enum_vals) = prop.get("enum").and_then(|v| v.as_array()) {
            let vals: Vec<String> = enum_vals
                .iter()
                .filter_map(|v| v.as_str())
                .map(|s| s.to_string())
                .collect();
            lines.push(format!("{}  enum: [{}]", pad, vals.join(", ")));
        }
    }

    if let Some(props) = schema.get("properties").and_then(|v| v.as_object()) {
        for (name, prop) in props {
            fmt_prop(name, prop, 1, &mut lines);
        }
    }

    lines.push(String::new());
    lines.push("规则：".into());
    lines.join("\n")
}

// ── 通用工具 ──

fn get_llm() -> Result<LLM> {
    let api_key = env::var("DEEPSEEK_API_KEY")
        .context("请设置 DEEPSEEK_API_KEY 环境变量")?;
    Ok(LLM::new("deepseek-chat", "https://api.deepseek.com", &api_key))
}

fn call_llm(
    prompt: &str,
    text: &str,
    llm: &LLM,
    max_tokens: u32,
) -> Result<Value> {
    let messages = vec![
        Message::new("system", prompt),
        Message::new("user", text),
    ];
    let options = CompleteOptions {
        max_tokens: Some(max_tokens),
        temperature: Some(0.1),
        response_format: Some(serde_json::json!({"type": "json_object"})),
        ..Default::default()
    };
    let resp = llm.complete(&messages, options)
        .map_err(|e| anyhow::anyhow!("LLM 调用失败: {}", e.0))?;
    let content = parse_structured_output(&resp.content)
        .map_err(|e| anyhow::anyhow!("LLM 解析失败: {}", e))?;
    Ok(content)
}

fn read_yaml(path: &Path) -> Result<Value> {
    let file = fs::File::open(path)
        .with_context(|| format!("读取文件失败: {:?}", path))?;
    let value: Value = serde_yaml::from_reader(file)?;
    Ok(value)
}

fn write_yaml(data: &Value, path: &Path) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    let yaml = serde_yaml::to_string(data)?;
    fs::write(path, &yaml)?;
    Ok(())
}

fn write_markdown(text: &str, path: &Path) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(path, text)?;
    Ok(())
}

// ── CLI ──

#[derive(clap::Args)]
pub struct ExtractArgs {
    /// 本体 YAML 路径
    #[arg(long, short = 'i', required = true)]
    pub input: String,

    /// 抽取类型 (cognition, todo, motif, annotate, worldbuilding, scene-graph)
    #[arg(long = "type", short = 't', required = true)]
    pub extract_type: String,

    /// 模型声明 YAML 路径（约束 LLM 输出）
    #[arg(long, short = 'm')]
    pub model: Option<String>,

    /// 输出目录
    #[arg(long, short = 'o', default_value = "output")]
    pub output: String,

    /// 限制处理段数（测试用）
    #[arg(long)]
    pub limit: Option<usize>,
}

// ── cognition: journal → cognition.yaml ──

const EXTRACT_PROMPT_BASE: &str = r#"从以下日记段落中提取结构化认知要素，包含图式。

{format_instructions}

规则：
- situation 从原文推断，不编造
- intentions 只提取有行动导向的内容（想要/打算/决定/需要）
- ideas 只提取认知产出（发现/想到/怀疑/感觉）
- schemas 识别本段触发的重复认知模式（图式），每个图式包含名称+所属领域+触发情境+响应
  - domain 标注所属领域（如"叙事工程"、"系统架构"、"团队管理"）
  - 图式名称用已有认知模式名（如"团队脆弱期的收缩策略"、"讲故事传递意图"）
  - 如果是未见过的模式，用概括性名称命名
  - 不需要跨段验证，只关注本段触发的模式
- 如果某类不存在，输出空数组或null
- 纯 JSON。"#;

fn extract_cognition(
    data: &Value,
    output: &Path,
    model_schema: Option<&Value>,
    limit: Option<usize>,
) -> Result<()> {
    let entries = data["entries"]
        .as_array()
        .context("输入数据缺少 'entries' 字段")?;
    let total = entries.len();

    let prompt = if let Some(schema) = model_schema {
        let fmt = format_schema_for_prompt(schema);
        EXTRACT_PROMPT_BASE.replace("{format_instructions}", &fmt)
    } else {
        EXTRACT_PROMPT_BASE.replace(
            "{format_instructions}",
            r#"输出 JSON：
{
  "situation": {
    "time": {"raw": "时间表述或null", "inferred_date": "推断日期或null"},
    "location": "地点或null",
    "participants": ["参与者列表"],
    "activity": "活动概括（15字）",
    "mood": {"raw": "情绪词或null", "valence": -3~3, "arousal": 0~5}
  },
  "intentions": [
    {"type": "goal/motive/plan/commitment", "content": "意图原文"}
  ],
  "ideas": [
    {"type": "insight/hypothesis/question/analogy", "content": "想法原文"}
  ]
}"#,
        )
    };

    let done_file = output.join("_done.txt");
    let mut done_set: HashSet<String> = HashSet::new();
    if done_file.exists() {
        let content = fs::read_to_string(&done_file).unwrap_or_default();
        for line in content.lines() {
            let line = line.trim();
            if !line.is_empty() {
                done_set.insert(line.to_string());
            }
        }
        eprintln!("\n  发现断点: 已处理 {}/{} 段", done_set.len(), total);
    }

    let out_file = output.join("cognition.yaml");
    let mut existing: Vec<Value> = Vec::new();
    if out_file.exists() {
        if let Ok(val) = read_yaml(&out_file) {
            if let Some(segments) = val.get("segments").and_then(|v| v.as_array()) {
                existing = segments.clone();
            }
        }
    }

    let llm = get_llm()?;
    let mut new_results: Vec<Value> = Vec::new();
    let entries_iter: Vec<&Value> = match limit {
        Some(n) => entries.iter().take(n).collect(),
        None => entries.iter().collect(),
    };

    for (idx, entry) in entries_iter.iter().enumerate() {
        let seg_id = format!("{:03}", idx + 1);
        if done_set.contains(&seg_id) {
            continue;
        }

        eprint!(
            "\r  处理中: {}/{} ({}%)",
            idx + 1,
            total,
            (idx + 1) * 100 / total.max(1)
        );
        let _ = std::io::stderr().flush();

        let text = entry["text"].as_str().unwrap_or("");
        let source = entry.get("source").and_then(|v| v.as_str()).unwrap_or("");

        let mut result = call_llm(&prompt, text, &llm, 1024)?;
        if let Some(obj) = result.as_object_mut() {
            obj.insert("_source".into(), Value::String(source.into()));
            let raw: String = text.chars().take(100).collect();
            obj.insert("_raw".into(), Value::String(raw));
        }
        new_results.push(result);

        fs::write(&done_file, format!("{}\n", seg_id))?;
        let all: Vec<Value> = existing.iter().chain(new_results.iter()).cloned().collect();
        write_yaml(&serde_json::json!({"segments": all}), &out_file)?;
    }

    if done_file.exists() {
        let _ = fs::remove_file(&done_file);
    }

    let all_results: Vec<Value> = existing.iter().chain(new_results.iter()).cloned().collect();

    let total_situations = all_results
        .iter()
        .filter(|r| r.get("situation").and_then(|v| v.as_object()).is_some())
        .count();
    let total_intentions: usize = all_results
        .iter()
        .map(|r| {
            r.get("intentions")
                .and_then(|v| v.as_array())
                .map(|a| a.len())
                .unwrap_or(0)
        })
        .sum();
    let total_ideas: usize = all_results
        .iter()
        .map(|r| {
            r.get("ideas")
                .and_then(|v| v.as_array())
                .map(|a| a.len())
                .unwrap_or(0)
        })
        .sum();

    eprintln!(
        "\r  处理完成: {}/{} (100%)",
        all_results.len(),
        all_results.len()
    );
    println!("\n结果:");
    println!("  有情境的段落: {}/{}", total_situations, all_results.len());
    println!("  意图总数: {}", total_intentions);
    println!("  想法总数: {}", total_ideas);
    println!("\n意图清单:");
    for r in &all_results {
        if let Some(intents) = r.get("intentions").and_then(|v| v.as_array()) {
            for intent in intents {
                let t = intent.get("type").and_then(|v| v.as_str()).unwrap_or("");
                let c = intent
                    .get("content")
                    .and_then(|v| v.as_str())
                    .unwrap_or("");
                let preview: String = c.chars().take(50).collect();
                println!("  [{}] {}", t, preview);
            }
        }
    }
    println!("\n想法清单:");
    for r in &all_results {
        if let Some(ideas) = r.get("ideas").and_then(|v| v.as_array()) {
            for idea in ideas {
                let t = idea.get("type").and_then(|v| v.as_str()).unwrap_or("");
                let c = idea
                    .get("content")
                    .and_then(|v| v.as_str())
                    .unwrap_or("");
                let preview: String = c.chars().take(50).collect();
                println!("  [{}] {}", t, preview);
            }
        }
    }

    Ok(())
}

// ── todo: journal → TODO.md ──

const EXTRACT_INTENT_PROMPT_BASE: &str = r#"从以下日记段落中提取情境和行动计划类的意图。

{format_instructions}

规则：
- 只提取 plan（计划）和 commitment（承诺）类型的意图
- 从原文中找出有行动导向的内容
- 如果不存在，输出空数组
- 纯 JSON。"#;

const JUDGE_PROMPT: &str = r#"判断以下意图是否可执行，并给出领域分类。

情境：{situation}
意图：{intent}

规则：
- 可执行：有明确动词+具体对象，知道第一步做什么
- 模糊方向：有方向但缺具体动作或对象
- 不可执行：纯意图/战略/价值观/元认知

领域分类根据情境判断——从对话背景（活动描述）推断该意图属于哪个领域。

输出 JSON：
{{
  "verdict": "可执行/模糊方向/不可执行",
  "first_step": "如果是可执行，建议的第一步（15字）",
  "domain": "系统架构/小说创作/团队管理/工具链/实验验证/数据/方法论",
  "reason": "判断理由（10字）"
}}
纯 JSON。"#;

fn extract_todo(
    data: &Value,
    output: &Path,
    model_schema: Option<&Value>,
    limit: Option<usize>,
) -> Result<()> {
    let entries = data["entries"]
        .as_array()
        .context("输入数据缺少 'entries' 字段")?;
    let total = entries.len();

    let prompt = if let Some(schema) = model_schema {
        let fmt = schema
            .get("properties")
            .and_then(|p| p.get("intentions"))
            .map(|intent_schema| {
                let simple_schema = serde_json::json!({
                    "type": "object",
                    "properties": {
                        "activity": {
                            "type": "string",
                            "description": "活动概括（15字）"
                        },
                        "intentions": intent_schema
                    },
                    "additionalProperties": false
                });
                format_schema_for_prompt(&simple_schema)
            })
            .unwrap_or_else(|| format_schema_for_prompt(schema));
        EXTRACT_INTENT_PROMPT_BASE.replace("{format_instructions}", &fmt)
    } else {
        EXTRACT_INTENT_PROMPT_BASE.replace(
            "{format_instructions}",
            r#"输出 JSON：
{
  "activity": "活动概括（15字）",
  "intentions": [
    {"type": "plan/commitment", "content": "意图原文"}
  ]
}"#,
        )
    };

    let llm = get_llm()?;
    let mut ready: Vec<(String, String)> = Vec::new();
    let entries_iter: Vec<&Value> = match limit {
        Some(n) => entries.iter().take(n).collect(),
        None => entries.iter().collect(),
    };

    for (idx, entry) in entries_iter.iter().enumerate() {
        let text = entry["text"].as_str().unwrap_or("");
        eprint!(
            "\r  处理中: {}/{} ({}%)",
            idx + 1,
            total,
            (idx + 1) * 100 / total.max(1)
        );
        let _ = std::io::stderr().flush();

        let extract_result = call_llm(&prompt, text, &llm, 1024)?;
        let activity = match extract_result.get("activity").and_then(|v| v.as_str()) {
            Some(s) => s.to_string(),
            None => text.chars().take(200).collect(),
        };

        if let Some(intentions) = extract_result["intentions"].as_array() {
            for intent in intentions {
                let content = intent["content"]
                    .as_str()
                    .unwrap_or("")
                    .trim()
                    .to_string();
                if content.is_empty() {
                    continue;
                }
                let judge_prompt = JUDGE_PROMPT
                    .replace("{situation}", &activity)
                    .replace("{intent}", &content);
                let result = call_llm(&judge_prompt, &format!("意图：{}", content), &llm, 256)?;
                if result.get("verdict").and_then(|v| v.as_str()) == Some("可执行") {
                    let first_step = result
                        .get("first_step")
                        .and_then(|v| v.as_str())
                        .unwrap_or("");
                    ready.push((content, first_step.to_string()));
                }
            }
        }
    }

    let todo_path = output.join("TODO.md");
    let date_str = Local::now().format("%Y-%m-%d").to_string();

    let mut existing_items: BTreeSet<String> = BTreeSet::new();
    if todo_path.exists() {
        let content = fs::read_to_string(&todo_path).unwrap_or_default();
        for line in content.lines() {
            let line = line.trim();
            if line.starts_with("- [x] ") || line.starts_with("- [ ] ") {
                existing_items.insert(line[6..].trim().to_string());
            }
        }
    }

    let new_items: Vec<&(String, String)> = ready
        .iter()
        .filter(|(t, _)| !existing_items.contains(t.as_str()))
        .collect();
    let new_count = new_items.len();

    if !new_items.is_empty() {
        let mut file = if todo_path.exists() {
            fs::OpenOptions::new().append(true).open(&todo_path)?
        } else {
            fs::File::create(&todo_path)?
        };

        if !todo_path.exists() || fs::read_to_string(&todo_path).unwrap_or_default().trim().is_empty() {
            writeln!(file, "# TODO\n")?;
        }
        writeln!(file, "## {}\n", date_str)?;
        for (text, step) in &new_items {
            writeln!(file, "- [ ] {}", text)?;
            if !step.is_empty() {
                writeln!(file, "  第一步：{}", step)?;
            }
        }
        writeln!(file)?;
    }

    println!("\n可执行: {}", ready.len());
    for (text, step) in &ready {
        println!("  [ ] {}  → {}", text, step);
    }
    println!("\n已更新: {:?}", todo_path);
    println!("  新增: {} 条", new_count);

    Ok(())
}

// ── motif: 小说 → motifs.yaml / styles.yaml ──

const MOTIF_PROMPT_BASE: &str = r#"你是一个叙事分析助手。从小说片段中识别母题 (Motif)。

{format_instructions}

规则：
- 每个片段识别 1-5 个母题
- 母题要有实质内容，不泛泛而谈
- 输出纯 JSON 数组，不要 markdown"#;

const STYLE_PROMPT_BASE: &str = r#"你是一个文体分析助手。分析以下小说片段的风格特征。

{format_instructions}

规则：
- 基于原文实际统计，不编造数字
- 输出纯 JSON，不要 markdown"#;

fn extract_motif(
    data: &Value,
    output: &Path,
    model_schema: Option<&Value>,
    limit: Option<usize>,
) -> Result<()> {
    let entries = data["entries"]
        .as_array()
        .context("输入数据缺少 'entries' 字段")?;

    let (motif_fmt, style_fmt): (String, String) = if let Some(schema) = model_schema {
        let motif_schema = serde_json::json!({"type": "array", "items": schema});
        (format_schema_for_prompt(&motif_schema), "无需格式约束".to_string())
    } else {
        (
            r#"输出 JSON 数组，每个元素：
{
  "motif_name": "母题名",
  "motif_type": "theme|image|plot|character",
  "motif_subtype": "子类型标签",
  "description": "简述",
  "excerpt": "最能体现该母题的原文片段（50字以内")
}"#
            .to_string(),
            r#"输出 JSON 对象：
{
  "style_name": "风格名称",
  "tags": ["风格标签数组"],
  "features": {
    "avg_sentence_length": 平均句长（字符数，浮点数）,
    "dialogue_ratio": 对话占比（0-1，浮点数）,
    "lexical_diversity": 词汇多样性（估算，0-1）,
    "rhetorical_density": 修辞密度（估算，0-1）
  }
}"#
            .to_string(),
        )
    };

    let motif_prompt = MOTIF_PROMPT_BASE.replace("{format_instructions}", &motif_fmt);
    let style_prompt = STYLE_PROMPT_BASE.replace("{format_instructions}", &style_fmt);

    let llm = get_llm()?;
    let mut all_motifs: Vec<Value> = Vec::new();
    let mut all_styles: Vec<Value> = Vec::new();
    let mut seq: u32 = 0;

    let entries_iter: Vec<&Value> = match limit {
        Some(n) => entries.iter().take(n).collect(),
        None => entries.iter().collect(),
    };

    for entry in &entries_iter {
        let text = entry["text"].as_str().unwrap_or("");
        let source = entry.get("source").and_then(|v| v.as_str()).unwrap_or("");

        let paragraphs: Vec<&str> = text
            .split("\n\n")
            .map(|s| s.trim())
            .filter(|s| !s.is_empty() && !s.starts_with("# "))
            .collect();

        let mut chunks: Vec<String> = Vec::new();
        let mut current: Vec<&str> = Vec::new();
        let mut current_len = 0;

        for p in &paragraphs {
            if current_len + p.len() > 3000 && !current.is_empty() {
                chunks.push(current.join("\n\n"));
                current.clear();
                current_len = 0;
            }
            current.push(p);
            current_len += p.len();
        }
        if !current.is_empty() {
            chunks.push(current.join("\n\n"));
        }
        if chunks.is_empty() {
            chunks.push(text.to_string());
        }

        let mut file_motifs: Vec<Value> = Vec::new();
        let mut file_style: Option<Value> = None;

        for (ci, chunk) in chunks.iter().enumerate() {
            let motif_data = call_llm(&motif_prompt, chunk, &llm, 4096)?;
            let motifs: Vec<Value> = if let Some(arr) = motif_data.as_array() {
                arr.clone()
            } else if let Some(obj) = motif_data.as_object() {
                let mut result = Vec::new();
                for key in &["motifs", "results", "items"] {
                    if let Some(arr) = obj.get(*key).and_then(|v| v.as_array()) {
                        result = arr.clone();
                        break;
                    }
                }
                result
            } else {
                Vec::new()
            };

            for mut m in motifs {
                seq += 1;
                if let Some(obj) = m.as_object_mut() {
                    obj.insert("id".into(), Value::String(format!("m-{:03}", seq)));
                    obj.insert("source".into(), Value::String(source.into()));
                    obj.insert("chunk".into(), Value::from(ci as u64 + 1));
                }
                file_motifs.push(m);
            }
            println!("  {} 块 {}: {} 个母题", source, ci + 1, file_motifs.len());

            if file_style.is_none() {
                let style = call_llm(&style_prompt, chunk, &llm, 4096).ok();
                if let Some(mut s) = style {
                    if s.get("style_name").is_none() {
                        if let Some(name_val) = s.get("name").cloned() {
                            if let Some(obj) = s.as_object_mut() {
                                obj.insert("style_name".into(), name_val);
                                obj.remove("name");
                            }
                        }
                    }
                    seq += 1;
                    if let Some(obj) = s.as_object_mut() {
                        obj.insert("id".into(), Value::String(format!("st-{:03}", seq)));
                        obj.insert("source".into(), Value::String(source.into()));
                    }
                    let style_name = s
                        .get("style_name")
                        .and_then(|v| v.as_str())
                        .unwrap_or("?");
                    println!("    风格: {}", style_name);
                    file_style = Some(s);
                }
            }
        }

        all_motifs.extend(file_motifs);
        if let Some(s) = file_style {
            all_styles.push(s);
        }
    }

    if !all_motifs.is_empty() {
        let out = output.join("motifs.yaml");
        write_yaml(&serde_json::json!({"motifs": all_motifs}), &out)?;
        println!("母题结果: {:?} ({} 条)", out, all_motifs.len());
    }

    if !all_styles.is_empty() {
        let out = output.join("styles.yaml");
        write_yaml(&serde_json::json!({"styles": all_styles}), &out)?;
        println!("风格结果: {:?} ({} 条)", out, all_styles.len());
    }

    Ok(())
}

// ── annotate: cognition → ANNOTATION.md ──

fn extract_annotate(
    data: &Value,
    output: &Path,
    _model_schema: Option<&Value>,
    _limit: Option<usize>,
) -> Result<()> {
    let entries = data["entries"]
        .as_array()
        .context("输入数据缺少 'entries' 字段")?;

    let mut all_intents: Vec<String> = Vec::new();
    let mut all_ideas: Vec<String> = Vec::new();

    for entry in entries {
        if let Some(intentions) = entry.get("intentions").and_then(|v| v.as_array()) {
            for item in intentions {
                let content = item["content"].as_str().unwrap_or("").trim().to_string();
                if !content.is_empty() {
                    all_intents.push(content);
                }
            }
        }
        if let Some(ideas) = entry.get("ideas").and_then(|v| v.as_array()) {
            for item in ideas {
                let content = item["content"].as_str().unwrap_or("").trim().to_string();
                if !content.is_empty() {
                    all_ideas.push(content);
                }
            }
        }
    }

    // 去重，保持顺序
    let mut seen = HashSet::new();
    let intents: Vec<&String> = all_intents.iter().filter(|s| seen.insert(s.to_string())).collect();
    seen.clear();
    let ideas: Vec<&String> = all_ideas.iter().filter(|s| seen.insert(s.to_string())).collect();

    let date_str = Local::now().format("%Y-%m-%d").to_string();
    let mut lines = vec![format!("# 标注确认 — {}\n", date_str)];
    lines.push(
        "标记说明：`[ ]`待确认 `[x]`已采纳 `[-]`已废弃 `[?]`待决策 `[~]`已修改\n\n".into(),
    );

    if !intents.is_empty() {
        lines.push("## 意图 [ ]\n\n".into());
        for item in &intents {
            lines.push(format!("- [ ] {}\n", item));
        }
        lines.push("\n".into());
    }

    if !ideas.is_empty() {
        lines.push("## 想法 [ ]\n\n".into());
        for item in &ideas {
            lines.push(format!("- [ ] {}\n", item));
        }
        lines.push("\n".into());
    }

    let anno_path = output.join("ANNOTATION.md");
    write_markdown(&lines.concat(), &anno_path)?;
    println!("已生成: {:?}", anno_path);
    println!("  意图: {} 条", intents.len());
    println!("  想法: {} 条", ideas.len());

    Ok(())
}

// ── worldbuilding: fiction → worldbuilding.yaml ──

const WORLDBUILDING_PROMPT_BASE: &str = r#"你是一个叙事世界观分析助手。从以下小说片段中提取结构化世界观要素。

{format_instructions}

规则：
- 所有要素必须基于原文推断，不编造不补充
- characters 识别角色的身份、性格特征、动机与弧光
- relationship 分析角色之间的动态关系与张力
- setting 提取场景空间及其氛围和叙事意义
- emotional_geography 识别情感在空间中的投射和记忆绑定
- timeline 梳理叙事的过去、现在与未来线索
- themes 提炼作品的核心意涵与情感母题
- tensions 识别推动叙事的情感矛盾

- 如果某类不存在，输出空数组
- 纯 JSON。"#;

fn extract_worldbuilding(
    data: &Value,
    output: &Path,
    model_schema: Option<&Value>,
    limit: Option<usize>,
) -> Result<()> {
    let entries = data["entries"]
        .as_array()
        .context("输入数据缺少 'entries' 字段")?;

    let prompt = if let Some(schema) = model_schema {
        let fmt = format_schema_for_prompt(schema);
        WORLDBUILDING_PROMPT_BASE.replace("{format_instructions}", &fmt)
    } else {
        return Err(anyhow::anyhow!("worldbuilding 类型需要 --model 参数"));
    };

    let llm = get_llm()?;
    let mut all_results: Vec<Value> = Vec::new();

    let entries_iter: Vec<&Value> = match limit {
        Some(n) => entries.iter().take(n).collect(),
        None => entries.iter().collect(),
    };

    for entry in &entries_iter {
        let text = entry["text"].as_str().unwrap_or("");
        let source = entry.get("source").and_then(|v| v.as_str()).unwrap_or("");

        let mut result = call_llm(&prompt, text, &llm, 4096)?;
        if let Some(obj) = result.as_object_mut() {
            obj.insert("_source".into(), Value::String(source.into()));
        }
        all_results.push(result);
    }

    let out_file = output.join("worldbuilding.yaml");
    write_yaml(&serde_json::json!({"worldbuilding": all_results}), &out_file)?;
    println!("世界观结果: {:?} ({} 条)", out_file, all_results.len());

    Ok(())
}

// ── scene-graph: 多场景 → 场景关联图 ──

const SCENE_GRAPH_PROMPT_BASE: &str = r#"你是一个叙事结构分析助手。从以下小说片段中，分析场景之间的引用关系和叙事结构。

{format_instructions}

规则：
- 仔细阅读所有场景，识别场景之间的引用、回调、前传依赖
- forward_references 识别当前场景提到的更早发生的事——包括前文场景中的事件和文本未覆盖的过往（backstory/off_screen）
- timeline_relationship 标注场景之间的时间先后和间隔
- emotional_echoes 识别同一地点或物品在不同场景中承载的不同情感
- 所有要素必须基于原文推断，不编造
- excerpt / excerpt_past / excerpt_present 字段必须从原文逐字引用，不能概括或改写
- 如果某类不存在，输出空数组
- 纯 JSON。"#;

fn extract_scene_graph(
    data: &Value,
    output: &Path,
    model_schema: Option<&Value>,
    limit: Option<usize>,
) -> Result<()> {
    let entries = data["entries"]
        .as_array()
        .context("输入数据缺少 'entries' 字段")?;

    let prompt = if let Some(schema) = model_schema {
        let fmt = format_schema_for_prompt(schema);
        SCENE_GRAPH_PROMPT_BASE.replace("{format_instructions}", &fmt)
    } else {
        return Err(anyhow::anyhow!("scene-graph 类型需要 --model 参数"));
    };

    let llm = get_llm()?;

    // 把所有场景拼接成一段文本送给 LLM，让它看到全部场景之间的关系
    let mut combined = String::new();
    let entries_iter: Vec<&Value> = match limit {
        Some(n) => entries.iter().take(n).collect(),
        None => entries.iter().collect(),
    };
    for entry in &entries_iter {
        let sid = entry["id"].as_str().unwrap_or("?");
        let source = entry.get("source").and_then(|v| v.as_str()).unwrap_or("");
        let text = entry["text"].as_str().unwrap_or("");
        combined.push_str(&format!("\n=== 场景 {} ({}) ===\n{}\n", sid, source, text));
    }

    let mut result = call_llm(&prompt, &combined, &llm, 4096)?;
    if let Some(obj) = result.as_object_mut() {
        let sources: Vec<String> = entries_iter
            .iter()
            .filter_map(|e| e.get("source").and_then(|v| v.as_str()).map(|s| s.to_string()))
            .collect();
        obj.insert("_sources".into(), Value::Array(sources.into_iter().map(Value::String).collect()));
    }

    let out_file = output.join("scene-graph.yaml");
    write_yaml(&serde_json::json!({"scene_graph": result}), &out_file)?;
    println!("场景关联图: {:?}", out_file);

    Ok(())
}

// ── 分发 ──

fn extract_by_type(
    data: &Value,
    output: &Path,
    extract_type: &str,
    model_schema: Option<&Value>,
    limit: Option<usize>,
) -> Result<()> {
    match extract_type {
        "cognition" => extract_cognition(data, output, model_schema, limit),
        "todo" => extract_todo(data, output, model_schema, limit),
        "motif" => extract_motif(data, output, model_schema, limit),
        "annotate" => extract_annotate(data, output, model_schema, limit),
        "worldbuilding" => extract_worldbuilding(data, output, model_schema, limit),
        "scene-graph" => extract_scene_graph(data, output, model_schema, limit),
        _ => anyhow::bail!(
            "错误: 未知抽取类型 '{}'，可用: cognition, todo, motif, annotate, worldbuilding, scene-graph",
            extract_type
        ),
    }
}

pub fn run(args: &ExtractArgs) -> Result<()> {
    let output = PathBuf::from(&args.output);
    fs::create_dir_all(&output)?;

    let raw = read_yaml(Path::new(&args.input))?;
    let data = raw.get("data").unwrap_or(&raw).clone();
    let data = if data.is_object() {
        let mut entries_val: Option<Value> = None;
        if let Some(obj) = data.as_object() {
            for v in obj.values() {
                if let Some(arr) = v.as_array() {
                    if arr.first().and_then(|e| e.as_object()).is_some() {
                        entries_val = Some(serde_json::json!({"entries": arr}));
                        break;
                    }
                }
            }
        }
        entries_val.unwrap_or(data)
    } else {
        data
    };

    let model_schema = if let Some(model_path) = &args.model {
        let model_raw = read_yaml(Path::new(model_path))?;
        let top_keys = ["cognition", "motif", "style", "situation", "worldbuilding", "scene_graph"];
        let model_key = top_keys
            .iter()
            .find(|k| model_raw.get(*k).is_some())
            .map(|s| s.to_string())
            .or_else(|| {
                model_raw
                    .as_object()
                    .and_then(|obj| obj.keys().find(|k| *k != "description" && *k != "example").cloned())
            });

        match model_key {
            Some(key) => {
                let schema = compile_schema(&model_raw, &key)?;
                println!("模型: {} (key: {})", model_path, key);
                Some(schema)
            }
            None => {
                eprintln!("警告: 未能从模型文件中提取顶层 key");
                None
            }
        }
    } else {
        None
    };

    extract_by_type(&data, &output, &args.extract_type, model_schema.as_ref(), args.limit)
}


