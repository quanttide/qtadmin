use anyhow::{Result, anyhow};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Employee {
    pub id: Option<i64>,
    pub name: String,
    pub email: Option<String>,
    pub phone: Option<String>,
    pub department: Option<String>,
    pub position: Option<String>,
    pub hire_date: Option<String>,
    pub active: Option<bool>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Department {
    pub id: Option<i64>,
    pub name: String,
    pub description: Option<String>,
    pub parent: Option<String>,
    pub active: Option<bool>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Position {
    pub id: Option<i64>,
    pub name: String,
    pub department: Option<String>,
    pub level: Option<String>,
    pub description: Option<String>,
    pub responsibilities: Option<String>,
    pub requirements: Option<String>,
    pub active: Option<bool>,
}

#[derive(Debug, Deserialize)]
struct ErrorBody {
    #[allow(dead_code)]
    message: Option<String>,
    #[allow(dead_code)]
    error: Option<String>,
    #[allow(dead_code)]
    detail: Option<serde_json::Value>,
}

pub struct ProviderClient {
    base_url: String,
    token: Option<String>,
    client: reqwest::Client,
}

impl ProviderClient {
    pub fn new(base_url: &str) -> Self {
        let url = if base_url.is_empty() {
            std::env::var("PROVIDER_URL").unwrap_or_else(|_| "http://localhost:8000".to_string())
        } else {
            base_url.to_string()
        };
        ProviderClient {
            base_url: url.trim_end_matches('/').to_string(),
            token: None,
            client: reqwest::Client::new(),
        }
    }

    pub fn set_token(&mut self, token: String) {
        self.token = Some(token);
    }

    pub fn token(&self) -> Option<&str> {
        self.token.as_deref()
    }

    pub async fn login(&mut self, username: &str, password: &str) -> Result<String> {
        let resp = self
            .client
            .post(format!("{}/api/v1/auth/login", self.base_url))
            .json(&serde_json::json!({
                "username": username,
                "password": password
            }))
            .send()
            .await?;

        if !resp.status().is_success() {
            let status = resp.status();
            let body = resp.text().await.unwrap_or_default();
            return Err(anyhow!("登录失败 ({}): {}", status, body));
        }

        let body: serde_json::Value = resp.json().await?;
        let token = body["token"]
            .as_str()
            .ok_or_else(|| anyhow!("响应中缺少 token"))?
            .to_string();

        self.token = Some(token.clone());
        Ok(token)
    }

    fn build_request(&self, method: reqwest::Method, path: &str) -> reqwest::RequestBuilder {
        let url = format!("{}{}", self.base_url, path);
        let req = self.client.request(method, &url);
        if let Some(ref token) = self.token {
            req.header("Authorization", format!("Bearer {}", token))
        } else {
            req
        }
    }

    async fn check_response<T: serde::de::DeserializeOwned>(
        resp: reqwest::Response,
    ) -> Result<T> {
        let status = resp.status();
        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();
            return Err(anyhow!("请求失败 ({}): {}", status, body));
        }
        Ok(resp.json().await?)
    }

    // ── Employee ──

    pub async fn list_employees(&self) -> Result<Vec<Employee>> {
        let resp = self
            .build_request(reqwest::Method::GET, "/api/v1/employees")
            .send()
            .await?;
        Self::check_response(resp).await
    }

    pub async fn get_employee(&self, id: i64) -> Result<Employee> {
        let resp = self
            .build_request(reqwest::Method::GET, &format!("/api/v1/employees/{}", id))
            .send()
            .await?;
        Self::check_response(resp).await
    }

    pub async fn create_employee(&self, emp: &Employee) -> Result<Employee> {
        let resp = self
            .build_request(reqwest::Method::POST, "/api/v1/employees")
            .json(emp)
            .send()
            .await?;
        Self::check_response(resp).await
    }

    // ── Department ──

    pub async fn list_departments(&self) -> Result<Vec<Department>> {
        let resp = self
            .build_request(reqwest::Method::GET, "/api/v1/departments")
            .send()
            .await?;
        Self::check_response(resp).await
    }

    pub async fn get_department(&self, id: i64) -> Result<Department> {
        let resp = self
            .build_request(reqwest::Method::GET, &format!("/api/v1/departments/{}", id))
            .send()
            .await?;
        Self::check_response(resp).await
    }

    pub async fn create_department(&self, dept: &Department) -> Result<Department> {
        let resp = self
            .build_request(reqwest::Method::POST, "/api/v1/departments")
            .json(dept)
            .send()
            .await?;
        Self::check_response(resp).await
    }

    // ── Position ──

    pub async fn list_positions(&self) -> Result<Vec<Position>> {
        let resp = self
            .build_request(reqwest::Method::GET, "/api/v1/positions")
            .send()
            .await?;
        Self::check_response(resp).await
    }

    pub async fn get_position(&self, id: i64) -> Result<Position> {
        let resp = self
            .build_request(reqwest::Method::GET, &format!("/api/v1/positions/{}", id))
            .send()
            .await?;
        Self::check_response(resp).await
    }

    pub async fn create_position(&self, pos: &Position) -> Result<Position> {
        let resp = self
            .build_request(reqwest::Method::POST, "/api/v1/positions")
            .json(pos)
            .send()
            .await?;
        Self::check_response(resp).await
    }
}
