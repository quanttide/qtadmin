//! 聊天记录拉取（lark-cli im 域）
//!
//! 招聘讨论分散在各群聊与单聊中，通过跨群搜索聚合。

use std::process::Command;

use anyhow::{Context, Result};
use serde::Deserialize;

/// 一条聊天消息
#[derive(Debug, Clone)]
pub struct ChatMessage {
    /// 发送者姓名
    pub sender: String,
    /// 消息内容
    pub content: String,
    /// 发送时间（YYYY-MM-DD HH:MM）
    pub time: String,
}

#[derive(Debug, Deserialize)]
struct SearchResponse {
    data: SearchData,
}

#[derive(Debug, Deserialize)]
struct SearchData {
    #[serde(default)]
    messages: Vec<SearchMessage>,
}

#[derive(Debug, Deserialize)]
struct SearchMessage {
    content: String,
    #[serde(default)]
    create_time: String,
    sender: Sender,
}

#[derive(Debug, Deserialize)]
struct Sender {
    #[serde(default)]
    name: String,
}

/// 跨群聊天记录搜索器
pub struct LarkChatFetcher;

impl LarkChatFetcher {
    /// 跨群搜索聊天记录，返回匹配消息列表。
    ///
    /// 示例：`search("招聘")` 聚合所有群聊与单聊中提及招聘的讨论。
    pub fn search(&self, query: &str) -> Result<Vec<ChatMessage>> {
        let output = Command::new("lark-cli")
            .args([
                "im",
                "+messages-search",
                "--query",
                query,
                "--as",
                "user",
                "--page-size",
                "50",
                "--format",
                "json",
            ])
            .output()
            .context("无法启动 lark-cli，请确认已安装并完成登录")?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("lark-cli 执行失败: {}", stderr.trim());
        }

        let resp: SearchResponse =
            serde_json::from_slice(&output.stdout).context("lark-cli 返回数据格式异常")?;

        Ok(resp
            .data
            .messages
            .into_iter()
            .map(|m| ChatMessage {
                sender: m.sender.name,
                content: m.content,
                time: m.create_time,
            })
            .collect())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_search_response() {
        let json = r#"{
            "ok": true,
            "data": {
                "messages": [
                    {
                        "content": "招聘会分两个等级",
                        "create_time": "2026-08-05 15:49",
                        "sender": {"name": "张果"}
                    }
                ]
            }
        }"#;
        let resp: SearchResponse = serde_json::from_str(json).unwrap();
        assert_eq!(resp.data.messages.len(), 1);
        assert_eq!(resp.data.messages[0].content, "招聘会分两个等级");
        assert_eq!(resp.data.messages[0].sender.name, "张果");
    }
}
