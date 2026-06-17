use anyhow::Result;

use super::quotation::{PersonnelLevel, Quotation, ServiceItem};

#[derive(clap::Args)]
pub struct QuoteArgs {
    /// 服务时长（小时）
    #[arg(long, default_value = "8")]
    pub hours: f64,

    /// 人员等级：chief / advanced
    #[arg(long, default_value = "advanced")]
    pub level: String,

    /// 溢价率（0-50，百分比整数）
    #[arg(long, default_value = "0")]
    pub premium: u32,
}

fn level_from_str(s: &str) -> Option<PersonnelLevel> {
    match s {
        "chief" => Some(PersonnelLevel::Chief),
        "advanced" => Some(PersonnelLevel::Advanced),
        _ => None,
    }
}

fn level_label(level: PersonnelLevel) -> &'static str {
    match level {
        PersonnelLevel::Chief => "首席",
        PersonnelLevel::Advanced => "高级",
        _ => "未知",
    }
}

fn approval_label(t: super::quotation::ApprovalType) -> &'static str {
    use super::quotation::ApprovalType;
    match t {
        ApprovalType::Major => "重大报价（管理层审批）",
        ApprovalType::Discount => "让利报价（管理层审批）",
        ApprovalType::Standard => "标准报价（业务线负责人审批）",
    }
}

fn format_quotation(q: &Quotation) -> String {
    let s = q.summary();
    format!(
        r#"## 报价单

| 项目 | 值 |
|------|-----|
| 人员等级 | {level} |
| 服务时长 | {hours} 小时 |
| 单价 | {rate} 元/小时 |
| 基础总价 | {base} 元 |
| 溢价率 | {premium_rate}% |
| 溢价金额 | {premium_amt} 元 |
| 折扣率 | {discount_rate}% |
| 折后总价 | {total} 元 |
| 审批类型 | {approval} |
"#,
        level = level_label(q.items.first().map(|i| i.level).unwrap_or(PersonnelLevel::Advanced)),
        hours = s.total_hours,
        rate = s.base_total / s.total_hours,
        base = s.base_total,
        premium_rate = (s.premium_rate * 100.0) as u32,
        premium_amt = s.premium_amount,
        discount_rate = (s.discount_rate * 100.0) as u32,
        total = s.total,
        approval = approval_label(s.approval_type),
    )
}

pub fn run(args: &QuoteArgs) -> Result<()> {
    let level = match level_from_str(&args.level) {
        Some(l) => l,
        None => {
            eprintln!("错误: 不支持的人员等级 '{}'，支持 chief/advanced", args.level);
            return Ok(());
        }
    };

    if args.premium > 50 {
        eprintln!("错误: 溢价率不能超过 50%");
        return Ok(());
    }

    let q = Quotation {
        items: vec![ServiceItem { name: "服务", hours: args.hours, level }],
        premium_rate: args.premium as f64 / 100.0,
    };

    print!("{}", format_quotation(&q));
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use super::super::quotation::PersonnelLevel;

    #[test]
    fn test_format_standard() {
        let q = Quotation {
            items: vec![ServiceItem { name: "咨询", hours: 8.0, level: PersonnelLevel::Advanced }],
            premium_rate: 0.0,
        };
        let out = format_quotation(&q);
        assert!(out.contains("8000 元"));
        assert!(out.contains("标准报价"));
    }

    #[test]
    fn test_format_with_premium() {
        let q = Quotation {
            items: vec![ServiceItem { name: "内训", hours: 36.0, level: PersonnelLevel::Chief }],
            premium_rate: 0.30,
        };
        let out = format_quotation(&q);
        assert!(out.contains("72000 元"));
        assert!(out.contains("重大报价"));
    }

    #[test]
    fn test_format_with_discount() {
        let q = Quotation {
            items: vec![ServiceItem { name: "咨询", hours: 10.0, level: PersonnelLevel::Advanced }],
            premium_rate: 0.0,
        };
        let out = format_quotation(&q);
        assert!(out.contains("9000 元"));
        assert!(out.contains("| 折扣率 | 10% |"));
    }
}
