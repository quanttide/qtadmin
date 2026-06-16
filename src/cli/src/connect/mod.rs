pub mod lark;

use anyhow::Result;

#[derive(Debug, Clone)]
pub struct Message {
    pub subject: String,
    pub date: String,
}

pub trait MailFetcher {
    fn fetch_all(&self) -> Result<Vec<Message>>;
}
