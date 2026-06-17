#![allow(dead_code)]
use anyhow::Result;

// ── 报价模型 ──

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum PersonnelLevel {
    Chief,
    Senior,
    Advanced,
    Mid,
    Junior,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum ApprovalType {
    Standard,
    Major,
    Discount,
}

pub struct ServiceItem {
    pub name: &'static str,
    pub hours: f64,
    pub level: PersonnelLevel,
}

pub struct Quotation {
    pub items: Vec<ServiceItem>,
    pub premium_rate: f64,
}

const ENTERPRISE_RATES: [(PersonnelLevel, f64); 2] = [
    (PersonnelLevel::Chief, 2000.0),
    (PersonnelLevel::Advanced, 1000.0),
];

const DISCOUNT_RULES: [(f64, f64); 2] = [
    (20.0, 0.15),
    (10.0, 0.10),
];

pub struct Summary {
    pub total_hours: f64,
    pub base_total: f64,
    pub premium_rate: f64,
    pub premium_amount: f64,
    pub discount_rate: f64,
    pub discount_amount: f64,
    pub total: f64,
    pub approval_type: ApprovalType,
}

fn unit_price(level: PersonnelLevel) -> Option<f64> {
    ENTERPRISE_RATES.iter().find(|(l, _)| *l == level).map(|(_, p)| *p)
}

impl Quotation {
    pub fn total_hours(&self) -> f64 {
        self.items.iter().map(|i| i.hours).sum()
    }

    pub fn base_total(&self) -> Option<f64> {
        let mut total = 0.0;
        for item in &self.items {
            total += unit_price(item.level)? * item.hours;
        }
        Some(total)
    }

    pub fn premium_amount(&self) -> Option<f64> {
        Some(self.base_total()? * self.premium_rate)
    }

    pub fn discount_rate(&self) -> f64 {
        let hours = self.total_hours();
        for (threshold, rate) in DISCOUNT_RULES {
            if hours >= threshold {
                return rate;
            }
        }
        0.0
    }

    pub fn discount_amount(&self) -> Option<f64> {
        Some(self.base_total()? * self.discount_rate())
    }

    pub fn total(&self) -> Option<f64> {
        let base = self.base_total()?;
        Some((base + base * self.premium_rate) * (1.0 - self.discount_rate()))
    }

    pub fn approval_type(&self) -> ApprovalType {
        if self.premium_rate > 0.0 {
            return ApprovalType::Major;
        }
        if self.discount_rate() > 0.0 {
            return ApprovalType::Discount;
        }
        ApprovalType::Standard
    }

    pub fn summary(&self) -> Summary {
        Summary {
            total_hours: self.total_hours(),
            base_total: self.base_total().unwrap_or(0.0),
            premium_rate: self.premium_rate,
            premium_amount: self.premium_amount().unwrap_or(0.0),
            discount_rate: self.discount_rate(),
            discount_amount: self.discount_amount().unwrap_or(0.0),
            total: self.total().unwrap_or(0.0),
            approval_type: self.approval_type(),
        }
    }
}

// ── CLI 命令 ──

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

fn approval_label(t: ApprovalType) -> &'static str {
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

    #[test]
    fn test_tutorial_case() {
        let q = Quotation {
            items: vec![
                ServiceItem { name: "准备", hours: 16.0, level: PersonnelLevel::Chief },
                ServiceItem { name: "交付", hours: 16.0, level: PersonnelLevel::Chief },
                ServiceItem { name: "回访", hours: 4.0, level: PersonnelLevel::Chief },
            ],
            premium_rate: 0.30,
        };
        let s = q.summary();
        assert_eq!(s.total_hours, 36.0);
        assert_eq!(s.base_total, 72000.0);
        assert_eq!(s.premium_amount, 21600.0);
        assert_eq!(s.discount_rate, 0.15);
        assert_eq!(s.total, 79560.0);
        assert_eq!(s.approval_type as i32, ApprovalType::Major as i32);
    }

    #[test]
    fn test_standard_quotation() {
        let q = Quotation {
            items: vec![ServiceItem { name: "咨询", hours: 8.0, level: PersonnelLevel::Advanced }],
            premium_rate: 0.0,
        };
        let s = q.summary();
        assert_eq!(s.base_total, 8000.0);
        assert_eq!(s.discount_rate, 0.0);
        assert_eq!(s.total, 8000.0);
        assert_eq!(s.approval_type as i32, ApprovalType::Standard as i32);
    }

    #[test]
    fn test_discount_10h() {
        let q = Quotation {
            items: vec![ServiceItem { name: "咨询", hours: 10.0, level: PersonnelLevel::Advanced }],
            premium_rate: 0.0,
        };
        let s = q.summary();
        assert_eq!(s.discount_rate, 0.10);
        assert_eq!(s.total, 9000.0);
    }

    #[test]
    fn test_discount_20h() {
        let q = Quotation {
            items: vec![ServiceItem { name: "咨询", hours: 20.0, level: PersonnelLevel::Advanced }],
            premium_rate: 0.0,
        };
        let s = q.summary();
        assert_eq!(s.discount_rate, 0.15);
        assert_eq!(s.total, 17000.0);
    }

    #[test]
    fn test_mixed_levels() {
        let q = Quotation {
            items: vec![
                ServiceItem { name: "设计", hours: 4.0, level: PersonnelLevel::Chief },
                ServiceItem { name: "执行", hours: 16.0, level: PersonnelLevel::Advanced },
            ],
            premium_rate: 0.0,
        };
        let s = q.summary();
        assert_eq!(s.base_total, 24000.0);
        assert_eq!(s.discount_rate, 0.15);
    }

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
