use std::collections::BTreeMap;

use chrono::NaiveDate;
use chrono::Datelike;

use super::config;

pub fn extract_date(date_str: &str) -> Option<NaiveDate> {
    if date_str.is_empty() {
        return None;
    }

    if let Ok(dt) = chrono::DateTime::parse_from_rfc3339(date_str) {
        return Some(dt.date_naive());
    }

    if let Ok(d) = NaiveDate::parse_from_str(date_str, "%Y-%m-%d") {
        return Some(d);
    }

    let re = regex::Regex::new(r"(\d{4}-\d{2}-\d{2})").ok()?;
    let cap = re.find(date_str)?;
    NaiveDate::parse_from_str(cap.as_str(), "%Y-%m-%d").ok()
}

pub struct MailItem {
    pub subject: String,
    pub date: String,
}

pub fn filter_by_date<'a>(
    items: &'a [MailItem],
    start: Option<NaiveDate>,
    end: Option<NaiveDate>,
) -> Vec<&'a MailItem> {
    items
        .iter()
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

pub fn build_title(start: Option<NaiveDate>, end: Option<NaiveDate>, days: Option<u32>) -> String {
    match (start, end, days) {
        (Some(s), Some(e), None) => {
            format!(
                "量潮招聘数据统计 ({}/{} 至 {}/{})",
                s.month(),
                s.day(),
                e.month(),
                e.day()
            )
        }
        (Some(s), None, None) => format!("量潮招聘数据统计 ({} 起)", s),
        (_, _, Some(d)) => format!("量潮招聘数据统计 (最近 {} 天)", d),
        _ => "量潮招聘数据统计".to_string(),
    }
}

pub fn format_report(
    items: &[&MailItem],
    rules: &[config::PositionRule],
    title: &str,
) -> String {
    let total = items.len();
    let mut positions: BTreeMap<&str, usize> = BTreeMap::new();
    let mut unnamed_subjects: Vec<&str> = Vec::new();
    let mut daily: BTreeMap<String, usize> = BTreeMap::new();

    for m in items {
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

    let mut out = String::new();

    let identified = total - unnamed_subjects.len();
    let identified_pct = if total > 0 {
        identified * 100 / total
    } else {
        0
    };

    out.push_str(&format!("# {}\n\n", title));
    out.push_str(&format!("{} 封投递。\n", total));
    if total > 0 {
        out.push_str(&format!(
            "其中可识别岗位 {} 封（{}%），其余为自动回复、空主题等。\n",
            identified, identified_pct
        ));
    }
    out.push('\n');

    out.push_str("## 岗位分布\n\n");
    out.push_str("| 岗位 | 人数 |\n");
    out.push_str("|------|------|\n");
    let mut sorted: Vec<_> = positions.into_iter().collect();
    sorted.sort_by(|a, b| b.1.cmp(&a.1));
    for (pos, count) in &sorted {
        out.push_str(&format!("| {} | {} |\n", pos, count));
    }
    out.push('\n');

    if !daily.is_empty() {
        let avg = daily.values().sum::<usize>() as f64 / daily.len() as f64;
        let max_day = daily.iter().max_by_key(|(_, &c)| c).unwrap();
        out.push_str("## 投递趋势\n\n");
        out.push_str(&format!(
            "> 日均投递：{:.1} 封，最高峰：{}（{} 封）\n\n",
            avg, max_day.0, max_day.1
        ));

        out.push_str("| 日期 | 投递数 | 趋势 |\n");
        out.push_str("|------|--------|------|\n");
        let mut prev_count: Option<usize> = None;
        for (d, count) in &daily {
            let arrow = match prev_count {
                Some(prev) if *count > prev => "↑",
                Some(prev) if *count < prev => "↓",
                _ => "-",
            };
            out.push_str(&format!("| {} | {} | {} |\n", d, count, arrow));
            prev_count = Some(*count);
        }
        out.push('\n');
    }

    if !unnamed_subjects.is_empty() {
        out.push_str(&format!(
            "## 未识别邮件样本（前{}条）\n\n",
            unnamed_subjects.len().min(10)
        ));
        out.push_str("建议根据以下样本调整分类规则：\n\n");
        for subj in unnamed_subjects.iter().take(10) {
            let display = if subj.is_empty() { "【空主题】" } else { subj };
            out.push_str(&format!("- {}\n", display));
        }
        out.push('\n');
    }

    out
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_rules() -> Vec<config::PositionRule> {
        config::load_config().rules
    }

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
        let items = vec![
            MailItem { subject: "a".into(), date: "2026-06-14".into() },
            MailItem { subject: "b".into(), date: "2026-06-15".into() },
            MailItem { subject: "c".into(), date: "2026-06-16".into() },
        ];
        let start = NaiveDate::from_ymd_opt(2026, 6, 15);
        let end = NaiveDate::from_ymd_opt(2026, 6, 15);
        let filtered = filter_by_date(&items, start, end);
        assert_eq!(filtered.len(), 1);
        assert_eq!(filtered[0].subject, "b");
    }

    #[test]
    fn test_filter_by_date_no_match() {
        let items = vec![MailItem { subject: "a".into(), date: "2026-06-14".into() }];
        let start = NaiveDate::from_ymd_opt(2026, 6, 15);
        let end = NaiveDate::from_ymd_opt(2026, 6, 15);
        let filtered = filter_by_date(&items, start, end);
        assert!(filtered.is_empty());
    }

    #[test]
    fn test_format_report_contains_title() {
        let rules = test_rules();
        let report = format_report(&[], &rules, "测试报告");
        assert!(report.contains("# 测试报告"));
        assert!(report.contains("0 封投递。"));
    }

    #[test]
    fn test_format_report_with_data() {
        use crate::human::config;
        let rules = config::load_config().rules;
        let items = vec![
            MailItem { subject: "应聘全栈工程师 - 张三".into(), date: "2026-06-15".into() },
            MailItem { subject: "【后端开发】李四".into(), date: "2026-06-16".into() },
        ];
        let refs: Vec<&MailItem> = items.iter().collect();
        let report = format_report(&refs, &rules, "测试报告");
        assert!(report.contains("2 封投递。"));
        assert!(report.contains("岗位分布"));
        assert!(report.contains("全栈工程师"));
        assert!(report.contains("投递趋势"));
        assert!(report.contains("2026-06-15"));
        assert!(report.contains("2026-06-16"));
    }

    #[test]
    fn test_format_report_unnamed_samples() {
        let rules = test_rules();
        let items = vec![
            MailItem { subject: "自动回复：感谢投递".into(), date: "2026-06-15".into() },
        ];
        let refs: Vec<&MailItem> = items.iter().collect();
        let report = format_report(&refs, &rules, "测试");
        assert!(report.contains("未识别邮件样本"));
        assert!(report.contains("自动回复：感谢投递"));
    }

    #[test]
    fn test_format_report_empty_subject() {
        let rules = test_rules();
        let items = vec![
            MailItem { subject: "".into(), date: "2026-06-15".into() },
        ];
        let refs: Vec<&MailItem> = items.iter().collect();
        let report = format_report(&refs, &rules, "测试");
        assert!(report.contains("【空主题】"));
    }
}
