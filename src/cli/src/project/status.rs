use anyhow::Result;

use super::{PlanStore, ProjectItem, ProjectStatus};

pub const STAGES: &[&str] = &["调研", "谈判", "执行", "交付", "复盘"];

pub fn default_status() -> ProjectStatus {
    ProjectStatus {
        projects: vec![
            ProjectItem { title: "客户群消息总结流程".into(), stage: "调研".into(), client: "秘书处".into(), category: "量潮咨询".into(), description: "使用 wecom-cli 制作客户群消息总结".into() },
            ProjectItem { title: "秘书处 Vibe Coding 入门培训".into(), stage: "调研".into(), client: "秘书处".into(), category: "量潮课堂".into(), description: "4人入门培训".into() },
            ProjectItem { title: "招聘系统".into(), stage: "调研".into(), client: "秘书处".into(), category: "量潮云".into(), description: "内部招聘管理系统".into() },
            ProjectItem { title: "创始人日志精炼".into(), stage: "调研".into(), client: "秘书处".into(), category: "量潮数据".into(), description: "精炼创始人日志形成认知工程数据".into() },
        ],
    }
}

pub fn format_status(store: &dyn PlanStore) -> String {
    let status = store.load();
    let mut out = String::new();

    out.push_str("# 项目交付状态\n\n");

    let stages_display = STAGES
        .iter()
        .map(|s| format!("`{s}`"))
        .collect::<Vec<_>>()
        .join(" → ");
    out.push_str(&format!("> 五阶段流程：{}\n\n", stages_display));

    out.push_str("| 项目 | 客户 | 类别 | 当前阶段 | 目标 |\n");
    out.push_str("|------|------|------|----------|------|\n");

    for p in &status.projects {
        let stage_idx = STAGES.iter().position(|s| s == &p.stage);
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
                bar.push_str(p.stage.as_str());
                bar
            }
            None => p.stage.clone(),
        };
        out.push_str(&format!("| {} | {} | {} | {} | {} |\n", p.title, p.client, p.category, stage_bar, p.description));
    }

    out
}

#[derive(clap::Args)]
pub struct StatusArgs;

pub fn run(_args: &StatusArgs) -> Result<()> {
    let store = super::FilePlanStore;
    print!("{}", format_status(&store));
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    struct MockStore {
        status: ProjectStatus,
    }

    impl PlanStore for MockStore {
        fn load(&self) -> ProjectStatus {
            self.status.clone()
        }
    }

    #[test]
    fn test_format_status_contains_header() {
        let store = MockStore { status: default_status() };
        let output = format_status(&store);
        assert!(output.contains("项目交付状态"));
        assert!(output.contains("五阶段流程"));
    }

    #[test]
    fn test_format_status_contains_projects() {
        let store = MockStore { status: default_status() };
        let output = format_status(&store);
        assert!(output.contains("客户群消息总结流程"));
        assert!(output.contains("秘书处 Vibe Coding 入门培训"));
    }

    #[test]
    fn test_format_status_stage_bar() {
        let store = MockStore { status: default_status() };
        let output = format_status(&store);

        // 调研 stage: ◉ ○ ○ ○ ○
        assert!(output.contains("◉ ○ ○ ○ ○"));
        assert!(output.contains("调研"));
    }

    #[test]
    fn test_format_status_empty() {
        let store = MockStore {
            status: ProjectStatus { projects: vec![] },
        };
        let output = format_status(&store);
        assert!(output.contains("项目交付状态"));
    }
}
