use clap::{Args, Subcommand};
use serde::{Deserialize, Serialize};
use sqlx::sqlite::SqlitePoolOptions;
use sqlx::FromRow;

#[derive(FromRow, Serialize, Deserialize)]
struct UserProfile {
    id: i64,
    real_name: String,
    email: String,
    phone: Option<String>,
    school: Option<String>,
    major: Option<String>,
    avatar_url: Option<String>,
    resume_url: Option<String>,
}

#[derive(Args)]
pub struct UserArgs {
    #[command(subcommand)]
    pub command: UserCommands,
}

#[derive(Clone, Subcommand)]
pub enum UserCommands {
    /// 列出用户档案
    List {
        #[arg(long)]
        search: Option<String>,
        #[arg(long)]
        email: Option<String>,
        #[arg(long, default_value = "100")]
        limit: i64,
        #[arg(long, default_value = "0")]
        skip: i64,
    },
    /// 查询单个用户档案
    Get { id: i64 },
    /// 创建用户档案
    Create {
        #[arg(long)]
        real_name: String,
        #[arg(long)]
        email: String,
        #[arg(long)]
        phone: Option<String>,
        #[arg(long)]
        school: Option<String>,
        #[arg(long)]
        major: Option<String>,
        #[arg(long)]
        avatar_url: Option<String>,
        #[arg(long)]
        resume_url: Option<String>,
    },
    /// 更新用户档案
    Update {
        id: i64,
        #[arg(long)]
        real_name: Option<String>,
        #[arg(long)]
        email: Option<String>,
        #[arg(long)]
        phone: Option<String>,
        #[arg(long)]
        school: Option<String>,
        #[arg(long)]
        major: Option<String>,
        #[arg(long)]
        avatar_url: Option<String>,
        #[arg(long)]
        resume_url: Option<String>,
    },
    /// 删除用户档案
    Delete { id: i64 },
}

async fn init_db(pool: &sqlx::SqlitePool) {
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS user_profiles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            real_name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            phone TEXT,
            school TEXT,
            major TEXT,
            avatar_url TEXT,
            resume_url TEXT,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        )
        "#,
    )
    .execute(pool)
    .await
    .unwrap();
}

