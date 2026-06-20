use clap::{Args, Subcommand};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
struct PositionRecord {
    id: String,
    name: String,
    department: Option<String>,
    level: Option<String>,
    description: Option<String>,
    responsibilities: Option<String>,
    requirements: Option<String>,
    active: bool,
}

#[derive(Debug, Serialize, Deserialize)]
struct PositionsFile {
    records: HashMap<String, PositionRecord>,
}

#[derive(Args)]
pub struct PositionArgs {
    #[command(subcommand)]
    pub command: PositionCommands,
}

#[derive(Clone, Subcommand)]
pub enum PositionCommands {
    /// 列出岗位
    List {
        #[arg(long)]
        department: Option<String>,
        #[arg(long)]
        active: Option<bool>,
        #[arg(long)]
        search: Option<String>,
    },
    /// 查询单个岗位
    Get { id: String },
}

fn positions_path() -> PathBuf {
    crate::cli_config::profile_root()
        .join("human")
        .join("positions.json")
}

fn load_positions() -> Vec<PositionRecord> {
    let path = positions_path();
    let content = match std::fs::read_to_string(&path) {
        Ok(c) => c,
        Err(_) => return Vec::new(),
    };
    let file: PositionsFile = match serde_json::from_str(&content) {
        Ok(f) => f,
        Err(_) => return Vec::new(),
    };
    let mut list: Vec<PositionRecord> = file.records.into_values().collect();
    list.sort_by(|a, b| a.name.cmp(&b.name));
    list
}

pub fn dispatch(args: &PositionArgs, _provider: bool) {
    match &args.command {
        PositionCommands::List {
            department,
            active,
            search,
        } => {
            let all = load_positions();
            let filtered: Vec<&PositionRecord> = all
                .iter()
                .filter(|p| {
                    if let Some(d) = department {
                        if p.department.as_deref() != Some(d) {
                            return false;
                        }
                    }
                    if let Some(a) = active {
                        if p.active != *a {
                            return false;
                        }
                    }
                    if let Some(q) = search {
                        let q = q.to_lowercase();
                        if !p.name.to_lowercase().contains(&q)
                            && !p
                                .department
                                .as_deref()
                                .unwrap_or("")
                                .to_lowercase()
                                .contains(&q)
                        {
                            return false;
                        }
                    }
                    true
                })
                .collect();
            println!("{}", serde_json::to_string_pretty(&filtered).unwrap());
        }
        PositionCommands::Get { id } => {
            let all = load_positions();
            match all.iter().find(|p| p.id == *id) {
                Some(p) => println!("{}", serde_json::to_string_pretty(p).unwrap()),
                None => eprintln!("未找到 id={} 的岗位", id),
            }
        }
    }
}
