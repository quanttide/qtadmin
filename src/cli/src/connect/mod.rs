pub mod email;

use anyhow::Result;

#[derive(Debug, Clone)]
pub struct Message {
    pub subject: String,
    pub date: String,
}

pub trait EmailFetcher {
    fn fetch_all(&self) -> Result<Vec<Message>>;
}
