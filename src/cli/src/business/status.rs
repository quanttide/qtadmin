use anyhow::Result;

use super::{OrderItem, OrderStore, BusinessStatus};

pub const STAGES: &[&str] = &["商机", "报价", "谈判", "签约"];

pub fn default_orders() -> BusinessStatus {
    BusinessStatus {
        orders: vec![
            OrderItem { title: "客户群消息总结流程".into(), client: "秘书处".into(), stage: "报价".into(), amount: "50,000".into() },
            OrderItem { title: "Vibe Coding 入门培训".into(), client: "秘书处".into(), stage: "商机".into(), amount: "—".into() },
            OrderItem { title: "招聘系统".into(), client: "秘书处".into(), stage: "商机".into(), amount: "—".into() },
            OrderItem { title: "创始人日志精炼".into(), client: "秘书处".into(), stage: "商机".into(), amount: "—".into() },
        ],
    }
}

pub fn format_status(store: &dyn OrderStore) -> String {
    let status = store.load();
    let mut out = String::new();

    out.push_str("# 商务拓展\n\n");

    let stages_display = STAGES
        .iter()
        .map(|s| format!("`{s}`"))
        .collect::<Vec<_>>()
        .join(" → ");
    out.push_str(&format!("> 商务流程：{}\n\n", stages_display));

    out.push_str("| 订单 | 客户 | 阶段 | 金额 |\n");
    out.push_str("|------|------|------|------|\n");

    for o in &status.orders {
        let stage_idx = STAGES.iter().position(|s| s == &o.stage);
        let stage_bar = match stage_idx {
            Some(idx) => {
                let mut bar = String::new();
                for i in 0..STAGES.len() {
                    if i < idx {
                        bar.push_str("● ");
                    } else if i == idx {
                        bar.push_str("◉ ");
                    } else {
                        bar.push_str("○ ");
                    }
                }
                bar.push_str(o.stage.as_str());
                bar
            }
            None => o.stage.clone(),
        };
        out.push_str(&format!("| {} | {} | {} | {} |\n", o.title, o.client, stage_bar, o.amount));
    }

    out
}

#[derive(clap::Args)]
pub struct StatusArgs;

pub fn run(_args: &StatusArgs) -> Result<()> {
    let store = super::FileOrderStore;
    print!("{}", format_status(&store));
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    struct MockStore {
        status: BusinessStatus,
    }

    impl OrderStore for MockStore {
        fn load(&self) -> BusinessStatus {
            self.status.clone()
        }
    }

    #[test]
    fn test_format_status_contains_header() {
        let store = MockStore { status: default_orders() };
        let output = format_status(&store);
        assert!(output.contains("商务拓展"));
        assert!(output.contains("商务流程"));
    }

    #[test]
    fn test_format_status_contains_orders() {
        let store = MockStore { status: default_orders() };
        let output = format_status(&store);
        assert!(output.contains("客户群消息总结流程"));
        assert!(output.contains("Vibe Coding 入门培训"));
        assert!(output.contains("招聘系统"));
        assert!(output.contains("创始人日志精炼"));
    }

    #[test]
    fn test_format_status_stage_bar() {
        let store = MockStore { status: default_orders() };
        let output = format_status(&store);
        // 报价 is 2nd stage: ● ◉ ○ ○
        assert!(output.contains("● ◉ ○ ○"));
    }

    #[test]
    fn test_format_status_empty() {
        let store = MockStore {
            status: BusinessStatus { orders: vec![] },
        };
        let output = format_status(&store);
        assert!(output.contains("商务拓展"));
    }
}
