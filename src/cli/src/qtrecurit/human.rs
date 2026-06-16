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

use super::connect::Message;

pub fn filter_by_date<'a>(
    msgs: &'a [Message],
    start: Option<NaiveDate>,
    end: Option<NaiveDate>,
) -> Vec<&'a Message> {
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

pub fn print_report(msgs: &[&Message], rules: &[config::PositionRule], title: &str) {
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

    println!("## 岗位分布\n");
    println!("| 岗位 | 人数 |");
    println!("|------|------|");
    let mut sorted: Vec<_> = positions.into_iter().collect();
    sorted.sort_by(|a, b| b.1.cmp(&a.1));
    for (pos, count) in &sorted {
        println!("| {} | {} |", pos, count);
    }
    println!();

    if !daily.is_empty() {
        let avg = daily.values().sum::<usize>() as f64 / daily.len() as f64;
        let max_day = daily.iter().max_by_key(|(_, &c)| c).unwrap();
        println!("## 投递趋势\n");
        println!(
            "> 日均投递：{:.1} 封，最高峰：{}（{} 封）\n",
            avg, max_day.0, max_day.1
        );

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

    if !unnamed_subjects.is_empty() {
        println!(
            "## 未识别邮件样本（前{}条）\n",
            unnamed_subjects.len().min(10)
        );
        println!("建议根据以下样本调整分类规则：\n");
        for subj in unnamed_subjects.iter().take(10) {
            let display = if subj.is_empty() { "【空主题】" } else { subj };
            println!("- {}", display);
        }
        println!();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::qtrecurit::connect::Message;

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
            Message {
                subject: "a".into(),
                date: "2026-06-14".into(),
            },
            Message {
                subject: "b".into(),
                date: "2026-06-15".into(),
            },
            Message {
                subject: "c".into(),
                date: "2026-06-16".into(),
            },
        ];
        let start = NaiveDate::from_ymd_opt(2026, 6, 15);
        let end = NaiveDate::from_ymd_opt(2026, 6, 15);
        let filtered = filter_by_date(&msgs, start, end);
        assert_eq!(filtered.len(), 1);
        assert_eq!(filtered[0].subject, "b");
    }

    #[test]
    fn test_filter_by_date_no_match() {
        let msgs = vec![Message {
            subject: "a".into(),
            date: "2026-06-14".into(),
        }];
        let start = NaiveDate::from_ymd_opt(2026, 6, 15);
        let end = NaiveDate::from_ymd_opt(2026, 6, 15);
        let filtered = filter_by_date(&msgs, start, end);
        assert!(filtered.is_empty());
    }
}
