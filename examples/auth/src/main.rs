#![allow(dead_code)]
mod auth;

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

#[derive(Deserialize)]
struct UserProfileCreate {
    real_name: String,
    email: String,
    phone: Option<String>,
    school: Option<String>,
    major: Option<String>,
    avatar_url: Option<String>,
    resume_url: Option<String>,
}

#[derive(Deserialize)]
struct UserProfileUpdate {
    real_name: Option<String>,
    email: Option<String>,
    phone: Option<String>,
    school: Option<String>,
    major: Option<String>,
    avatar_url: Option<String>,
    resume_url: Option<String>,
}

#[derive(Deserialize)]
struct ListQuery {
    q: Option<String>,
    email: Option<String>,
    skip: Option<i64>,
    limit: Option<i64>,
}

type DbPool = Arc<sqlx::SqlitePool>;

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

async fn list(
    State(pool): State<DbPool>,
    Query(q): Query<ListQuery>,
) -> Json<Vec<UserProfile>> {
    let skip = q.skip.unwrap_or(0);
    let limit = q.limit.unwrap_or(100).min(500);

    let profiles = if let Some(ref search) = q.q {
        let like = format!("%{}%", search);
        sqlx::query_as::<_, UserProfile>(
            "SELECT * FROM user_profiles WHERE real_name LIKE ?1 OR email LIKE ?1 ORDER BY created_at DESC LIMIT ?2 OFFSET ?3",
        )
        .bind(&like)
        .bind(limit)
        .bind(skip)
        .fetch_all(&*pool)
        .await
        .unwrap()
    } else if let Some(ref email) = q.email {
        sqlx::query_as::<_, UserProfile>(
            "SELECT * FROM user_profiles WHERE email = ?1 ORDER BY created_at DESC LIMIT ?2 OFFSET ?3",
        )
        .bind(email)
        .bind(limit)
        .bind(skip)
        .fetch_all(&*pool)
        .await
        .unwrap()
    } else {
        sqlx::query_as::<_, UserProfile>(
            "SELECT * FROM user_profiles ORDER BY created_at DESC LIMIT ?1 OFFSET ?2",
        )
        .bind(limit)
        .bind(skip)
        .fetch_all(&*pool)
        .await
        .unwrap()
    };

    Json(profiles)
}

async fn get_one(
    State(pool): State<DbPool>,
    Path(id): Path<i64>,
) -> impl IntoResponse {
    match sqlx::query_as::<_, UserProfile>("SELECT * FROM user_profiles WHERE id = ?1")
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
    Json(data): Json<UserProfileCreate>,
) -> impl IntoResponse {
    let result = sqlx::query(
        r#"
        INSERT INTO user_profiles (real_name, email, phone, school, major, avatar_url, resume_url)
        VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)
        "#,
    )
    .bind(&data.real_name)
    .bind(&data.email)
    .bind(&data.phone)
    .bind(&data.school)
    .bind(&data.major)
    .bind(&data.avatar_url)
    .bind(&data.resume_url)
    .execute(&*pool)
    .await;

    match result {
        Ok(r) => {
            let id = r.last_insert_rowid();
            let profile = sqlx::query_as::<_, UserProfile>("SELECT * FROM user_profiles WHERE id = ?1")
                .bind(id)
                .fetch_one(&*pool)
                .await
                .unwrap();
            (StatusCode::CREATED, Json(profile)).into_response()
        }
        Err(e) => {
            let msg = format!("{}", e);
            (StatusCode::CONFLICT, Json(serde_json::json!({"error": msg}))).into_response()
        }
    }
}

async fn update(
    State(pool): State<DbPool>,
    Path(id): Path<i64>,
    Json(data): Json<UserProfileUpdate>,
) -> impl IntoResponse {
    let existing = sqlx::query_as::<_, UserProfile>("SELECT * FROM user_profiles WHERE id = ?1")
        .bind(id)
        .fetch_optional(&*pool)
        .await
        .unwrap();

    let existing = match existing {
        Some(p) => p,
        None => return (StatusCode::NOT_FOUND, Json(serde_json::json!({"error": "not found"}))).into_response(),
    };

    let real_name = data.real_name.unwrap_or(existing.real_name);
    let email = data.email.unwrap_or(existing.email);
    let phone = data.phone.or(existing.phone);
    let school = data.school.or(existing.school);
    let major = data.major.or(existing.major);
    let avatar_url = data.avatar_url.or(existing.avatar_url);
    let resume_url = data.resume_url.or(existing.resume_url);

    sqlx::query(
        r#"
        UPDATE user_profiles SET real_name=?1, email=?2, phone=?3, school=?4, major=?5, avatar_url=?6, resume_url=?7, updated_at=datetime('now')
        WHERE id=?8
        "#,
    )
    .bind(&real_name)
    .bind(&email)
    .bind(&phone)
    .bind(&school)
    .bind(&major)
    .bind(&avatar_url)
    .bind(&resume_url)
    .bind(id)
    .execute(&*pool)
    .await
    .unwrap();

    let updated = sqlx::query_as::<_, UserProfile>("SELECT * FROM user_profiles WHERE id = ?1")
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
    let result = sqlx::query("DELETE FROM user_profiles WHERE id = ?1")
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
        .connect("sqlite:qtcloud-auth.db?mode=rwc")
        .await
        .expect("无法连接数据库");

    init_db(&pool).await;

    let state: DbPool = Arc::new(pool);

    let app = Router::new()
        .route("/health", get(|| async { Json(serde_json::json!({"status": "ok"})) }))
        .route("/user-profiles", get(list))
        .route("/user-profiles", post(create))
        .route("/user-profiles/{id}", get(get_one))
        .route("/user-profiles/{id}", patch(update))
        .route("/user-profiles/{id}", delete_method(delete_handler))
        .layer(CorsLayer::permissive())
        .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    println!("qtadmin-auth listening on http://0.0.0.0:3000");
    axum::serve(listener, app).await.unwrap();
}
