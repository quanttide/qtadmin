pub mod status;

use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProjectStatus {
    pub projects: Vec<ProjectItem>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProjectItem {
    pub title: String,
    pub stage: String,
    pub client: String,
    pub category: String,
    pub description: String,
}

pub trait PlanStore {
    fn load(&self) -> ProjectStatus;
}

pub struct FilePlanStore;

impl PlanStore for FilePlanStore {
    fn load(&self) -> ProjectStatus {
        let path = plan_path();
        if let Ok(content) = std::fs::read_to_string(&path) {
            if let Ok(status) = serde_json::from_str(&content) {
                return status;
            }
        }
        status::default_status()
    }
}

fn plan_path() -> PathBuf {
    if let Ok(dir) = std::env::var("QTRECURIT_DATA") {
        let p = PathBuf::from(dir);
        return p.join("project_status.json");
    }
    if let Some(data_dir) = dirs::data_dir() {
        return data_dir.join("qtadmin").join("project_status.json");
    }
    if let Ok(cwd) = std::env::current_dir() {
        return cwd.join("project_status.json");
    }
    PathBuf::from("project_status.json")
}

use clap::Subcommand;

#[derive(Subcommand)]
pub enum ProjectCommands {
    /// 项目交付状态总览
    Status(status::StatusArgs),
}

#[derive(clap::Args)]
pub struct ProjectArgs {
    #[command(subcommand)]
    pub command: ProjectCommands,
}

pub fn dispatch(args: &ProjectArgs) {
    match &args.command {
        ProjectCommands::Status(status_args) => {
            if let Err(e) = status::run(status_args) {
                eprintln!("错误: {}", e);
            }
        }
    }
}
