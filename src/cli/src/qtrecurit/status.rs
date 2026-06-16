use anyhow::Result;
use chrono::NaiveDate;
use chrono::Datelike;

use super::connect;
use super::human;
use super::config;

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

    let now = chrono::Local::now().date_naive();
    let start = NaiveDate::from_ymd_opt(now.year(), now.month(), 1).unwrap_or(now);
    (Some(start), Some(now))
}

pub fn run(args: &StatusArgs) -> Result<()> {
    let cfg = config::load_config();

    let msgs = connect::fetch_all_mailbox()?;

    let (start, end) = resolve_date_range(args);
    let filtered = human::filter_by_date(&msgs, start, end);

    let title = human::build_title(start, end, args.days);
    human::print_report(&filtered, &cfg.rules, &title);

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_resolve_date_range_default_this_month() {
        let args = StatusArgs {
            days: None,
            start: None,
            end: None,
        };
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
        let args = StatusArgs {
            days: Some(7),
            start: None,
            end: None,
        };
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
