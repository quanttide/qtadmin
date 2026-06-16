use anyhow::Result;

use crate::project;
use crate::project::PlanStore;

const CATEGORY: &str = "量潮数据";

pub fn format_status() -> String {
    let store = project::FilePlanStore;
    let status = store.load();
    let mut out = String::new();

    out.push_str(&format!("# {}\n\n", CATEGORY));

    let filtered: Vec<_> = status.projects.iter().filter(|p| p.category == CATEGORY).collect();
    if filtered.is_empty() {
        out.push_str("暂无项目\n");
        return out;
    }

    out.push_str("| 项目 | 客户 | 当前阶段 | 目标 |\n");
    out.push_str("|------|------|----------|------|\n");

    for p in &filtered {
        let stage_idx = project::status::STAGES.iter().position(|s| s == &p.stage);
        let stage_bar = match stage_idx {
            Some(idx) => {
                let mut bar = String::new();
                for i in 0..project::status::STAGES.len() {
                    if i < idx { bar.push_str("● "); }
                    else if i == idx { bar.push_str("◉ "); }
                    else { bar.push_str("○ "); }
                }
                bar.push_str(p.stage.as_str());
                bar
            }
            None => p.stage.clone(),
        };
        out.push_str(&format!("| {} | {} | {} | {} |\n", p.title, p.client, stage_bar, p.description));
    }

    out
}

#[derive(clap::Args)]
pub struct StatusArgs;

pub fn run(_args: &StatusArgs) -> Result<()> {
    print!("{}", format_status());
    Ok(())
}
