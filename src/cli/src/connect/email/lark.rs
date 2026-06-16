use std::process::{Command, Stdio};
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

use anyhow::{Context, Result};
use serde::Deserialize;

use super::super::{EmailFetcher, Message};

#[derive(Debug, Deserialize)]
struct LarkResponse {
    messages: Option<Vec<LarkMessage>>,
    page_token: Option<String>,
}

#[derive(Debug, Deserialize)]
struct LarkMessage {
    #[serde(default)]
    subject: String,
    #[serde(default)]
    date: String,
}

pub struct LarkCliFetcher;

impl EmailFetcher for LarkCliFetcher {
    fn fetch_all(&self) -> Result<Vec<Message>> {
        let mut all = Vec::new();
        let mut token: Option<String> = None;

        for _ in 0..20 {
            let resp = run_lark_cli(token.as_deref())?;
            if let Some(batch) = resp.messages {
                if batch.is_empty() {
                    break;
                }
                for m in batch {
                    all.push(Message { subject: m.subject, date: m.date });
                }
            } else {
                break;
            }
            match resp.page_token {
                Some(t) if !t.is_empty() => token = Some(t),
                _ => break,
            }
        }

        Ok(all)
    }
}

fn run_lark_cli(page_token: Option<&str>) -> Result<LarkResponse> {
    let mut args = vec![
        "mail",
        "+triage",
        "--mailbox",
        "hr@quanttide.com",
        "--max",
        "50",
        "--format",
        "json",
    ];
    if let Some(token) = page_token {
        args.extend(["--page-token", token]);
    }

    let child = Command::new("lark-cli")
        .args(&args)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .context("无法启动 lark-cli，请确认已安装并完成登录")?;

    let (tx, rx) = mpsc::channel();
    thread::spawn(move || {
        let result = child.wait_with_output();
        let _ = tx.send(result);
    });

    let output = rx
        .recv_timeout(Duration::from_secs(15))
        .map_err(|_| anyhow::anyhow!("lark-cli 请求超时（15s），请检查网络连接或认证状态"))?
        .context("lark-cli 进程异常退出")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("lark-cli 执行失败: {}", stderr.trim());
    }

    let data: LarkResponse =
        serde_json::from_slice(&output.stdout).context("lark-cli 返回数据格式异常")?;
    Ok(data)
}
