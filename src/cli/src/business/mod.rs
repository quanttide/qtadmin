mod status;
mod quote;

use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BusinessStatus {
    pub orders: Vec<OrderItem>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OrderItem {
    pub title: String,
    pub client: String,
    pub stage: String,
    pub amount: String,
}

pub trait OrderStore {
    fn load(&self) -> BusinessStatus;
}

pub struct FileOrderStore;

impl OrderStore for FileOrderStore {
    fn load(&self) -> BusinessStatus {
        let path = order_path();
        if let Ok(content) = std::fs::read_to_string(&path) {
            if let Ok(status) = serde_json::from_str(&content) {
                return status;
            }
        }
        status::default_orders()
    }
}

fn order_path() -> PathBuf {
    if let Ok(dir) = std::env::var("QTRECURIT_DATA") {
        let p = PathBuf::from(dir);
        return p.join("business_orders.json");
    }
    if let Some(data_dir) = dirs::data_dir() {
        return data_dir.join("qtadmin").join("business_orders.json");
    }
    if let Ok(cwd) = std::env::current_dir() {
        return cwd.join("business_orders.json");
    }
    PathBuf::from("business_orders.json")
}

use clap::Subcommand;

#[derive(Subcommand)]
pub enum BusinessCommands {
    /// 商务拓展总览
    Status(status::StatusArgs),
    /// 报价计算
    Quote(quote::QuoteArgs),
}

#[derive(clap::Args)]
pub struct BusinessArgs {
    #[command(subcommand)]
    pub command: BusinessCommands,
}

pub fn dispatch(args: &BusinessArgs) {
    match &args.command {
        BusinessCommands::Status(status_args) => {
            if let Err(e) = status::run(status_args) {
                eprintln!("错误: {}", e);
            }
        }
        BusinessCommands::Quote(quote_args) => {
            if let Err(e) = quote::run(quote_args) {
                eprintln!("错误: {}", e);
            }
        }
    }
}
