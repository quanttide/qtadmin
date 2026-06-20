use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RecruitmentPlan {
    pub month: String,
    pub positions: Vec<PositionPlan>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PositionPlan {
    pub name: String,
    pub headcount: u32,
    pub filled: u32,
    pub in_progress: u32,
    pub note: String,
}

fn default_plan() -> RecruitmentPlan {
    RecruitmentPlan {
        month: "2026-06".into(),
        positions: vec![
            PositionPlan { name: "数据工程师".into(), headcount: 2, filled: 0, in_progress: 0, note: "".into() },
            PositionPlan { name: "项目经理".into(), headcount: 1, filled: 0, in_progress: 0, note: "".into() },
            PositionPlan { name: "销售经理".into(), headcount: 1, filled: 0, in_progress: 0, note: "".into() },
            PositionPlan { name: "新媒体运营".into(), headcount: 1, filled: 0, in_progress: 0, note: "".into() },
            PositionPlan { name: "课程助教".into(), headcount: 1, filled: 0, in_progress: 0, note: "".into() },
            PositionPlan { name: "咨询助理".into(), headcount: 1, filled: 0, in_progress: 0, note: "".into() },
            PositionPlan { name: "商务经理".into(), headcount: 1, filled: 0, in_progress: 0, note: "".into() },
            PositionPlan { name: "执行助理".into(), headcount: 2, filled: 0, in_progress: 0, note: "".into() },
        ],
    }
}

pub trait PlanStore {
    fn load(&self) -> RecruitmentPlan;
}

pub struct FilePlanStore;

impl PlanStore for FilePlanStore {
    fn load(&self) -> RecruitmentPlan {
        let path = plan_path();
        if let Ok(content) = std::fs::read_to_string(&path) {
            if let Ok(plan) = serde_json::from_str(&content) {
                return plan;
            }
        }
        default_plan()
    }
}

fn plan_path() -> PathBuf {
    if let Ok(dir) = std::env::var("QTRECURIT_DATA") {
        let p = PathBuf::from(dir);
        return p.join("recruitment_plan.json");
    }
    if let Ok(dir) = std::env::var("QTRECURIT_CONFIG") {
        let p = PathBuf::from(dir);
        if let Some(parent) = p.parent() {
            return parent.join("recruitment_plan.json");
        }
    }
    if let Some(data_dir) = dirs::data_dir() {
        return data_dir.join("qtadmin").join("recruitment_plan.json");
    }
    if let Ok(cwd) = std::env::current_dir() {
        return cwd.join("recruitment_plan.json");
    }
    PathBuf::from("recruitment_plan.json")
}

pub fn format_status(store: &dyn PlanStore) -> String {
    let plan = store.load();
    let mut out = String::new();

    out.push_str(&format!("# {} 招聘计划与进度\n\n", plan.month));
    out.push_str("| 岗位 | 编制 | 已入职 | 进行中 | 备注 |\n");
    out.push_str("|------|------|--------|--------|------|\n");

    let mut total_headcount = 0u32;
    let mut total_filled = 0u32;
    let mut total_in_progress = 0u32;

    for p in &plan.positions {
        total_headcount += p.headcount;
        total_filled += p.filled;
        total_in_progress += p.in_progress;
        out.push_str(&format!("| {} | {} | {} | {} | {} |\n", p.name, p.headcount, p.filled, p.in_progress, p.note));
    }

    out.push('\n');
    out.push_str(&format!(
        "> 编制 {} 人 · 已入职 {} 人 · 进行中 {} 人 · 空缺 {} 人\n",
        total_headcount, total_filled, total_in_progress, total_headcount - total_filled
    ));
    out.push_str("> 截至 6 月 16 日\n");

    out
}

#[derive(clap::Args)]
pub struct StatusArgs;

pub fn run(_args: &StatusArgs, _provider: bool) -> Result<()> {
    let store = FilePlanStore;
    print!("{}", format_status(&store));
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    struct MockPlanStore {
        plan: RecruitmentPlan,
    }

    impl PlanStore for MockPlanStore {
        fn load(&self) -> RecruitmentPlan {
            self.plan.clone()
        }
    }

    #[test]
    fn test_format_status_contains_title() {
        let store = MockPlanStore { plan: default_plan() };
        let output = format_status(&store);
        assert!(output.contains("2026-06 招聘计划与进度"));
        assert!(output.contains("数据工程师"));
        assert!(output.contains("执行助理"));
    }

    #[test]
    fn test_format_status_totals() {
        let store = MockPlanStore { plan: default_plan() };
        let output = format_status(&store);
        assert!(output.contains("编制 10 人"));
        assert!(output.contains("空缺 10 人"));
    }

    #[test]
    fn test_format_status_with_partial_filled() {
        let plan = RecruitmentPlan {
            month: "2026-06".into(),
            positions: vec![
                PositionPlan { name: "数据工程师".into(), headcount: 2, filled: 1, in_progress: 1, note: "试用期".into() },
            ],
        };
        let store = MockPlanStore { plan };
        let output = format_status(&store);
        assert!(output.contains("数据工程师 | 2 | 1 | 1 | 试用期"));
        assert!(output.contains("编制 2 人 · 已入职 1 人 · 进行中 1 人 · 空缺 1 人"));
    }

    #[test]
    fn test_default_plan_not_empty() {
        let plan = default_plan();
        assert_eq!(plan.month, "2026-06");
        assert_eq!(plan.positions.len(), 8);
    }

    #[test]
    fn test_format_status_with_filled() {
        let plan = RecruitmentPlan {
            month: "2026-06".into(),
            positions: vec![
                PositionPlan { name: "数据工程师".into(), headcount: 2, filled: 1, in_progress: 1, note: "试用期".into() },
            ],
        };
        let store = MockPlanStore { plan };
        let output = format_status(&store);
        assert!(output.contains("1 | 1 | 试用期"));
        assert!(output.contains("编制 2 人 · 已入职 1 人"));
    }

    #[test]
    fn test_format_status_empty_positions() {
        let plan = RecruitmentPlan {
            month: "2026-06".into(),
            positions: vec![],
        };
        let store = MockPlanStore { plan };
        let output = format_status(&store);
        assert!(output.contains("编制 0 人"));
    }

    #[test]
    fn test_format_status_with_multiple_notes() {
        let plan = RecruitmentPlan {
            month: "2026-06".into(),
            positions: vec![
                PositionPlan { name: "全栈工程师".into(), headcount: 1, filled: 0, in_progress: 0, note: "急招".into() },
                PositionPlan { name: "数据工程师".into(), headcount: 2, filled: 2, in_progress: 0, note: "已满".into() },
            ],
        };
        let store = MockPlanStore { plan };
        let output = format_status(&store);
        assert!(output.contains("全栈工程师 | 1 | 0 | 0 | 急招"));
        assert!(output.contains("数据工程师 | 2 | 2 | 0 | 已满"));
    }
}
