use std::path::Path;

use anyhow::Result;
use quanttide_agent::llm::{CompleteOptions, LLM};
use quanttide_agent::message::Message;
use serde_json::Value;

const DESTINATION_PROMPT: &str = r#"You decide where to place source code in a public repository.

The public repo has these existing examples:
{existing_examples}

The source code to be open-sourced has this structure:
{source_structure}

Key files and their purposes:
{source_summary}

Decide:
1. Does this code FIT into an existing examples/ subdirectory? If so, which one?
2. Or should it go into a NEW examples/ subdirectory?

Respond with JSON:
{{
  "destination": "examples/connect",
  "reasoning": "...",
  "new_folder_name": null
}}

Or for a new folder:
{{
  "destination": "examples/my-new-module",
  "reasoning": "...",
  "new_folder_name": "my-new-module"
}}

Rules:
- Prefer existing folders if the code is semantically related
- Use `examples/` as the base directory
- The destination should be relative to the public repo root
- If creating new, use kebab-case for folder names
"#;

/// 列举公仓 examples/ 中的已有子目录（不调用 LLM，可测试）
pub fn list_existing_examples(public_dst: &Path) -> String {
    let examples_dir = public_dst.join("examples");
    if examples_dir.exists() {
        let mut dirs: Vec<String> = Vec::new();
        if let Ok(entries) = std::fs::read_dir(&examples_dir) {
            for entry in entries.flatten() {
                if entry.file_type().map(|t| t.is_dir()).unwrap_or(false) {
                    if let Some(name) = entry.file_name().to_str() {
                        dirs.push(format!("  {}/", name));
                    }
                }
            }
        }
        if dirs.is_empty() {
            "  (none)".to_string()
        } else {
            dirs.join("\n")
        }
    } else {
        "  (no examples/ directory yet)".to_string()
    }
}

/// 扫描源码结构（不调用 LLM，可测试）
pub fn scan_source_structure(private_src: &Path, sync_src: Option<&str>) -> (String, String) {
    let items: Vec<String> = match sync_src {
        Some(s) => s.split_whitespace().map(|s| s.to_string()).collect(),
        None => vec![".".to_string()],
    };

    let mut structure_lines = Vec::new();
    let mut summary_lines = Vec::new();

    for item in items.iter().take(8) {
        let item = item.trim_end_matches('/');
        let full = private_src.join(item);

        if full.is_dir() {
            structure_lines.push(format!("  {}/", item));
            if let Ok(entries) = std::fs::read_dir(&full) {
                for (i, entry) in entries.flatten().enumerate() {
                    if i >= 8 {
                        break;
                    }
                    let name = entry.file_name().to_string_lossy().to_string();
                    structure_lines.push(format!("    {}", name));

                    let ext = std::path::Path::new(&name)
                        .extension()
                        .map(|e| e.to_string_lossy().to_string())
                        .unwrap_or_default();
                    if ext == "rs" || ext == "py" || ext == "md" {
                        if let Ok(content) = std::fs::read_to_string(entry.path()) {
                            let truncated: String = content.chars().take(500).collect();
                            let p = entry.path();
                            let rel = p.strip_prefix(private_src).unwrap_or(&p).to_string_lossy();
                            summary_lines.push(format!("\n--- {} ---\n{}", rel, truncated));
                        }
                    }
                }
            }
        } else if full.is_file() {
            structure_lines.push(format!("  {}", item));
            let ext = full
                .extension()
                .map(|e| e.to_string_lossy())
                .unwrap_or_default();
            if ext == "rs" || ext == "py" || ext == "md" {
                if let Ok(content) = std::fs::read_to_string(&full) {
                    let truncated: String = content.chars().take(500).collect();
                    summary_lines.push(format!("\n--- {} ---\n{}", item, truncated));
                }
            }
        }
    }

    let source_structure = structure_lines.join("\n");
    let source_summary: String = summary_lines.join("\n").chars().take(4000).collect();
    (source_structure, source_summary)
}

