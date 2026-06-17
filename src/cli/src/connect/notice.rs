use clap::Args;
use std::process::Command;

#[derive(Args)]
pub struct NoticeArgs {
    /// 群名称或 chat_id
    #[arg(long)]
    pub chat: String,
    /// 成员姓名或 open_id
    #[arg(long)]
    pub at: String,
    /// 通知内容
    #[arg(long)]
    pub notice: String,
}

fn resolve_chat_id(chat: &str) -> Result<String, String> {
    if chat.starts_with("oc_") {
        return Ok(chat.to_string());
    }
    let output = Command::new("lark-cli")
        .args(["im", "+chat-search", "--query", chat, "--as", "user"])
        .output()
        .map_err(|e| format!("无法执行 lark-cli: {}", e))?;
    let stdout = String::from_utf8_lossy(&output.stdout);
    if let Some(id) = stdout.lines().find_map(|l| {
        serde_json::from_str::<serde_json::Value>(l)
            .ok()
            .and_then(|v| v["data"]["chats"][0]["chat_id"].as_str().map(String::from))
    }) {
        return Ok(id);
    }
    let output = Command::new("lark-cli")
        .args(["im", "+chat-list", "--as", "user"])
        .output()
        .map_err(|e| format!("无法执行 lark-cli: {}", e))?;
    let stdout = String::from_utf8_lossy(&output.stdout);
    for line in stdout.lines() {
        if let Ok(v) = serde_json::from_str::<serde_json::Value>(line) {
            if let Some(chats) = v["data"]["chats"].as_array() {
                for chat_entry in chats {
                    if chat_entry["name"].as_str() == Some(chat) {
                        if let Some(id) = chat_entry["chat_id"].as_str() {
                            return Ok(id.to_string());
                        }
                    }
                }
            }
        }
    }
    Err(format!("未找到群: {}", chat))
}

fn resolve_open_id(user: &str) -> Result<String, String> {
    if user.starts_with("ou_") {
        return Ok(user.to_string());
    }
    let output = Command::new("lark-cli")
        .args(["contact", "+search-user", "--query", user, "--as", "user"])
        .output()
        .map_err(|e| format!("无法执行 lark-cli: {}", e))?;
    let stdout = String::from_utf8_lossy(&output.stdout);
    for line in stdout.lines() {
        if let Ok(v) = serde_json::from_str::<serde_json::Value>(line) {
            if let Some(open_id) = v["data"]["users"][0]["open_id"].as_str() {
                return Ok(open_id.to_string());
            }
        }
    }
    Err(format!("未找到成员: {}", user))
}

pub fn run(args: &NoticeArgs) {
    let chat_id = match resolve_chat_id(&args.chat) {
        Ok(id) => id,
        Err(e) => {
            eprintln!("错误: {}", e);
            return;
        }
    };
    let open_id = match resolve_open_id(&args.at) {
        Ok(id) => id,
        Err(e) => {
            eprintln!("错误: {}", e);
            return;
        }
    };
    let markdown = format!("<at user_id=\"{}\"></at>\n\n{}", open_id, args.notice);
    let output = Command::new("lark-cli")
        .args([
            "im",
            "+messages-send",
            "--chat-id",
            &chat_id,
            "--markdown",
            &markdown,
            "--as",
            "user",
        ])
        .output();
    match output {
        Ok(o) if o.status.success() => println!("✓ 已发送"),
        Ok(o) => eprintln!("发送失败: {}", String::from_utf8_lossy(&o.stderr)),
        Err(e) => eprintln!("无法执行 lark-cli: {}", e),
    }
}