async fn run(args: UserCommands) {
    let pool = SqlitePoolOptions::new()
        .connect("sqlite:qtcloud-auth.db?mode=rwc")
        .await
        .expect("无法连接数据库");
    init_db(&pool).await;

    match args {
        UserCommands::List {
            search,
            email,
            limit,
            skip,
        } => {
            let profiles = if let Some(ref q) = search {
                let like = format!("%{}%", q);
                sqlx::query_as::<_, UserProfile>(
                    "SELECT * FROM user_profiles WHERE real_name LIKE ?1 OR email LIKE ?1 ORDER BY created_at DESC LIMIT ?2 OFFSET ?3",
                )
                .bind(&like).bind(limit).bind(skip).fetch_all(&pool).await.unwrap()
            } else if let Some(ref e) = email {
                sqlx::query_as::<_, UserProfile>(
                    "SELECT * FROM user_profiles WHERE email = ?1 ORDER BY created_at DESC LIMIT ?2 OFFSET ?3",
                )
                .bind(e).bind(limit).bind(skip).fetch_all(&pool).await.unwrap()
            } else {
                sqlx::query_as::<_, UserProfile>(
                    "SELECT * FROM user_profiles ORDER BY created_at DESC LIMIT ?1 OFFSET ?2",
                )
                .bind(limit)
                .bind(skip)
                .fetch_all(&pool)
                .await
                .unwrap()
            };
            println!("{}", serde_json::to_string_pretty(&profiles).unwrap());
        }
        UserCommands::Get { id } => {
            let profile =
                sqlx::query_as::<_, UserProfile>("SELECT * FROM user_profiles WHERE id = ?1")
                    .bind(id)
                    .fetch_optional(&pool)
                    .await
                    .unwrap();
            match profile {
                Some(p) => println!("{}", serde_json::to_string_pretty(&p).unwrap()),
                None => eprintln!("未找到 id={} 的用户", id),
            }
        }
        UserCommands::Create {
            real_name,
            email,
            phone,
            school,
            major,
            avatar_url,
            resume_url,
        } => {
            let result = sqlx::query(
                "INSERT INTO user_profiles (real_name, email, phone, school, major, avatar_url, resume_url) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
            )
            .bind(&real_name).bind(&email).bind(&phone).bind(&school)
            .bind(&major).bind(&avatar_url).bind(&resume_url)
            .execute(&pool).await;
            match result {
                Ok(r) => {
                    let p = sqlx::query_as::<_, UserProfile>(
                        "SELECT * FROM user_profiles WHERE id = ?1",
                    )
                    .bind(r.last_insert_rowid())
                    .fetch_one(&pool)
                    .await
                    .unwrap();
                    println!("{}", serde_json::to_string_pretty(&p).unwrap());
                }
                Err(e) => eprintln!("创建失败: {}", e),
            }
        }
        UserCommands::Update {
            id,
            real_name,
            email,
            phone,
            school,
            major,
            avatar_url,
            resume_url,
        } => {
            let existing =
                sqlx::query_as::<_, UserProfile>("SELECT * FROM user_profiles WHERE id = ?1")
                    .bind(id)
                    .fetch_optional(&pool)
                    .await
                    .unwrap();
            let existing = match existing {
                Some(p) => p,
                None => {
                    eprintln!("未找到 id={} 的用户", id);
                    return;
                }
            };
            sqlx::query(
                "UPDATE user_profiles SET real_name=?1, email=?2, phone=?3, school=?4, major=?5, avatar_url=?6, resume_url=?7, updated_at=datetime('now') WHERE id=?8",
            )
            .bind(real_name.unwrap_or(existing.real_name))
            .bind(email.unwrap_or(existing.email))
            .bind(phone.or(existing.phone))
            .bind(school.or(existing.school))
            .bind(major.or(existing.major))
            .bind(avatar_url.or(existing.avatar_url))
            .bind(resume_url.or(existing.resume_url))
            .bind(id)
            .execute(&pool).await.unwrap();
            let updated =
                sqlx::query_as::<_, UserProfile>("SELECT * FROM user_profiles WHERE id = ?1")
                    .bind(id)
                    .fetch_one(&pool)
                    .await
                    .unwrap();
            println!("{}", serde_json::to_string_pretty(&updated).unwrap());
        }
        UserCommands::Delete { id } => {
            let result = sqlx::query("DELETE FROM user_profiles WHERE id = ?1")
                .bind(id)
                .execute(&pool)
                .await
                .unwrap();
            if result.rows_affected() == 0 {
                eprintln!("未找到 id={} 的用户", id);
            } else {
                println!("已删除 id={} 的用户", id);
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_args_list_command() {
        let args = UserArgs {
            command: UserCommands::List {
                search: None,
                email: None,
                limit: 50,
                skip: 10,
            },
        };
        match args.command {
            UserCommands::List {
                search,
                email,
                limit,
                skip,
                ..
            } => {
                assert!(search.is_none());
                assert!(email.is_none());
                assert_eq!(limit, 50);
                assert_eq!(skip, 10);
            }
            _ => panic!("expected List variant"),
        }
    }

    #[test]
    fn test_user_args_get_command() {
        let args = UserArgs {
            command: UserCommands::Get { id: 42 },
        };
        match args.command {
            UserCommands::Get { id } => {
                assert_eq!(id, 42);
            }
            _ => panic!("expected Get variant"),
        }
    }

    #[test]
    fn test_user_args_create_command() {
        let args = UserArgs {
            command: UserCommands::Create {
                real_name: "张三".to_string(),
                email: "zhangsan@example.com".to_string(),
                phone: Some("13800138000".to_string()),
                school: None,
                major: None,
                avatar_url: None,
                resume_url: None,
            },
        };
        match args.command {
            UserCommands::Create {
                real_name,
                email,
                phone,
                ..
            } => {
                assert_eq!(real_name, "张三");
                assert_eq!(email, "zhangsan@example.com");
                assert_eq!(phone, Some("13800138000".to_string()));
            }
            _ => panic!("expected Create variant"),
        }
    }
}

pub fn dispatch(args: &UserArgs) {
    let rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(run(args.command.clone()));
}
