use std::path::Path;

use anyhow::{Context, Result};
use quanttide_agent::llm::{CompleteOptions, LLM};
use quanttide_agent::message::Message;
use serde_json::Value;

use crate::asset::git_utils;

const COMMIT_DECISION_PROMPT: &str = r#"You are an AI assistant helping to open-source internal code.

Below is the git diff of changes to be published to a public repository.

Your task:
1. Review the diff carefully
2. Decide if these changes should be committed (they might be empty, trivial, or incomplete)
3. If yes, write a clear commit message
4. If no, explain why

Respond with JSON:
{
  "should_commit": true,
  "commit_message": "feat: add email ETL pipeline\n\nAutomated email fetching, attachment download, and LLM classification for recruitment.",
  "reasoning": "This adds a complete new module with working code."
}

Or if not ready:
{
  "should_commit": false,
  "commit_message": "",
  "reasoning": "The diff only contains placeholder files with no real implementation."
}
"#;

/// 在公仓中执行 git commit 和 tag
pub fn git_commit(
    dst_dir: &Path,
    sync_dst: Option<&str>,
    version: Option<&str>,
    llm: Option<&LLM>,
) -> Result<bool> {
    println!("\n=== git: {} ===", dst_dir.display());

    // 检查 .git 指针是否有效
    let git_file = dst_dir.join(".git");
    if git_file.is_file() {
        let content = std::fs::read_to_string(&git_file).unwrap_or_default();
        if content.trim().starts_with("gitdir:") {
            let gitdir_path = content.trim().strip_prefix("gitdir:").unwrap_or("").trim();
            if !std::path::Path::new(gitdir_path).exists() {
                println!("  .git 指针损坏，重新初始化");
                std::fs::remove_file(&git_file)?;
                std::process::Command::new("git")
                    .args(["init"])
                    .current_dir(dst_dir)
                    .output()
                    .context("git init 失败")?;
            }
        }
    }

    // Stage 变更
    let add_path = sync_dst.unwrap_or(".");
    git_utils::run_git_cmd(&["add", "-A", add_path], dst_dir)?;

    // 检查是否有变更
    if !git_utils::has_uncommitted_changes(dst_dir)? {
        println!("  无变更，跳过 commit");
        return Ok(false);
    }

    // 如果有 LLM，让它决定是否提交
    if let Some(llm) = llm {
        let diff_stat = git_utils::run_git_cmd(&["diff", "--cached", "--stat"], dst_dir)?;
        let diff_content = git_utils::run_git_cmd(&["diff", "--cached"], dst_dir)?;

        let mut user_content = format!(
            "Repository: {}\nSync path: {}\n\nDiff stat:\n{}\n\nFull diff:\n{}",
            dst_dir
                .file_name()
                .map(|n| n.to_string_lossy())
                .unwrap_or_default(),
            add_path,
            diff_stat,
            &diff_content[..diff_content.len().min(12000)]
        );
        if let Some(v) = version {
            user_content.push_str(&format!("\n\nRequested version tag: {}", v));
        }

        let messages = vec![
            Message::new("system", COMMIT_DECISION_PROMPT),
            Message::new("user", &user_content),
        ];

        let options = CompleteOptions {
            response_format: Some(serde_json::json!({"type": "json_object"})),
            temperature: Some(0.0),
            ..Default::default()
        };

        let decision: Value = match llm.complete(&messages, options) {
            Ok(resp) => serde_json::from_str(&resp.content).unwrap_or_default(),
            Err(e) => {
                println!("  LLM 决策失败: {}，使用默认行为", e);
                serde_json::json!({"should_commit": true})
            }
        };

        if decision.get("should_commit").and_then(|v| v.as_bool()) == Some(false) {
            let reasoning = decision
                .get("reasoning")
                .and_then(|v| v.as_str())
                .unwrap_or("");
            println!("  LLM 决定不提交: {}", reasoning);
            git_utils::run_git_cmd(&["reset", "HEAD"], dst_dir)?;
            return Ok(false);
        }

        let default_msg = format!("opensource: 同步 {}", sync_dst.unwrap_or("."));
        let commit_msg = decision
            .get("commit_message")
            .and_then(|v| v.as_str())
            .filter(|s| !s.is_empty())
            .unwrap_or(&default_msg);

        let mut msg = commit_msg.to_string();
        if let Some(v) = version {
            msg.push_str(&format!("\n\n版本: {}", v));
        }

        git_utils::run_git_cmd(&["commit", "-m", &msg], dst_dir)?;
        println!("  ✓ 已提交: {}", msg.lines().next().unwrap_or(""));
    } else {
        // 没有 LLM，使用默认提交信息
        let msg = format!("opensource: 同步 {}", sync_dst.unwrap_or("."));
        git_utils::run_git_cmd(&["commit", "-m", &msg], dst_dir)?;
        println!("  ✓ 已提交: {}", msg);
    }

    // 打 tag
    if let Some(v) = version {
        let result = std::process::Command::new("git")
            .args(["rev-parse", v])
            .current_dir(dst_dir)
            .output();
        match result {
            Ok(out) if out.status.success() => {
                println!("  tag {} 已存在，跳过", v);
            }
            _ => {
                git_utils::run_git_cmd(&["tag", v], dst_dir)?;
                println!("  ✓ 已打 tag: {}", v);
            }
        }
    }

    Ok(true)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn init_repo(dir: &Path) {
        std::process::Command::new("git")
            .args(["init"])
            .current_dir(dir)
            .output()
            .unwrap();
        std::process::Command::new("git")
            .args(["config", "user.email", "test@test.com"])
            .current_dir(dir)
            .output()
            .unwrap();
        std::process::Command::new("git")
            .args(["config", "user.name", "Test"])
            .current_dir(dir)
            .output()
            .unwrap();
    }

    #[test]
    fn test_git_commit_no_changes() {
        let dir = tempfile::tempdir().unwrap();
        init_repo(dir.path());

        let result = git_commit(dir.path(), None, None, None).unwrap();
        assert!(!result); // no changes
    }

    #[test]
    fn test_git_commit_with_changes() {
        let dir = tempfile::tempdir().unwrap();
        init_repo(dir.path());
        fs::write(dir.path().join("test.txt"), "hello").unwrap();

        let result = git_commit(dir.path(), None, None, None).unwrap();
        assert!(result);

        // verify commit
        let log = git_utils::run_git_cmd(&["log", "--oneline", "-1"], dir.path()).unwrap();
        assert!(log.contains("opensource: 同步 ."));
    }

    #[test]
    fn test_git_commit_with_tag() {
        let dir = tempfile::tempdir().unwrap();
        init_repo(dir.path());
        fs::write(dir.path().join("test.txt"), "hello").unwrap();

        let result = git_commit(dir.path(), None, Some("v0.1.0"), None).unwrap();
        assert!(result);

        let tag = git_utils::run_git_cmd(&["tag", "-l"], dir.path()).unwrap();
        assert_eq!(tag, "v0.1.0");
    }

    #[test]
    fn test_git_commit_tag_already_exists() {
        let dir = tempfile::tempdir().unwrap();
        init_repo(dir.path());
        fs::write(dir.path().join("a.txt"), "a").unwrap();
        git_utils::run_git_cmd(&["add", "-A"], dir.path()).unwrap();
        git_utils::run_git_cmd(&["commit", "-m", "first"], dir.path()).unwrap();
        git_utils::run_git_cmd(&["tag", "v0.1.0"], dir.path()).unwrap();

        // second commit with same tag
        fs::write(dir.path().join("b.txt"), "b").unwrap();
        let result = git_commit(dir.path(), None, Some("v0.1.0"), None).unwrap();
        assert!(result);
    }

    #[test]
    fn test_git_commit_repair_broken_git_file() {
        let dir = tempfile::tempdir().unwrap();
        // write a .git file with a broken gitdir pointer
        fs::write(dir.path().join(".git"), "gitdir: /nonexistent/path").unwrap();
        fs::write(dir.path().join("test.txt"), "hello").unwrap();

        // should repair the .git pointer and commit successfully
        let result = git_commit(dir.path(), None, None, None).unwrap();
        assert!(result);
    }

    #[test]
    fn test_git_commit_with_sync_dst() {
        let dir = tempfile::tempdir().unwrap();
        init_repo(dir.path());
        let sub = dir.path().join("subdir");
        fs::create_dir_all(&sub).unwrap();
        fs::write(sub.join("test.txt"), "hello").unwrap();

        let result = git_commit(dir.path(), Some("subdir"), None, None).unwrap();
        assert!(result);

        let log = git_utils::run_git_cmd(&["log", "--oneline", "-1"], dir.path()).unwrap();
        assert!(log.contains("opensource: 同步 subdir"));
    }

    #[ignore]
    #[test]
    fn test_git_commit_with_llm() {
        let api_key = std::env::var("DEEPSEEK_API_KEY").unwrap_or_default();
        if api_key.is_empty() || api_key == "sk-xxx" {
            eprintln!("  skip: DEEPSEEK_API_KEY not set");
            return;
        }

        let dir = tempfile::tempdir().unwrap();
        init_repo(dir.path());
        fs::write(
            dir.path().join("hello.rs"),
            "fn main() { println!(\"hi\"); }",
        )
        .unwrap();

        let llm = LLM::new("deepseek-chat", "https://api.deepseek.com", &api_key);
        let result = git_commit(dir.path(), None, None, Some(&llm)).unwrap();
        assert!(result);

        let log = git_utils::run_git_cmd(&["log", "--oneline", "-1"], dir.path()).unwrap();
        // LLM will generate a commit message
        assert!(!log.is_empty());
    }
}
