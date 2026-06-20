use crate::provider::{ProviderClient, self};
use clap::{Args, Subcommand};
use serde::{Deserialize, Serialize};
use sqlx::sqlite::SqlitePoolOptions;
use sqlx::FromRow;

#[derive(FromRow, Serialize, Deserialize)]
struct Position {
    id: i64,
    name: String,
    department: Option<String>,
    level: Option<String>,
    description: Option<String>,
    responsibilities: Option<String>,
    requirements: Option<String>,
    active: bool,
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
        #[arg(long, default_value = "100")]
        limit: i64,
        #[arg(long, default_value = "0")]
        skip: i64,
    },
    /// 查询单个岗位
    Get { id: String },
    /// 创建岗位
    Create {
        #[arg(long)]
        name: String,
        #[arg(long)]
        department: Option<String>,
        #[arg(long)]
        level: Option<String>,
        #[arg(long)]
        description: Option<String>,
        #[arg(long)]
        responsibilities: Option<String>,
        #[arg(long)]
        requirements: Option<String>,
    },
    /// 更新岗位
    Update {
        id: String,
        #[arg(long)]
        name: Option<String>,
        #[arg(long)]
        department: Option<String>,
        #[arg(long)]
        level: Option<String>,
        #[arg(long)]
        description: Option<String>,
        #[arg(long)]
        responsibilities: Option<String>,
        #[arg(long)]
        requirements: Option<String>,
        #[arg(long)]
        active: Option<bool>,
    },
    /// 删除岗位
    Delete { id: String },
}

async fn init_db(pool: &sqlx::SqlitePool) {
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS org_positions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            department TEXT,
            level TEXT,
            description TEXT,
            responsibilities TEXT,
            requirements TEXT,
            active INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
        "#,
    )
    .execute(pool)
    .await
    .unwrap();
}

async fn run(args: PositionCommands) {
    let pool = SqlitePoolOptions::new()
        .connect("sqlite:qtcloud-org.db?mode=rwc")
        .await
        .expect("无法连接数据库");
    init_db(&pool).await;

    match args {
        PositionCommands::List { department, active, search, limit, skip } => {
            let mut bind_idx = 1;
            let search = search.map(|q| { let param = format!("%{}%", q); bind_idx += 1; param });
            if department.is_some() { bind_idx += 1; }
            if active.is_some() { bind_idx += 1; }

            let limit_sql = bind_idx;
            let skip_sql = bind_idx + 1;

            let mut query_str = "SELECT * FROM org_positions".to_string();
            let mut conditions = Vec::new();
            if search.is_some() { conditions.push("(name LIKE ?1 OR department LIKE ?1)".to_string()); }
            if department.is_some() { conditions.push(format!("department = ?2")); }
            if active.is_some() { conditions.push(format!("active = ?3")); }
            if !conditions.is_empty() { query_str.push_str(&format!(" WHERE {}", conditions.join(" AND "))); }
            query_str.push_str(&format!(" ORDER BY name LIMIT ?{} OFFSET ?{}", limit_sql, skip_sql));

            let mut query = sqlx::query_as::<_, Position>(&query_str);
            if let Some(ref q) = search { query = query.bind(q); }
            if let Some(ref dept) = department { query = query.bind(dept); }
            if let Some(a) = active { query = query.bind(a); }

            let positions = query.bind(limit).bind(skip).fetch_all(&pool).await.unwrap();
            println!("{}", serde_json::to_string_pretty(&positions).unwrap());
        }
        PositionCommands::Get { id } => {
            let id: i64 = id.parse().expect("ID 格式错误");
            match sqlx::query_as::<_, Position>("SELECT * FROM org_positions WHERE id = ?1")
                .bind(id).fetch_optional(&pool).await.unwrap()
            {
                Some(p) => println!("{}", serde_json::to_string_pretty(&p).unwrap()),
                None => eprintln!("未找到 id={} 的岗位", id),
            }
        }
        PositionCommands::Create { name, department, level, description, responsibilities, requirements } => {
            match sqlx::query(
                "INSERT INTO org_positions (name, department, level, description, responsibilities, requirements) VALUES (?1, ?2, ?3, ?4, ?5, ?6)",
            )
            .bind(&name).bind(&department).bind(&level)
            .bind(&description).bind(&responsibilities).bind(&requirements)
            .execute(&pool).await
            {
                Ok(r) => {
                    let p = sqlx::query_as::<_, Position>("SELECT * FROM org_positions WHERE id = ?1")
                        .bind(r.last_insert_rowid()).fetch_one(&pool).await.unwrap();
                    println!("{}", serde_json::to_string_pretty(&p).unwrap());
                }
                Err(e) => eprintln!("创建失败: {}", e),
            }
        }
        PositionCommands::Update { id, name, department, level, description, responsibilities, requirements, active } => {
            let id: i64 = id.parse().expect("ID 格式错误");
            let existing = match sqlx::query_as::<_, Position>("SELECT * FROM org_positions WHERE id = ?1")
                .bind(id).fetch_optional(&pool).await.unwrap()
            {
                Some(p) => p,
                None => { eprintln!("未找到 id={} 的岗位", id); return; }
            };
            sqlx::query(
                "UPDATE org_positions SET name=?1, department=?2, level=?3, description=?4, responsibilities=?5, requirements=?6, active=?7, updated_at=datetime('now') WHERE id=?8",
            )
            .bind(name.unwrap_or(existing.name))
            .bind(department.or(existing.department))
            .bind(level.or(existing.level))
            .bind(description.or(existing.description))
            .bind(responsibilities.or(existing.responsibilities))
            .bind(requirements.or(existing.requirements))
            .bind(active.unwrap_or(existing.active))
            .bind(id)
            .execute(&pool).await.unwrap();
            let updated = sqlx::query_as::<_, Position>("SELECT * FROM org_positions WHERE id = ?1")
                .bind(id).fetch_one(&pool).await.unwrap();
            println!("{}", serde_json::to_string_pretty(&updated).unwrap());
        }
        PositionCommands::Delete { id } => {
            let id: i64 = id.parse().expect("ID 格式错误");
            let result = sqlx::query("DELETE FROM org_positions WHERE id = ?1")
                .bind(id).execute(&pool).await.unwrap();
            if result.rows_affected() == 0 {
                eprintln!("未找到 id={} 的岗位", id);
            } else {
                println!("已删除 id={} 的岗位", id);
            }
        }
    }
}

async fn run_provider(args: PositionCommands) {
    let client = ProviderClient::new("");

    match args {
        PositionCommands::List { .. } => {
            match client.list_positions().await {
                Ok(positions) => println!("{}", serde_json::to_string_pretty(&positions).unwrap()),
                Err(e) => eprintln!("错误: {}", e),
            }
        }
        PositionCommands::Get { id } => {
            match client.get_position(&id.to_string()).await {
                Ok(p) => println!("{}", serde_json::to_string_pretty(&p).unwrap()),
                Err(e) => eprintln!("错误: {}", e),
            }
        }
        PositionCommands::Create { name, department, description, .. } => {
            let pos = provider::Position {
                id: None,
                name,
                department,
                description,
            };
            match client.create_position(&pos).await {
                Ok(p) => println!("{}", serde_json::to_string_pretty(&p).unwrap()),
                Err(e) => eprintln!("错误: {}", e),
            }
        }
        _ => eprintln!("Provider模式下暂不支持该操作"),
    }
}

pub fn dispatch(args: &PositionArgs, provider: bool) {
    if provider {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(run_provider(args.command.clone()));
    } else {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(run(args.command.clone()));
    }
}
