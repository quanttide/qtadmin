use std::collections::HashSet;
use std::path::Path;

use anyhow::Result;
use quanttide_agent::llm::{CompleteOptions, LLM};
use quanttide_agent::message::Message;
use regex::Regex;
use serde_json::Value;

use super::copy;

// box-drawing chars and arrows/checkmarks are not used;
// the original Python script printed arrow and checkmark glyphs,
// but in Rust console output we keep it simple with ASCII.

// ── 静态脱敏规则 ──────────────────────────────────────────────────────

struct StaticRule {
    pattern: Regex,
    replacement: &'static str,
    description: &'static str,
}

fn static_rules() -> Vec<StaticRule> {
    vec![
        // email: user@domain.com -> user@example.com
        StaticRule {
            pattern: Regex::new(r"[\w.+-]+@[\w-]+\.(com|net|org|cn|io)").unwrap(),
            replacement: "user@example.com",
            description: "Email address",
        },
        // API key pattern: sk-xxxx, api_key=xxxx
        StaticRule {
            pattern: Regex::new(r#"(?i)(sk-|api[_-]?key[=:]\s*['"]?)[\w-]{16,}"#).unwrap(),
            replacement: "${1}sk-xxx",
            description: "API key / token",
        },
        // internal IP: 10.x.x.x, 192.168.x.x, 172.16-31.x.x
        StaticRule {
            pattern: Regex::new(
                r"\b(10\.\d{1,3}\.\d{1,3}\.\d{1,3}|192\.168\.\d{1,3}\.\d{1,3}|172\.(1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3})\b",
            )
            .unwrap(),
            replacement: "127.0.0.1",
            description: "Internal IP address",
        },
        // phone: 1xx-xxxx-xxxx
        StaticRule {
            pattern: Regex::new(r"\b1[3-9]\d{2}[-\s]?\d{4}[-\s]?\d{4}\b").unwrap(),
            replacement: "138-0000-0000",
            description: "Phone number",
        },
    ]
}

/// 检测和替换敏感信息的返回结果
#[derive(Debug)]
pub struct Replacement {
    pub sensitive: String,
    pub replace_with: String,
    pub reason: String,
}

/// 对目录中的文件执行脱敏
pub fn sanitize(dir: &Path, dry_run: bool, llm: Option<&LLM>) -> Result<Vec<Replacement>> {
    let files = copy::find_source_files(dir);
    if files.is_empty() {
        println!("  未找到需要脱敏的文件");
        return Ok(Vec::new());
    }

    let mut all_replacements: Vec<Replacement> = Vec::new();

    // 1. 静态规则脱敏
    let static_repl = apply_static_rules(&files, dry_run);
    all_replacements.extend(static_repl);

    // 2. LLM 脱敏（如果提供了 LLM）
    if let Some(llm) = llm {
        let llm_repl = apply_llm_sanitize(&files, dir, llm, dry_run)?;
        all_replacements.extend(llm_repl);
    }

    if all_replacements.is_empty() {
        println!("  未检测到敏感内容");
    } else {
        println!("  共 {} 个替换", all_replacements.len());
        if dry_run {
            for r in &all_replacements {
                println!("  {} => {} ({})", r.sensitive, r.replace_with, r.reason);
            }
        }
    }

    Ok(all_replacements)
}

/// 应用静态正则规则
fn apply_static_rules(files: &[std::path::PathBuf], dry_run: bool) -> Vec<Replacement> {
    let rules = static_rules();
    let mut replacements = Vec::new();
    let mut seen = HashSet::new();

    for file in files {
        let content = match std::fs::read_to_string(file) {
            Ok(c) => c,
            Err(_) => continue,
        };

        let mut new_content = content.clone();
        let mut changed = false;

        for rule in &rules {
            for cap in rule.pattern.captures_iter(&content) {
                if let Some(m) = cap.get(0) {
                    let matched = m.as_str().to_string();
                    let key = (matched.to_lowercase(), rule.replacement.to_lowercase());
                    if seen.insert(key) {
                        replacements.push(Replacement {
                            sensitive: matched,
                            replace_with: rule.replacement.to_string(),
                            reason: rule.description.to_string(),
                        });
                    }
                }
            }

            let after = rule.pattern.replace_all(&new_content, rule.replacement);
            if after != new_content {
                changed = true;
                new_content = after.to_string();
            }
        }

        if changed && !dry_run {
            if let Err(e) = std::fs::write(file, &new_content) {
                eprintln!("  写入失败 {}: {}", file.display(), e);
            }
        }
    }

    replacements
}

const DETECT_PROMPT: &str = r#"You are reviewing source code that will be published to a public GitHub repository.
Find ANY sensitive information that must be removed before publishing.

Types of sensitive info to detect:
- Email addresses (replace "user@domain.com" with "user@example.com")
- Internal domain names (replace "company.com", "corp.net" with "example.com")
- API keys, tokens, secrets (replace with "sk-xxx")
- Internal server URLs, IP addresses (replace with "https://api.example.com")
- Employee/customer names paired with contact info (replace names with "Example User")
- Internal project codenames (replace with "example-project")
- Real phone numbers (replace with "000-0000-0000")
- Any confidential business logic comments

You are given multiple files below, separated by "--- filename ---" markers.
Respond with a SINGLE JSON array. Each element is:
{
  "file": "relative/path/to/file.rs",
  "findings": [
    {"sensitive": "hr@example.com", "replace_with": "hr@example.com", "reason": "Internal email address"}
  ]
}

If no sensitive info is found in any files, respond with an empty array [].

Be thorough. Check every string literal, comment, config value, and docstring.
"#;

/// 使用 LLM 检测敏感内容
fn apply_llm_sanitize(
    files: &[std::path::PathBuf],
    root_dir: &Path,
    llm: &LLM,
    dry_run: bool,
) -> Result<Vec<Replacement>> {
    let batch_size = 5;
    let mut all_replacements = Vec::new();
    let mut seen = HashSet::new();

    for chunk in files.chunks(batch_size) {
        let mut parts = Vec::new();

        for file in chunk {
            let content = match std::fs::read_to_string(file) {
                Ok(c) => c,
                Err(_) => continue,
            };

            // skip large files
            if content.len() > 50000 || content.len() < 20 {
                continue;
            }

            let truncated = if content.len() > 15000 {
                let mut s = content.chars().take(15000).collect::<String>();
                s.push_str("\n... [truncated]");
                s
            } else {
                content
            };

            let rel = file
                .strip_prefix(root_dir)
                .unwrap_or(file)
                .to_string_lossy()
                .to_string();
            parts.push(format!("--- {} ---\n{}", rel, truncated));
        }

        if parts.is_empty() {
            continue;
        }

        let user_content = parts.join("\n");

        let messages = vec![
            Message::new("system", DETECT_PROMPT),
            Message::new("user", &user_content),
        ];

        let options = CompleteOptions {
            response_format: Some(serde_json::json!({"type": "json_object"})),
            ..Default::default()
        };

        let resp = match llm.complete(&messages, options) {
            Ok(r) => r,
            Err(e) => {
                eprintln!("  [notice] LLM batch failed: {}", e);
                continue;
            }
        };

        let result: Value = match serde_json::from_str(&resp.content) {
            Ok(v) => v,
            Err(_) => continue,
        };

        let items = match result.as_array() {
            Some(arr) => arr.clone(),
            None => result
                .get("results")
                .or_else(|| result.get("files"))
                .and_then(|v| v.as_array())
                .map(|a| a.clone())
                .unwrap_or_default(),
        };

        for item in &items {
            if let Some(findings) = item.get("findings").and_then(|f| f.as_array()) {
                for finding in findings {
                    let sensitive = finding
                        .get("sensitive")
                        .and_then(|v| v.as_str())
                        .unwrap_or("")
                        .trim()
                        .to_string();
                    let replacement = finding
                        .get("replace_with")
                        .and_then(|v| v.as_str())
                        .unwrap_or("")
                        .trim()
                        .to_string();
                    let reason = finding
                        .get("reason")
                        .and_then(|v| v.as_str())
                        .unwrap_or("")
                        .to_string();

                    if sensitive.is_empty() || replacement.is_empty() || sensitive == replacement {
                        continue;
                    }

                    let key = (sensitive.to_lowercase(), replacement.to_lowercase());
                    if seen.insert(key) {
                        all_replacements.push(Replacement {
                            sensitive,
                            replace_with: replacement,
                            reason,
                        });
                    }
                }
            }
        }
    }

    if all_replacements.is_empty() {
        return Ok(all_replacements);
    }

    // apply replacements
    let mut affected_files: HashSet<std::path::PathBuf> = HashSet::new();
    for r in &all_replacements {
        if dry_run {
            continue;
        }
        for file in files {
            let content = match std::fs::read_to_string(file) {
                Ok(c) => c,
                Err(_) => continue,
            };
            let new_content = content.replace(&r.sensitive, &r.replace_with);
            if new_content != content {
                if let Err(e) = std::fs::write(file, &new_content) {
                    eprintln!("  write failed {}: {}", file.display(), e);
                } else {
                    affected_files.insert(file.clone());
                }
            }
        }
    }

    if !dry_run && !affected_files.is_empty() {
        println!("  sanitized {} files", affected_files.len());
    }

    Ok(all_replacements)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use std::io::Write;
    use std::path::PathBuf;

    fn create_file(dir: &Path, name: &str, content: &str) -> PathBuf {
        let path = dir.join(name);
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).unwrap();
        }
        let mut f = fs::File::create(&path).unwrap();
        f.write_all(content.as_bytes()).unwrap();
        path
    }

    #[test]
    fn test_static_rules_email() {
        let rules = static_rules();
        let email_rule = &rules[0];
        assert!(email_rule.pattern.is_match("user@company.com"));
        assert!(!email_rule.pattern.is_match("user@localhost"));
    }

    #[test]
    fn test_static_rules_api_key() {
        let rules = static_rules();
        let key_rule = &rules[1];
        let result = key_rule
            .pattern
            .replace_all("sk-proj-abcdefghijklmnopqrstuvwx", "${1}sk-xxx");
        assert!(result.contains("sk-xxx"));
    }

    #[test]
    fn test_apply_static_rules_internal_ip() {
        let rules = static_rules();
        let ip_rule = &rules[2];
        assert!(ip_rule.pattern.is_match("10.0.0.1"));
        assert!(ip_rule.pattern.is_match("192.168.1.1"));
        assert!(!ip_rule.pattern.is_match("8.8.8.8"));
    }

    #[test]
    fn test_sanitize_orchestrator_no_files() {
        let dir = tempfile::tempdir().unwrap();
        let result = sanitize(dir.path(), false, None).unwrap();
        assert!(result.is_empty());
    }

    #[test]
    fn test_sanitize_orchestrator_with_static_rules() {
        let dir = tempfile::tempdir().unwrap();
        let f_path = dir.path().join("test.rs");
        let mut f = std::fs::File::create(&f_path).unwrap();
        f.write_all(b"let email = \"admin@internal.com\";").unwrap();

        let result = sanitize(dir.path(), false, None).unwrap();
        assert!(!result.is_empty());
        let content = std::fs::read_to_string(&f_path).unwrap();
        assert!(!content.contains("admin@internal.com"));
    }

    #[test]
    fn test_sanitize_orchestrator_dry_run() {
        let dir = tempfile::tempdir().unwrap();
        let f_path = dir.path().join("test.rs");
        std::fs::write(&f_path, "let email = \"admin@internal.com\";").unwrap();

        let result = sanitize(dir.path(), true, None).unwrap();
        assert!(!result.is_empty());
        // dry-run: file unchanged
        let content = std::fs::read_to_string(&f_path).unwrap();
        assert!(content.contains("admin@internal.com"));
    }

    #[test]
    fn test_sanitize_orchestrator_unknown_ext() {
        let dir = tempfile::tempdir().unwrap();
        // .txt files are not scanned
        std::fs::write(dir.path().join("secret.txt"), "admin@internal.com").unwrap();
        let result = sanitize(dir.path(), false, None).unwrap();
        assert!(result.is_empty());
    }

    #[test]
    fn test_sanitize_clean_file() {
        let dir = tempfile::tempdir().unwrap();
        // .rs file with no sensitive content
        std::fs::write(
            dir.path().join("main.rs"),
            "fn main() {\n    let x = 42;\n    println!(\"hello\");\n}\n",
        )
        .unwrap();
        let result = sanitize(dir.path(), false, None).unwrap();
        assert!(result.is_empty());
    }

    #[ignore]
    #[test]
    fn test_sanitize_with_llm() {
        let api_key = std::env::var("DEEPSEEK_API_KEY").unwrap_or_default();
        if api_key.is_empty() || api_key == "sk-xxx" {
            eprintln!("  skip: DEEPSEEK_API_KEY not set");
            return;
        }

        let dir = tempfile::tempdir().unwrap();
        std::fs::write(
            dir.path().join("config.rs"),
            r#"let internal_url = "https://internal.company.com/api/v1";
let support_email = "support@corp.net";
"#,
        )
        .unwrap();

        let llm = LLM::new("deepseek-chat", "https://api.deepseek.com", &api_key);
        let result = sanitize(dir.path(), false, Some(&llm)).unwrap();
        // LLM should find sensitive content (internal URL + email)
        assert!(!result.is_empty());
        // file should be sanitized
        let content = std::fs::read_to_string(dir.path().join("config.rs")).unwrap();
        assert!(!content.contains("internal.company.com"));
        assert!(!content.contains("@corp.net"));
    }

    #[test]
    fn test_apply_static_rules_dry_run() {
        let dir = tempfile::tempdir().unwrap();
        let file = create_file(
            dir.path(),
            "test.rs",
            "let email = \"admin@internal.com\";\nlet key = \"sk-proj-abcdefghijklmnopq\";\n",
        );

        let files = vec![file.clone()];
        let repl = apply_static_rules(&files, true);
        assert!(!repl.is_empty());

        // dry-run: file unchanged
        let content = fs::read_to_string(&file).unwrap();
        assert!(content.contains("admin@internal.com"));
    }

    #[test]
    fn test_apply_static_rules_apply() {
        let dir = tempfile::tempdir().unwrap();
        let file = create_file(dir.path(), "test.rs", "let email = \"admin@internal.com\";");

        let files = vec![file.clone()];
        let repl = apply_static_rules(&files, false);
        assert!(!repl.is_empty());

        let content = fs::read_to_string(&file).unwrap();
        assert!(!content.contains("admin@internal.com"));
        assert!(content.contains("user@example.com"));
    }
}
