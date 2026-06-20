use std::collections::HashMap;
use std::path::PathBuf;
use std::time::{Duration, Instant};

use anyhow::Result;
use clap::Args;
use regex::Regex;
use serde::{Deserialize, Serialize};
use walkdir::WalkDir;

/// 评估资产内容质量（叙事/知识/认知三维度）
#[derive(Args)]
pub struct QualityArgs {
    /// 手册目录路径
    #[arg(long, default_value = "docs/handbook")]
    pub handbook_dir: String,

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

// ── 数据结构 ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ScoreResult {
    score: u32,
    reason: String,
    evidence: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct FileResult {
    file: String,
    error: Option<String>,
    lines: usize,
    chars: usize,
    dimension_scores: HashMap<String, f64>,
    overall_score: f64,
    metrics: HashMap<String, ScoreResult>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Stats {
    total_files: usize,
    files_evaluated: usize,
    files_with_error: usize,
    overall_average: f64,
    dimension_averages: HashMap<String, f64>,
    health_distribution: HashMap<String, usize>,
    best_file: Option<String>,
    best_score: Option<f64>,
    worst_file: Option<String>,
    worst_score: Option<f64>,
    metric_averages: HashMap<String, f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Output {
    files: Vec<FileResult>,
    stats: Stats,
}

// ── 评估指标定义 ──────────────────────────────────────────────────────────

const METRICS: &[(&str, &str, &str, &str)] = &[
    ("narrative_clarity", "narrative", "叙事·清晰易懂",
     "评估此手册的语言表达是否清晰易懂：句子是否简短通顺？术语是否有解释？逻辑是否连贯？读者能否轻松跟上思路而不感到困惑？"),
    ("knowledge_extractable_branch", "knowledge", "可编程·条件分支",
     "评估此手册中包含的可编程条件逻辑的清晰度：规则是否明确定义了'如果X则Y'的条件分支？条件判断的依据是否可量化或可枚举？"),
    ("knowledge_extractable_rule", "knowledge", "可编程·规则参数",
     "评估此手册中的规则参数是否清晰可提取：金额、比例、期限、阈值等数值型参数是否明确给出或指向明确的数据源？"),
    ("knowledge_extractable_flow", "knowledge", "可编程·流程状态机",
     "评估此手册中的流程是否可建模为状态机：是否有明确的起始状态、中间态/步骤、终止状态？步骤之间的转移条件是否清晰？"),
    ("knowledge_extractable_role", "knowledge", "可编程·角色权限",
     "评估此手册中的角色和权限定义是否可编程：谁可以做什么、谁不能做什么、谁审批什么——这些是否明确到可以直接映射为代码中的角色权限模型？"),
    ("knowledge_extractable_validation", "knowledge", "可编程·校验规则",
     "评估此手册中定义的约束和校验规则是否可编程：'不得''必须''禁止'等约束是否清晰定义了校验条件？"),
    ("cognitive_mental_model", "cognitive", "心智·三段论完整性",
     "评估此手册是否帮助读者建立了完整的工作心智模型。一个完整的工作手册应当包含三个部分：（1）意图——为什么做、在什么场景下触发、谁来做、目标是什么；（2）流程——怎么做、先做什么再做什么、步骤之间的转移条件；（3）验收——怎么知道做完了、做对了、交付标准和检查条件是什么。请整体判断：这篇手册的意图→流程→验收三段论完整吗？"),
];

// ── LLM 调用 ──────────────────────────────────────────────────────────────

#[derive(Serialize)]
struct ChatMessage {
    role: String,
    content: String,
}

#[derive(Serialize)]
struct ChatRequest {
    model: String,
    messages: Vec<ChatMessage>,
    temperature: f64,
    max_tokens: u32,
    response_format: ResponseFormat,
}

#[derive(Serialize)]
struct ResponseFormat {
    #[serde(rename = "type")]
    type_: String,
}

#[derive(Deserialize)]
struct ChatResponse {
    choices: Vec<Choice>,
}

#[derive(Deserialize)]
struct Choice {
    message: ChoiceMessage,
}

#[derive(Deserialize)]
struct ChoiceMessage {
    content: String,
}

fn call_llm(prompt: &str, api_key: &str) -> Result<String> {
    let client = reqwest::blocking::Client::new();
    let request = ChatRequest {
        model: "deepseek-chat".into(),
        messages: vec![
            ChatMessage {
                role: "system".into(),
                content: "你是一位严格的文档质量评估师。请严格按照评分标准打分，输出纯 JSON。"
                    .into(),
            },
            ChatMessage {
                role: "user".into(),
                content: prompt.into(),
            },
        ],
        temperature: 0.1,
        max_tokens: 300,
        response_format: ResponseFormat {
            type_: "json_object".into(),
        },
    };

    let mut last_err = None;
    for attempt in 0..3 {
        let backoff = Duration::from_secs(2u64.pow(attempt));
        match client
            .post("https://api.deepseek.com/v1/chat/completions")
            .header("Authorization", format!("Bearer {}", api_key))
            .json(&request)
            .send()
        {
            Ok(resp) => {
                if let Ok(chat_resp) = resp.json::<ChatResponse>() {
                    if let Some(choice) = chat_resp.choices.first() {
                        return Ok(choice.message.content.clone());
                    }
                }
            }
            Err(e) => {
                last_err = Some(e);
                std::thread::sleep(backoff);
            }
        }
    }
    Err(anyhow::anyhow!("API 调用失败: {:?}", last_err))
}

fn parse_score_response(text: &str) -> ScoreResult {
    // 尝试直接解析 JSON
    if let Ok(mut result) = serde_json::from_str::<HashMap<String, serde_json::Value>>(text) {
        let score = result
            .remove("score")
            .and_then(|v| v.as_u64())
            .unwrap_or(0)
            .min(5) as u32;
        let reason = result
            .remove("reason")
            .and_then(|v| v.as_str().map(String::from))
            .unwrap_or_default();
        let evidence = result
            .remove("evidence")
            .and_then(|v| v.as_str().map(String::from))
            .unwrap_or_default();
        return ScoreResult {
            score,
            reason,
            evidence,
        };
    }

    // 尝试从文本中提取 JSON 块
    let re = Regex::new(r"\{[^{}]*\}").unwrap();
    if let Some(m) = re.find(text) {
        if let Ok(mut result) =
            serde_json::from_str::<HashMap<String, serde_json::Value>>(m.as_str())
        {
            let score = result
                .remove("score")
                .and_then(|v| v.as_u64())
                .unwrap_or(0)
                .min(5) as u32;
            let reason = result
                .remove("reason")
                .and_then(|v| v.as_str().map(String::from))
                .unwrap_or_default();
            let evidence = result
                .remove("evidence")
                .and_then(|v| v.as_str().map(String::from))
                .unwrap_or_default();
            return ScoreResult {
                score,
                reason,
                evidence,
            };
        }
    }

    ScoreResult {
        score: 0,
        reason: format!("JSON 解析失败: {}", &text[..text.len().min(200)]),
        evidence: String::new(),
    }
}

// ── 文件扫描 ──────────────────────────────────────────────────────────────

fn scan_handbook_files(handbook_dir: &PathBuf, quick: bool) -> Vec<PathBuf> {
    let exclude: [&str; 6] = [
        "AGENTS.md",
        "CONTRIBUTING.md",
        "CHANGELOG.md",
        "README.md",
        "ROADMAP.md",
        "LICENSE",
    ];

    let mut files: Vec<PathBuf> = WalkDir::new(handbook_dir)
        .into_iter()
        .filter_entry(|e| {
            !e.file_name()
                .to_str()
                .map(|s| s.starts_with('.'))
                .unwrap_or(false)
        })
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().is_file())
        .map(|e| e.path().to_path_buf())
        .filter(|p| p.extension().map(|e| e == "md").unwrap_or(false))
        .filter(|p| {
            !exclude
                .iter()
                .any(|x| p.file_name().and_then(|n| n.to_str()) == Some(x))
        })
        .collect();
    files.sort();

    if quick {
        files.retain(|p| p.file_name().and_then(|n| n.to_str()) == Some("index.md"));
    }

    files
}

// ── 统计计算 ──────────────────────────────────────────────────────────────

fn compute_stats(files: &[FileResult]) -> Stats {
    let total_files = files.len();
    let files_with_error = files.iter().filter(|f| f.error.is_some()).count();
    let files_evaluated = total_files - files_with_error;
    let valid: Vec<&FileResult> = files.iter().filter(|f| f.error.is_none()).collect();

    let overall_avg = if !valid.is_empty() {
        let sum: f64 = valid.iter().map(|f| f.overall_score).sum();
        (sum / valid.len() as f64 * 100.0).round() / 100.0
    } else {
        0.0
    };

    let mut dim_avgs = HashMap::new();
    for dim in &["narrative", "knowledge", "cognitive"] {
        let sum: f64 = valid
            .iter()
            .map(|f| *f.dimension_scores.get(*dim).unwrap_or(&0.0))
            .sum();
        let avg = if !valid.is_empty() {
            (sum / valid.len() as f64 * 100.0).round() / 100.0
        } else {
            0.0
        };
        dim_avgs.insert(dim.to_string(), avg);
    }

    let mut health = HashMap::new();
    health.insert(
        "healthy".into(),
        valid.iter().filter(|f| f.overall_score >= 4.0).count(),
    );
    health.insert(
        "moderate".into(),
        valid
            .iter()
            .filter(|f| (2.5..4.0).contains(&f.overall_score))
            .count(),
    );
    health.insert(
        "unhealthy".into(),
        valid.iter().filter(|f| f.overall_score < 2.5).count(),
    );

    let best = valid
        .iter()
        .max_by(|a, b| a.overall_score.partial_cmp(&b.overall_score).unwrap());
    let worst = valid
        .iter()
        .min_by(|a, b| a.overall_score.partial_cmp(&b.overall_score).unwrap());

    let mut metric_avgs = HashMap::new();
    for (key, _, _, _) in METRICS {
        let scores: Vec<u32> = valid
            .iter()
            .filter_map(|f| f.metrics.get(*key))
            .map(|m| m.score)
            .collect();
        let avg = if !scores.is_empty() {
            (scores.iter().sum::<u32>() as f64 / scores.len() as f64 * 100.0).round() / 100.0
        } else {
            0.0
        };
        metric_avgs.insert(key.to_string(), avg);
    }

    Stats {
        total_files,
        files_evaluated,
        files_with_error,
        overall_average: overall_avg,
        dimension_averages: dim_avgs,
        health_distribution: health,
        best_file: best.map(|f| f.file.clone()),
        best_score: best.map(|f| f.overall_score),
        worst_file: worst.map(|f| f.file.clone()),
        worst_score: worst.map(|f| f.overall_score),
        metric_averages: metric_avgs,
    }
}

// ── 报告生成 ──────────────────────────────────────────────────────────────

fn generate_report(output: &Output) -> String {
    let stats = &output.stats;
    let mut lines = Vec::new();

    lines.push("# p40 手册质量多维度评估 —— LLM 评估报告\n".into());
    lines.push(format!(
        "> 评估文件数：{} / {}",
        stats.files_evaluated, stats.total_files
    ));
    lines.push(String::new());

    lines.push("## 一、总体健康度\n".into());
    lines.push("| 指标 | 值 |".into());
    lines.push("|------|-----|".into());
    lines.push(format!("| 总体平均分 | {} / 5 |", stats.overall_average));
    lines.push(format!(
        "| 叙事工程 | {} / 5 |",
        stats.dimension_averages.get("narrative").unwrap_or(&0.0)
    ));
    lines.push(format!(
        "| 知识工程 | {} / 5 |",
        stats.dimension_averages.get("knowledge").unwrap_or(&0.0)
    ));
    lines.push(format!(
        "| 认知工程 | {} / 5 |",
        stats.dimension_averages.get("cognitive").unwrap_or(&0.0)
    ));
    lines.push(String::new());
    lines.push(format!(
        "| 🟢 健康 (≥4.0) | {} 个 |",
        stats.health_distribution.get("healthy").unwrap_or(&0)
    ));
    lines.push(format!(
        "| 🟡 亚健康 (2.5-3.9) | {} 个 |",
        stats.health_distribution.get("moderate").unwrap_or(&0)
    ));
    lines.push(format!(
        "| 🔴 不健康 (<2.5) | {} 个 |",
        stats.health_distribution.get("unhealthy").unwrap_or(&0)
    ));
    lines.push(String::new());
    if let (Some(best), Some(score)) = (&stats.best_file, stats.best_score) {
        lines.push(format!("| 🏆 最佳手册 | {} ({}) |", best, score));
    }
    if let (Some(worst), Some(score)) = (&stats.worst_file, stats.worst_score) {
        lines.push(format!("| 😱 最差手册 | {} ({}) |", worst, score));
    }
    lines.push(String::new());

    lines.push("## 二、维度深度分析\n".into());
    for (dim_key, dim_label) in [
        ("narrative", "叙事工程"),
        ("knowledge", "知识工程"),
        ("cognitive", "认知工程"),
    ] {
        lines.push(format!("### {}\n", dim_label));
        lines.push(format!(
            "维度平均分：**{}** / 5\n",
            stats.dimension_averages.get(dim_key).unwrap_or(&0.0)
        ));
        lines.push("| 指标 | 平均分 |".into());
        lines.push("|------|-------|".into());

        let mut dim_metrics: Vec<(&String, &f64)> = stats
            .metric_averages
            .iter()
            .filter(|(k, _)| k.starts_with(dim_key))
            .collect();
        dim_metrics.sort_by(|a, b| a.1.partial_cmp(b.1).unwrap());

        for (mk, avg) in &dim_metrics {
            let label = METRICS
                .iter()
                .find(|m| m.0 == mk.as_str())
                .map(|m| m.2)
                .unwrap_or(mk);
            let icon = if **avg >= 4.0 {
                "🟢"
            } else if **avg >= 2.5 {
                "🟡"
            } else {
                "🔴"
            };
            lines.push(format!("| {} {} | {} |", icon, label, avg));
        }
        lines.push(String::new());
    }

    lines.push("## 三、按文件评分详情\n".into());
    lines.push("| 文件 | 总分 | 叙事 | 知识 | 认知 | 行数 |".into());
    lines.push("|------|------|------|------|------|------|".into());

    let mut sorted_files = output.files.clone();
    sorted_files.sort_by(|a, b| b.overall_score.partial_cmp(&a.overall_score).unwrap());
    for f in &sorted_files {
        if let Some(ref err) = f.error {
            lines.push(format!("| {} | ❌ {} | - | - | - | - |", f.file, err));
        } else {
            lines.push(format!(
                "| {} | {} | {} | {} | {} | {} |",
                f.file,
                f.overall_score,
                f.dimension_scores.get("narrative").unwrap_or(&0.0),
                f.dimension_scores.get("knowledge").unwrap_or(&0.0),
                f.dimension_scores.get("cognitive").unwrap_or(&0.0),
                f.lines,
            ));
        }
    }
    lines.push(String::new());

    lines.join("\n")
}

// ── 主入口 ──────────────────────────────────────────────────────────────

pub fn run(args: &QualityArgs) -> Result<()> {
    let api_key = std::env::var("DEEPSEEK_API_KEY")
        .map_err(|_| anyhow::anyhow!("DEEPSEEK_API_KEY 环境变量未设置"))?;

    let handbook_dir = PathBuf::from(&args.handbook_dir);
    if !handbook_dir.exists() {
        anyhow::bail!("手册目录不存在: {}", handbook_dir.display());
    }

    println!("📂 手册目录: {}", handbook_dir.display());
    println!("🤖 模型: deepseek-chat\n");

    let all_files = scan_handbook_files(&handbook_dir, args.quick);
    let total = all_files.len();
    println!(
        "{} 模式：共 {} 个文件待评估\n",
        if args.quick {
            "⚡ 快速"
        } else {
            "📋 完整"
        },
        total
    );

    // 加载已有结果
    let mut results: Vec<FileResult> = if args.resume {
        let path = std::path::Path::new(&args.output);
        if path.exists() {
            let content = std::fs::read_to_string(path)?;
            let existing: Output = serde_json::from_str(&content)?;
            println!("♻️ 断点续评：跳过 {} 个已评估文件", existing.files.len());
            existing.files
        } else {
            Vec::new()
        }
    } else {
        Vec::new()
    };

    let evaluated: std::collections::HashSet<String> =
        results.iter().map(|f| f.file.clone()).collect();

    let start = Instant::now();
    for (i, filepath) in all_files.iter().enumerate() {
        let relpath = filepath
            .strip_prefix(&handbook_dir)
            .unwrap_or(filepath)
            .to_string_lossy()
            .to_string();

        if evaluated.contains(&relpath) {
            continue;
        }

        print!("  [{}/{}] {} ... ", i + 1, total, relpath);
        std::io::Write::flush(&mut std::io::stdout())?;

        let content = match std::fs::read_to_string(filepath) {
            Ok(c) => c,
            Err(e) => {
                println!("❌ {}", e);
                results.push(FileResult {
                    file: relpath,
                    error: Some(e.to_string()),
                    lines: 0,
                    chars: 0,
                    dimension_scores: HashMap::new(),
                    overall_score: 0.0,
                    metrics: HashMap::new(),
                });
                continue;
            }
        };

        let lines = content.lines().count();
        let chars = content.len();

        if chars < 20 {
            let mut metrics = HashMap::new();
            for (key, _, _, _) in METRICS {
                metrics.insert(
                    key.to_string(),
                    ScoreResult {
                        score: 1,
                        reason: "文件过短（<20字符），无法评估".into(),
                        evidence: String::new(),
                    },
                );
            }
            results.push(FileResult {
                file: relpath,
                error: None,
                lines,
                chars,
                dimension_scores: HashMap::new(),
                overall_score: 1.0,
                metrics,
            });
            println!("⬜ 文件过短");
            continue;
        }

        let truncated: &str = if chars > 8000 {
            &content[..8000]
        } else {
            &content
        };

        let mut file_metrics = HashMap::new();
        let mut dim_scores: HashMap<String, Vec<u32>> = HashMap::new();

        for (key, dimension, _label, prompt_template) in METRICS {
            let full_prompt = format!(
                "你是一位专业的文档质量评估师。请对以下工作手册文件进行单一维度的评估。\n\n\
                 ## 评估指标\n\
                 {}\n\n\
                 ## 评分标准\n\
                 - 5分：优秀 —— 完全满足该指标要求，可作范本\n\
                 - 4分：良好 —— 基本满足，有少量改进空间\n\
                 - 3分：及格 —— 部分满足，存在明显不足\n\
                 - 2分：较差 —— 很少满足，大部分缺失\n\
                 - 1分：很差 —— 完全不满足或文件内容几乎不存在\n\n\
                 你必须只输出 JSON 格式，不要输出其他内容：\n\
                 {{\n  \"score\": <整数1-5>,\n  \"reason\": \"<一句话解释打分的理由>\",\n  \"evidence\": \"<从手册原文中摘录的一两句最有说服力的证据>\"\n}}\n\n\
                 ## 手册内容\n\
                 文件路径：{}\n\
                 文件大小：{} 行 / {} 字符\n\n\
                 ```\n{}\n```",
                prompt_template, relpath, lines, chars, truncated
            );

            let raw = call_llm(&full_prompt, &api_key).unwrap_or_else(|_| {
                r#"{"score": 0, "reason": "API 调用失败", "evidence": ""}"#.into()
            });
            let result = parse_score_response(&raw);
            let metric_score = result.score;
            file_metrics.insert(key.to_string(), result);

            dim_scores
                .entry(dimension.to_string())
                .or_default()
                .push(metric_score);
        }

        let mut dimension_scores = HashMap::new();
        for (dim, scores) in &dim_scores {
            let avg = if !scores.is_empty() {
                (scores.iter().sum::<u32>() as f64 / scores.len() as f64 * 100.0).round() / 100.0
            } else {
                0.0
            };
            dimension_scores.insert(dim.clone(), avg);
        }

        let overall = if !dimension_scores.is_empty() {
            let sum: f64 = dimension_scores.values().sum();
            (sum / dimension_scores.len() as f64 * 100.0).round() / 100.0
        } else {
            0.0
        };

        println!("✅ 总分={}", overall);

        results.push(FileResult {
            file: relpath,
            error: None,
            lines,
            chars,
            overall_score: overall,
            dimension_scores,
            metrics: file_metrics,
        });

        // 中间保存
        let stats = compute_stats(&results);
        let output = Output {
            files: results.clone(),
            stats,
        };
        save_output(&output, &args.output)?;
    }

    let elapsed = start.elapsed();
    println!("\n⏱ 总耗时: {:.1}秒", elapsed.as_secs_f64());

    let stats = compute_stats(&results);
    let output = Output {
        files: results,
        stats,
    };

    save_output(&output, &args.output)?;
    println!("💾 JSON 结果已保存: {}", args.output);

    let report = generate_report(&output);
    std::fs::write(&args.report, &report)?;
    println!("📝 Markdown 报告已保存: {}", args.report);

    Ok(())
}

fn save_output(output: &Output, path: &str) -> Result<()> {
    let json = serde_json::to_string_pretty(&output)?;
    if let Some(parent) = std::path::Path::new(path).parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(path, json)?;
    Ok(())
}