/// 使用 LLM 判断代码应该放入公仓的哪个目录
pub fn decide_destination(
    private_src: &Path,
    public_dst: &Path,
    sync_src: Option<&str>,
    llm: &LLM,
) -> Result<String> {
    // 列举公仓中已有的 examples/
    let existing_examples = list_existing_examples(public_dst);

    // 扫描源码结构
    let (source_structure, source_summary) = scan_source_structure(private_src, sync_src);

    let user_content = DESTINATION_PROMPT
        .replace("{existing_examples}", &existing_examples)
        .replace("{source_structure}", &source_structure)
        .replace("{source_summary}", &source_summary);

    let messages = vec![
        Message::new(
            "system",
            "You decide where code goes in a public repo. Respond with JSON.",
        ),
        Message::new("user", &user_content),
    ];

    let options = CompleteOptions {
        response_format: Some(serde_json::json!({"type": "json_object"})),
        temperature: Some(0.0),
        ..Default::default()
    };

    let resp = llm.complete(&messages, options)?;
    let decision: Value = serde_json::from_str(&resp.content)
        .map_err(|e| anyhow::anyhow!("解析 LLM 决策失败: {}", e))?;

    let destination = decision
        .get("destination")
        .and_then(|v| v.as_str())
        .unwrap_or("examples")
        .to_string();

    let reasoning = decision
        .get("reasoning")
        .and_then(|v| v.as_str())
        .unwrap_or("");

    println!("  LLM 决定: {}", destination);
    if !reasoning.is_empty() {
        println!("  理由: {}", reasoning);
    }

    Ok(destination)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use std::io::Write;

    #[test]
    fn test_list_existing_examples_no_dir() {
        let dir = tempfile::tempdir().unwrap();
        let result = list_existing_examples(dir.path());
        assert_eq!(result, "  (no examples/ directory yet)");
    }

    #[test]
    fn test_list_existing_examples_empty() {
        let dir = tempfile::tempdir().unwrap();
        fs::create_dir(dir.path().join("examples")).unwrap();
        let result = list_existing_examples(dir.path());
        assert_eq!(result, "  (none)");
    }

    #[test]
    fn test_list_existing_examples_with_dirs() {
        let dir = tempfile::tempdir().unwrap();
        fs::create_dir_all(dir.path().join("examples").join("human")).unwrap();
        fs::create_dir_all(dir.path().join("examples").join("connect")).unwrap();
        fs::create_dir_all(dir.path().join("examples").join("delib")).unwrap();
        // also create a file that should be ignored
        let mut f = fs::File::create(dir.path().join("examples").join("README.md")).unwrap();
        f.write_all(b"readme").unwrap();

        let result = list_existing_examples(dir.path());
        assert!(result.contains("  connect/"));
        assert!(result.contains("  human/"));
        assert!(result.contains("  delib/"));
        assert!(!result.contains("README"));
    }

    #[test]
    fn test_scan_source_structure_dirs() {
        let dir = tempfile::tempdir().unwrap();
        let src = dir.path().join("private");
        fs::create_dir_all(src.join("src")).unwrap();
        let mut f = fs::File::create(src.join("src").join("main.rs")).unwrap();
        f.write_all(b"fn main() { println!(\"hello\"); }").unwrap();
        let mut f = fs::File::create(src.join("README.md")).unwrap();
        f.write_all(b"# Project").unwrap();
        fs::create_dir_all(src.join("target")).unwrap(); // should not be scanned

        let (structure, summary) = scan_source_structure(&src, Some("src"));
        assert!(structure.contains("  src/"));
        assert!(structure.contains("    main.rs"));
        assert!(structure.contains("main.rs"));
        // target/ should not appear since sync_src filters it
        assert!(!structure.contains("target"));
        // README.md is at root level, not in src/
        assert!(!summary.contains("README"));
    }

    #[test]
    fn test_scan_source_structure_single_file() {
        let dir = tempfile::tempdir().unwrap();
        let mut f = fs::File::create(dir.path().join("script.py")).unwrap();
        f.write_all(b"print('hello')").unwrap();

        let (structure, summary) = scan_source_structure(dir.path(), Some("script.py"));
        assert!(structure.contains("  script.py"));
        assert!(summary.contains("script.py"));
    }

    #[test]
    fn test_scan_source_structure_empty_sync() {
        let dir = tempfile::tempdir().unwrap();
        let (structure, _) = scan_source_structure(dir.path(), None);
        // default sync is "." -> scans the directory itself
        assert!(structure.contains("  ./"));
    }

    #[test]
    fn test_scan_source_structure_limit_files() {
        let dir = tempfile::tempdir().unwrap();
        fs::create_dir_all(dir.path().join("src")).unwrap();
        // create 10 files to test the 8-file limit
        for i in 0..10 {
            let mut f =
                fs::File::create(dir.path().join("src").join(format!("file{}.rs", i))).unwrap();
            f.write_all(b"fn main() {}").unwrap();
        }

        let (structure, _) = scan_source_structure(dir.path(), Some("src"));
        let file_count = structure
            .lines()
            .filter(|l| l.trim().starts_with("file"))
            .count();
        assert_eq!(file_count, 8, "should limit to 8 files");
    }

    #[test]
    fn test_decide_destination_format() {
        let prompt = DESTINATION_PROMPT
            .replace("{existing_examples}", "  (none)")
            .replace("{source_structure}", "  src/\n    main.rs")
            .replace("{source_summary}", "--- main.rs ---\nfn main() {}");
        assert!(prompt.contains("examples/"));
        assert!(prompt.contains("main.rs"));
    }

    #[ignore]
    #[test]
    fn test_decide_destination_with_llm() {
        let api_key = std::env::var("DEEPSEEK_API_KEY").unwrap_or_default();
        if api_key.is_empty() || api_key == "sk-xxx" {
            eprintln!("  skip: DEEPSEEK_API_KEY not set");
            return;
        }

        let private = tempfile::tempdir().unwrap();
        let public = tempfile::tempdir().unwrap();

        // source files that look like a Rust project
        std::fs::create_dir_all(private.path().join("src")).unwrap();
        std::fs::write(private.path().join("src").join("main.rs"), "fn main() {}").unwrap();
        std::fs::write(
            private.path().join("Cargo.toml"),
            "[package]\nname = \"demo\"\n",
        )
        .unwrap();

        // existing examples in public repo
        std::fs::create_dir_all(public.path().join("examples").join("human")).unwrap();
        std::fs::create_dir_all(public.path().join("examples").join("connect")).unwrap();

        let llm = LLM::new("deepseek-chat", "https://api.deepseek.com", &api_key);
        let result = decide_destination(private.path(), public.path(), Some("src"), &llm);
        assert!(result.is_ok());
        let dest = result.unwrap();
        assert!(dest.starts_with("examples/"));
    }
}
