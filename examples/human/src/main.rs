use clap::{Parser, Subcommand};
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

#[derive(Parser)]
#[command(name = "human", about = "组织架构岗位管理 CLI")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
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
    Get {
        id: i64,
    },
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
        id: i64,
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
    Delete {
        id: i64,
    },
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

async fn run(cli: Cli) {
    let pool = SqlitePoolOptions::new()
        .connect("sqlite:qtcloud-org.db?mode=rwc")
        .await
        .expect("无法连接数据库");

    init_db(&pool).await;

    match cli.command {
        Commands::List { department, active, search, limit, skip } => {
            let mut conditions: Vec<String> = Vec::new();
            let mut bind_idx = 1;

            if let Some(ref q) = search {
                conditions.push(format!("(name LIKE ?{bind_idx} OR department LIKE ?{bind_idx})"));
                bind_idx += 1;
            }
            if let Some(ref dept) = department {
                conditions.push(format!("department = ?{bind_idx}"));
                bind_idx += 1;
            }
            if let Some(a) = active {
                conditions.push(format!("active = ?{bind_idx}"));
                bind_idx += 1;
            }

            let where_clause = if conditions.is_empty() {
                String::new()
            } else {
                format!("WHERE {}", conditions.join(" AND "))
            };

            let query_str = format!(
                "SELECT * FROM org_positions {} ORDER BY name LIMIT ?{limit} OFFSET ?{skip}",
                where_clause,
            );

            let mut query = sqlx::query_as::<_, Position>(&query_str);
            let mut bind_idx = 1;

            if let Some(ref q) = search {
                query = query.bind(format!("%{}%", q));
                bind_idx += 1;
            }
            if let Some(ref dept) = department {
                query = query.bind(dept);
                bind_idx += 1;
            }
            if let Some(a) = active {
                query = query.bind(a);
                bind_idx += 1;
            }

            let positions = query.bind(limit).bind(skip).fetch_all(&pool).await.unwrap();
            println!("{}", serde_json::to_string_pretty(&positions).unwrap());
        }
        Commands::Get { id } => {
            let position = sqlx::query_as::<_, Position>("SELECT * FROM org_positions WHERE id = ?1")
                .bind(id)
                .fetch_optional(&pool)
                .await
                .unwrap();
            match position {
                Some(p) => println!("{}", serde_json::to_string_pretty(&p).unwrap()),
                None => eprintln!("未找到 id={} 的岗位", id),
            }
        }
        Commands::Create { name, department, level, description, responsibilities, requirements } => {
            let result = sqlx::query(
                r#"INSERT INTO org_positions (name, department, level, description, responsibilities, requirements) VALUES (?1, ?2, ?3, ?4, ?5, ?6)"#,
            )
            .bind(&name)
            .bind(&department)
            .bind(&level)
            .bind(&description)
            .bind(&responsibilities)
            .bind(&requirements)
            .execute(&pool)
            .await;

            match result {
                Ok(r) => {
                    let p = sqlx::query_as::<_, Position>("SELECT * FROM org_positions WHERE id = ?1")
                        .bind(r.last_insert_rowid())
                        .fetch_one(&pool)
                        .await
                        .unwrap();
                    println!("{}", serde_json::to_string_pretty(&p).unwrap());
                }
                Err(e) => eprintln!("创建失败: {}", e),
            }
        }
        Commands::Update { id, name, department, level, description, responsibilities, requirements, active } => {
            let existing = sqlx::query_as::<_, Position>("SELECT * FROM org_positions WHERE id = ?1")
                .bind(id)
                .fetch_optional(&pool)
                .await
                .unwrap();

            let existing = match existing {
                Some(p) => p,
                None => {
                    eprintln!("未找到 id={} 的岗位", id);
                    return;
                }
            };

            sqlx::query(
                r#"UPDATE org_positions SET name=?1, department=?2, level=?3, description=?4, responsibilities=?5, requirements=?6, active=?7, updated_at=datetime('now') WHERE id=?8"#,
            )
            .bind(name.unwrap_or(existing.name))
            .bind(department.or(existing.department))
            .bind(level.or(existing.level))
            .bind(description.or(existing.description))
            .bind(responsibilities.or(existing.responsibilities))
            .bind(requirements.or(existing.requirements))
            .bind(active.unwrap_or(existing.active))
            .bind(id)
            .execute(&pool)
            .await
            .unwrap();

            let updated = sqlx::query_as::<_, Position>("SELECT * FROM org_positions WHERE id = ?1")
                .bind(id)
                .fetch_one(&pool)
                .await
                .unwrap();
            println!("{}", serde_json::to_string_pretty(&updated).unwrap());
        }
        Commands::Delete { id } => {
            let result = sqlx::query("DELETE FROM org_positions WHERE id = ?1")
                .bind(id)
                .execute(&pool)
                .await
                .unwrap();
            if result.rows_affected() == 0 {
                eprintln!("未找到 id={} 的岗位", id);
            } else {
                println!("已删除 id={} 的岗位", id);
            }
        }
    }
}

fn main() {
    let cli = Cli::parse();
    tokio::runtime::Runtime::new().unwrap().block_on(run(cli));
}
