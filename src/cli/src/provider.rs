use anyhow::{Result, anyhow};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct Position {
    #[serde(default)]
    pub id: Option<String>,
    pub name: String,
    #[serde(default)]
    pub department: Option<String>,
    #[serde(default)]
    pub description: Option<String>,
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

    // ── Position ──

    pub async fn list_positions(&self) -> Result<Vec<Position>> {
        let resp = self
            .build_request(reqwest::Method::GET, "/api/v1/positions")
            .send()
            .await?;
        Self::check_response(resp).await
    }

    pub async fn get_position(&self, id: &str) -> Result<Position> {
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
