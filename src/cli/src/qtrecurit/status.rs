use anyhow::Result;
use chrono::Datelike;

use crate::connect;
use crate::connect::email;
use crate::human;

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

fn resolve_date_range(args: &StatusArgs) -> (Option<chrono::NaiveDate>, Option<chrono::NaiveDate>) {
    if let (Some(start), Some(end)) = (&args.start, &args.end) {
        let s = chrono::NaiveDate::parse_from_str(start, "%Y-%m-%d").ok();
        let e = chrono::NaiveDate::parse_from_str(end, "%Y-%m-%d").ok();
        return (s, e);
    }

    if let Some(days) = args.days {
        let end = chrono::Local::now().date_naive();
        let start = end - chrono::Duration::days(days as i64);
        return (Some(start), Some(end));
    }

    let now = chrono::Local::now().date_naive();
    let start = chrono::NaiveDate::from_ymd_opt(now.year(), now.month(), 1).unwrap_or(now);
    (Some(start), Some(now))
}

pub fn format_status(fetcher: &dyn connect::EmailFetcher, args: &StatusArgs) -> Result<String> {
    let cfg = human::config::load_config();
    let msgs = fetcher.fetch_all()?;

    let items: Vec<human::report::MailItem> = msgs
        .into_iter()
        .map(|m| human::report::MailItem {
            subject: m.subject,
            date: m.date,
        })
        .collect();

    let (start, end) = resolve_date_range(args);
    let filtered = human::report::filter_by_date(&items, start, end);

    let title = human::report::build_title(start, end, args.days);
    Ok(human::report::format_report(&filtered, &cfg.rules, &title))
}

pub fn run(args: &StatusArgs) -> Result<()> {
    let fetcher = email::lark::LarkCliFetcher;
    print!("{}", format_status(&fetcher, args)?);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::connect::Message;

    struct MockFetcher {
        messages: Vec<Message>,
    }

    impl connect::EmailFetcher for MockFetcher {
        fn fetch_all(&self) -> Result<Vec<Message>> {
            Ok(self.messages.clone())
        }
    }

    #[test]
    fn test_format_status_with_data() {
        let fetcher = MockFetcher {
            messages: vec![
                Message { subject: "应聘全栈工程师".into(), date: "2026-06-15".into() },
                Message { subject: "自动回复".into(), date: "2026-06-16".into() },
            ],
        };
        let args = StatusArgs { days: None, start: None, end: None };
        let output = format_status(&fetcher, &args).unwrap();
        assert!(output.contains("2 封投递。"));
        assert!(output.contains("全栈工程师"));
        assert!(output.contains("未识别邮件样本"));
        assert!(output.contains("自动回复"));
    }

    #[test]
    fn test_format_status_empty() {
        let fetcher = MockFetcher { messages: vec![] };
        let args = StatusArgs { days: None, start: None, end: None };
        let output = format_status(&fetcher, &args).unwrap();
        assert!(output.contains("0 封投递。"));
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
