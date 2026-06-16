use std::collections::BTreeMap;
use std::process::{Command, Stdio};
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

use anyhow::{Context, Result};
use chrono::NaiveDate;
use chrono::Datelike;
use serde::Deserialize;

use super::config;

#[derive(Debug, Deserialize)]
struct LarkResponse {
    messages: Option<Vec<Message>>,
    page_token: Option<String>,
}

#[derive(Debug, Deserialize)]
struct Message {
    #[serde(default)]
    subject: String,
    #[serde(default)]
    date: String,
}

#[derive(clap::Args)]
pub struct StatusArgs {
    /// 统计最近 N 天
    #[arg(long)]
    pub days: Option<u32>,
    /// 开始日期 (YYYY-MM-DD)
    #[arg(long)]
    pub start: Option<String>,
    /// 结束日期 (YYYY-MM-DD)
    #[arg(long)]
    pub end: Option<String>,
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

fn fetch_all_mailbox() -> Result<Vec<Message>> {
    let mut all = Vec::new();
    let mut token: Option<String> = None;

    for _ in 0..20 {
        let resp = run_lark_cli(token.as_deref())?;
        if let Some(batch) = resp.messages {
            if batch.is_empty() {
                break;
            }
            all.extend(batch);
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

fn extract_date(date_str: &str) -> Option<NaiveDate> {
    if date_str.is_empty() {
        return None;
    }

    // Try ISO 8601 / RFC 3339
    if let Ok(dt) = chrono::DateTime::parse_from_rfc3339(date_str) {
        return Some(dt.date_naive());
    }

    // Try YYYY-MM-DD directly
    if let Ok(d) = NaiveDate::parse_from_str(date_str, "%Y-%m-%d") {
        return Some(d);
    }

    // Fallback: regex extract YYYY-MM-DD
    let re = regex::Regex::new(r"(\d{4}-\d{2}-\d{2})").ok()?;
    let cap = re.find(date_str)?;
    NaiveDate::parse_from_str(cap.as_str(), "%Y-%m-%d").ok()
}

fn resolve_date_range(args: &StatusArgs) -> (Option<NaiveDate>, Option<NaiveDate>) {
    if let (Some(start), Some(end)) = (&args.start, &args.end) {
        let s = NaiveDate::parse_from_str(start, "%Y-%m-%d").ok();
        let e = NaiveDate::parse_from_str(end, "%Y-%m-%d").ok();
        return (s, e);
    }

    if let Some(days) = args.days {
        let end = chrono::Local::now().date_naive();
        let start = end - chrono::Duration::days(days as i64);
        return (Some(start), Some(end));
    }

    // Default: this month
    let now = chrono::Local::now().date_naive();
    let start = NaiveDate::from_ymd_opt(now.year(), now.month(), 1).unwrap_or(now);
    (Some(start), Some(end_date_for_default(now)))
}

fn end_date_for_default(now: NaiveDate) -> NaiveDate {
    now
}

fn filter_by_date(msgs: &[Message], start: Option<NaiveDate>, end: Option<NaiveDate>) -> Vec<&Message> {
    msgs.iter()
        .filter(|m| {
            let date = extract_date(&m.date);
            match (date, start, end) {
                (Some(d), Some(s), Some(e)) => d >= s && d <= e,
                (Some(d), Some(s), None) => d >= s,
                (Some(d), None, Some(e)) => d <= e,
                (Some(_), None, None) => true,
                (None, _, _) => false,
            }
        })
        .collect()
}

fn build_title(start: Option<NaiveDate>, end: Option<NaiveDate>, days: Option<u32>) -> String {
    match (start, end, days) {
        (Some(s), Some(e), None) => format!("量潮招聘数据统计 ({}/{} 至 {}/{})", s.month(), s.day(), e.month(), e.day()),
        (Some(s), None, None) => format!("量潮招聘数据统计 ({} 起)", s),
        (_, _, Some(d)) => format!("量潮招聘数据统计 (最近 {} 天)", d),
        _ => "量潮招聘数据统计".to_string(),
    }
}

fn print_report(msgs: &[&Message], rules: &[config::PositionRule], title: &str) {
    let total = msgs.len();
    let mut positions: BTreeMap<&str, usize> = BTreeMap::new();
    let mut unnamed_subjects: Vec<&str> = Vec::new();
    let mut daily: BTreeMap<String, usize> = BTreeMap::new();

    for m in msgs {
        let subj = m.subject.trim();
        let cat = if subj.is_empty() {
            None
        } else {
            config::classify(subj, rules)
        };

        match cat {
            Some(pos) => {
                *positions.entry(pos).or_insert(0) += 1;
            }
            None => {
                unnamed_subjects.push(subj);
            }
        }

        if let Some(d) = extract_date(&m.date) {
            *daily.entry(d.to_string()).or_insert(0) += 1;
        }
    }

    let identified = total - unnamed_subjects.len();
    let identified_pct = if total > 0 {
        identified * 100 / total
    } else {
        0
    };

    println!("# {}\n", title);
    println!("{} 封投递。", total);
    if total > 0 {
        println!(
            "其中可识别岗位 {} 封（{}%），其余为自动回复、空主题等。",
            identified, identified_pct
        );
    }
    println!();

    // Position distribution
    println!("## 岗位分布\n");
    println!("| 岗位 | 人数 |");
    println!("|------|------|");
    let mut sorted: Vec<_> = positions.into_iter().collect();
    sorted.sort_by(|a, b| b.1.cmp(&a.1));
    for (pos, count) in &sorted {
        println!("| {} | {} |", pos, count);
    }
    println!();

    // Daily trend
    if !daily.is_empty() {
        let avg = daily.values().sum::<usize>() as f64 / daily.len() as f64;
        let max_day = daily.iter().max_by_key(|(_, &c)| c).unwrap();
        println!("## 投递趋势\n");
        println!("> 日均投递：{:.1} 封，最高峰：{}（{} 封）\n", avg, max_day.0, max_day.1);

        println!("| 日期 | 投递数 | 趋势 |");
        println!("|------|--------|------|");
        let mut prev_count: Option<usize> = None;
        for (d, count) in &daily {
            let arrow = match prev_count {
                Some(prev) if *count > prev => "↑",
                Some(prev) if *count < prev => "↓",
                _ => "-",
            };
            println!("| {} | {} | {} |", d, count, arrow);
            prev_count = Some(*count);
        }
        println!();
    }

    // Unidentified samples
    if !unnamed_subjects.is_empty() {
        println!("## 未识别邮件样本（前{}条）\n", unnamed_subjects.len().min(10));
        println!("建议根据以下样本调整分类规则：\n");
        for subj in unnamed_subjects.iter().take(10) {
            let display = if subj.is_empty() { "【空主题】" } else { subj };
            println!("- {}", display);
        }
        println!();
    }
}

pub fn run(args: &StatusArgs) -> Result<()> {
    let config = config::load_config();
    let rules = &config.rules;

    let msgs = fetch_all_mailbox()?;

    let (start, end) = resolve_date_range(args);
    let filtered = filter_by_date(&msgs, start, end);

    let title = build_title(start, end, args.days);
    print_report(&filtered, rules, &title);

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_date_iso8601() {
        let d = extract_date("2026-06-15T10:30:00+08:00");
        assert!(d.is_some());
        assert_eq!(d.unwrap().to_string(), "2026-06-15");
    }

    #[test]
    fn test_extract_date_ymd() {
        let d = extract_date("2026-06-15");
        assert!(d.is_some());
        assert_eq!(d.unwrap().to_string(), "2026-06-15");
    }

    #[test]
    fn test_extract_date_empty() {
        assert!(extract_date("").is_none());
    }

    #[test]
    fn test_extract_date_regex_fallback() {
        let d = extract_date("some text 2026-06-15 more text");
        assert!(d.is_some());
        assert_eq!(d.unwrap().to_string(), "2026-06-15");
    }

    #[test]
    fn test_filter_by_date() {
        let msgs = vec![
            Message { subject: "a".into(), date: "2026-06-14".into() },
            Message { subject: "b".into(), date: "2026-06-15".into() },
            Message { subject: "c".into(), date: "2026-06-16".into() },
        ];
        let start = NaiveDate::from_ymd_opt(2026, 6, 15);
        let end = NaiveDate::from_ymd_opt(2026, 6, 15);
        let filtered = filter_by_date(&msgs, start, end);
        assert_eq!(filtered.len(), 1);
        assert_eq!(filtered[0].subject, "b");
    }

    #[test]
    fn test_filter_by_date_no_match() {
        let msgs = vec![
            Message { subject: "a".into(), date: "2026-06-14".into() },
        ];
        let start = NaiveDate::from_ymd_opt(2026, 6, 15);
        let end = NaiveDate::from_ymd_opt(2026, 6, 15);
        let filtered = filter_by_date(&msgs, start, end);
        assert!(filtered.is_empty());
    }

    #[test]
    fn test_resolve_date_range_default_this_month() {
        let args = StatusArgs { days: None, start: None, end: None };
        let (s, e) = resolve_date_range(&args);
        assert!(s.is_some());
        assert!(e.is_some());
        let now = chrono::Local::now().date_naive();
        assert_eq!(s.unwrap().month(), now.month());
        assert_eq!(s.unwrap().year(), now.year());
        assert_eq!(s.unwrap().day(), 1);
    }

    #[test]
    fn test_resolve_date_range_with_days() {
        let args = StatusArgs { days: Some(7), start: None, end: None };
        let (s, e) = resolve_date_range(&args);
        assert!(s.is_some());
        assert!(e.is_some());
        let diff = e.unwrap().signed_duration_since(s.unwrap()).num_days();
        assert_eq!(diff, 7);
    }

    #[test]
    fn test_resolve_date_range_explicit() {
        let args = StatusArgs {
            days: None,
            start: Some("2026-06-01".into()),
            end: Some("2026-06-16".into()),
        };
        let (s, e) = resolve_date_range(&args);
        assert_eq!(s.unwrap().to_string(), "2026-06-01");
        assert_eq!(e.unwrap().to_string(), "2026-06-16");
    }
}
