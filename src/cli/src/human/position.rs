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

#[cfg(test)]
mod tests {
    use super::*;
    use std::env;
    use tempfile::TempDir;

    /// Helper: save an env var, set it to `val`, and restore the old value on drop.
    struct EnvGuard {
        key: String,
        prev: Option<String>,
    }

    impl Drop for EnvGuard {
        fn drop(&mut self) {
            match &self.prev {
                Some(v) => env::set_var(&self.key, v),
                None => env::remove_var(&self.key),
            }
        }
    }

    fn set_env_var_guard(key: &str, val: &str) -> EnvGuard {
        let prev = env::var(key).ok();
        env::set_var(key, val);
        EnvGuard {
            key: key.to_owned(),
            prev,
        }
    }

    #[test]
    fn test_load_positions_file_not_found() {
        let dir = TempDir::new().unwrap();
        let _guard =
            set_env_var_guard(crate::cli_config::ENV_PROFILE, dir.path().to_str().unwrap());
        let positions = load_positions();
        assert!(positions.is_empty());
    }

    #[test]
    fn test_load_positions_valid_json() {
        let dir = TempDir::new().unwrap();
        let human_dir = dir.path().join("human");
        std::fs::create_dir(&human_dir).unwrap();
        let file_path = human_dir.join("positions.json");
        let data = r#"{
            "records": {
                "p1": { "id": "p1", "name": "后端工程师", "department": "技术部", "active": true },
                "p2": { "id": "p2", "name": "前端工程师", "department": "技术部", "active": false }
            }
        }"#;
        std::fs::write(&file_path, data).unwrap();

        let _guard =
            set_env_var_guard(crate::cli_config::ENV_PROFILE, dir.path().to_str().unwrap());
        let positions = load_positions();
        assert_eq!(positions.len(), 2);
        // Should be sorted by name (UTF-8 byte order)
        assert_eq!(positions[0].name, "前端工程师");
        assert_eq!(positions[1].name, "后端工程师");
    }

    #[test]
    fn test_load_positions_filters_and_sorting() {
        let dir = TempDir::new().unwrap();
        let human_dir = dir.path().join("human");
        std::fs::create_dir(&human_dir).unwrap();
        let file_path = human_dir.join("positions.json");
        let data = r#"{
            "records": {
                "p3": { "id": "p3", "name": "产品经理", "department": "产品部", "active": true },
                "p1": { "id": "p1", "name": "架构师", "department": "技术部", "active": true },
                "p2": { "id": "p2", "name": "设计师", "department": "设计部", "active": false }
            }
        }"#;
        std::fs::write(&file_path, data).unwrap();

        let _guard =
            set_env_var_guard(crate::cli_config::ENV_PROFILE, dir.path().to_str().unwrap());
        let positions = load_positions();
        assert_eq!(positions.len(), 3);

        // Sorted by name ascending (UTF-8 byte order)
        assert_eq!(positions[0].name, "产品经理");
        assert_eq!(positions[1].name, "架构师");
        assert_eq!(positions[2].name, "设计师");

        // Filter by active
        let active_only: Vec<&PositionRecord> = positions.iter().filter(|p| p.active).collect();
        assert_eq!(active_only.len(), 2);

        // Filter by department
        let tech: Vec<&PositionRecord> = positions
            .iter()
            .filter(|p| p.department.as_deref() == Some("技术部"))
            .collect();
        assert_eq!(tech.len(), 1);
        assert_eq!(tech[0].name, "架构师");
    }
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
