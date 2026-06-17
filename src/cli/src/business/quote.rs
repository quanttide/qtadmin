use anyhow::Result;

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

const CHIEF_RATE: f64 = 2000.0;
const ADVANCED_RATE: f64 = 1000.0;

fn calc(hours: f64, rate: f64, premium_pct: u32) -> String {
    let base = hours * rate;
    let premium_rate = premium_pct as f64 / 100.0;
    let premium_amt = base * premium_rate;

    let discount_rate = if hours >= 20.0 { 0.15 } else if hours >= 10.0 { 0.10 } else { 0.0 };
    let total = (base + premium_amt) * (1.0 - discount_rate);

    let approval = if premium_pct > 0 { "重大报价（管理层审批）" } else if discount_rate > 0.0 { "让利报价" } else { "标准报价（业务线负责人审批）" };

    let level_label = if rate == CHIEF_RATE { "首席" } else { "高级" };

    format!(
        r#"## 报价单

| 项目 | 值 |
|------|-----|
| 人员等级 | {level_label} |
| 服务时长 | {hours} 小时 |
| 单价 | {rate} 元/小时 |
| 基础总价 | {base} 元 |
| 溢价率 | {premium_pct}% |
| 溢价金额 | {premium_amt} 元 |
| 折扣率 | {}% |
| 折后总价 | {total} 元 |
| 审批类型 | {approval} |
"#,
        (discount_rate * 100.0) as u32,
    )
}

pub fn run(args: &QuoteArgs) -> Result<()> {
    let rate = match args.level.as_str() {
        "chief" => CHIEF_RATE,
        "advanced" => ADVANCED_RATE,
        _ => {
            eprintln!("错误: 不支持的人员等级 '{}'，支持 chief/advanced", args.level);
            return Ok(());
        }
    };

    if args.premium > 50 {
        eprintln!("错误: 溢价率不能超过 50%");
        return Ok(());
    }

    print!("{}", calc(args.hours, rate, args.premium));
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calc_standard() {
        let out = calc(8.0, ADVANCED_RATE, 0);
        assert!(out.contains("8000 元"));
        assert!(out.contains("高级"));
        assert!(out.contains("标准报价"));
    }

    #[test]
    fn test_calc_with_premium() {
        let out = calc(36.0, CHIEF_RATE, 30);
        assert!(out.contains("72000 元"));
        assert!(out.contains("首席"));
        assert!(out.contains("重大报价"));
    }

    #[test]
    fn test_calc_with_discount() {
        let out = calc(10.0, ADVANCED_RATE, 0);
        assert!(out.contains("9000 元"));
        assert!(out.contains("| 折扣率 | 10% |"));
    }

    #[test]
    fn test_calc_with_both() {
        let out = calc(36.0, CHIEF_RATE, 30);
        assert!(out.contains("79560 元"));
        assert!(out.contains("| 折扣率 | 15% |"));
    }
}
