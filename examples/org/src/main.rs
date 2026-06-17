use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{delete as delete_method, get, patch, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use sqlx::sqlite::SqlitePoolOptions;
use sqlx::FromRow;
use std::sync::Arc;
use tower_http::cors::CorsLayer;
use tracing_subscriber;

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

#[derive(Deserialize)]
struct PositionCreate {
    name: String,
    department: Option<String>,
    level: Option<String>,
    description: Option<String>,
    responsibilities: Option<String>,
    requirements: Option<String>,
}

#[derive(Deserialize)]
struct PositionUpdate {
    name: Option<String>,
    department: Option<String>,
    level: Option<String>,
    description: Option<String>,
    responsibilities: Option<String>,
    requirements: Option<String>,
    active: Option<bool>,
}

#[derive(Deserialize)]
struct ListQuery {
    q: Option<String>,
    department: Option<String>,
    active: Option<bool>,
    skip: Option<i64>,
    limit: Option<i64>,
}

type DbPool = Arc<sqlx::SqlitePool>;

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

async fn list(
    State(pool): State<DbPool>,
    Query(q): Query<ListQuery>,
) -> Json<Vec<Position>> {
    let skip = q.skip.unwrap_or(0);
    let limit = q.limit.unwrap_or(100).min(500);

    let mut conditions: Vec<String> = Vec::new();
    let mut bind_idx = 1;

    if let Some(ref search) = q.q {
        conditions.push(format!("(name LIKE ?{bind_idx} OR department LIKE ?{bind_idx})"));
        bind_idx += 1;
    }
    if let Some(ref dept) = q.department {
        conditions.push(format!("department = ?{bind_idx}"));
        bind_idx += 1;
    }
    if let Some(a) = q.active {
        conditions.push(format!("active = ?{bind_idx}"));
        bind_idx += 1;
    }

    let where_clause = if conditions.is_empty() {
        String::new()
    } else {
        format!("WHERE {}", conditions.join(" AND "))
    };

    let query_str = format!(
        "SELECT * FROM org_positions {} ORDER BY name LIMIT ?{bind_idx} OFFSET ?{}",
        where_clause,
        bind_idx + 1
    );

    let mut query = sqlx::query_as::<_, Position>(&query_str);
    let mut bind_idx = 1;

    if let Some(ref search) = q.q {
        let like = format!("%{}%", search);
        query = query.bind(like);
        bind_idx += 1;
    }
    if let Some(ref dept) = q.department {
        query = query.bind(dept);
        bind_idx += 1;
    }
    if let Some(a) = q.active {
        query = query.bind(a);
        bind_idx += 1;
    }

    query = query.bind(limit).bind(skip);

    let positions = query.fetch_all(&*pool).await.unwrap();
    Json(positions)
}

async fn get_one(
    State(pool): State<DbPool>,
    Path(id): Path<i64>,
) -> impl IntoResponse {
    match sqlx::query_as::<_, Position>("SELECT * FROM org_positions WHERE id = ?1")
        .bind(id)
        .fetch_optional(&*pool)
        .await
        .unwrap()
    {
        Some(p) => (StatusCode::OK, Json(p)).into_response(),
        None => (StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "not found"}))).into_response(),
    }
}

async fn create(
    State(pool): State<DbPool>,
    Json(data): Json<PositionCreate>,
) -> impl IntoResponse {
    let result = sqlx::query(
        r#"
        INSERT INTO org_positions (name, department, level, description, responsibilities, requirements)
        VALUES (?1, ?2, ?3, ?4, ?5, ?6)
        "#,
    )
    .bind(&data.name)
    .bind(&data.department)
    .bind(&data.level)
    .bind(&data.description)
    .bind(&data.responsibilities)
    .bind(&data.requirements)
    .execute(&*pool)
    .await;

    match result {
        Ok(r) => {
            let id = r.last_insert_rowid();
            let p = sqlx::query_as::<_, Position>("SELECT * FROM org_positions WHERE id = ?1")
                .bind(id)
                .fetch_one(&*pool)
                .await
                .unwrap();
            (StatusCode::CREATED, Json(p)).into_response()
        }
        Err(e) => {
            (StatusCode::CONFLICT, Json(serde_json::json!({"error": format!("{}", e)}))).into_response()
        }
    }
}

async fn update(
    State(pool): State<DbPool>,
    Path(id): Path<i64>,
    Json(data): Json<PositionUpdate>,
) -> impl IntoResponse {
    let existing = sqlx::query_as::<_, Position>("SELECT * FROM org_positions WHERE id = ?1")
        .bind(id)
        .fetch_optional(&*pool)
        .await
        .unwrap();

    let existing = match existing {
        Some(p) => p,
        None => return (StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "not found"}))).into_response(),
    };

    sqlx::query(
        r#"
        UPDATE org_positions
        SET name=?1, department=?2, level=?3, description=?4, responsibilities=?5, requirements=?6, active=?7, updated_at=datetime('now')
        WHERE id=?8
        "#,
    )
    .bind(data.name.unwrap_or(existing.name))
    .bind(data.department.or(existing.department))
    .bind(data.level.or(existing.level))
    .bind(data.description.or(existing.description))
    .bind(data.responsibilities.or(existing.responsibilities))
    .bind(data.requirements.or(existing.requirements))
    .bind(data.active.unwrap_or(existing.active))
    .bind(id)
    .execute(&*pool)
    .await
    .unwrap();

    let updated = sqlx::query_as::<_, Position>("SELECT * FROM org_positions WHERE id = ?1")
        .bind(id)
        .fetch_one(&*pool)
        .await
        .unwrap();

    (StatusCode::OK, Json(updated)).into_response()
}

async fn delete_handler(
    State(pool): State<DbPool>,
    Path(id): Path<i64>,
) -> impl IntoResponse {
    let result = sqlx::query("DELETE FROM org_positions WHERE id = ?1")
        .bind(id)
        .execute(&*pool)
        .await
        .unwrap();

    if result.rows_affected() == 0 {
        (StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "not found"}))).into_response()
    } else {
        (StatusCode::NO_CONTENT, Json(serde_json::json!({}))).into_response()
    }
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let pool = SqlitePoolOptions::new()
        .connect("sqlite:qtcloud-org.db?mode=rwc")
        .await
        .expect("无法连接数据库");

    init_db(&pool).await;

    let state: DbPool = Arc::new(pool);

    let app = Router::new()
        .route("/health", get(|| async { Json(serde_json::json!({"status": "ok"})) }))
        .route("/positions", get(list))
        .route("/positions", post(create))
        .route("/positions/{id}", get(get_one))
        .route("/positions/{id}", patch(update))
        .route("/positions/{id}", delete_method(delete_handler))
        .layer(CorsLayer::permissive())
        .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3001").await.unwrap();
    println!("qtadmin-org listening on http://0.0.0.0:3001");
    axum::serve(listener, app).await.unwrap();
}
