use crate::asset;

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
}

pub fn run() {
    let cli = Cli::parse();

    match &cli.command {
        Some(Commands::Asset(args)) => asset::dispatch(args),
        None => {
            // --version and --help are handled by clap automatically
        }
    }
}
