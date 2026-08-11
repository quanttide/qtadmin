use crate::asset;
use crate::business;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "qtadmin", version, about = "QuantTide Admin CLI")]
pub struct Cli {
    #[command(subcommand)]
    pub command: Option<Commands>,
}

#[derive(Subcommand)]
pub enum Commands {
    /// 数字资产职能
    Asset(asset::AssetArgs),
    /// 商务拓展职能
    Business(business::BusinessArgs),
}

pub fn run() {
    let cli = Cli::parse();

    match &cli.command {
        Some(Commands::Asset(args)) => asset::dispatch(args),
        Some(Commands::Business(args)) => business::dispatch(args),
        None => {}
    }
}
