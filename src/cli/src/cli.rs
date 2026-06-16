use crate::asset;
use crate::human;
use crate::qtrecurit;

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
    /// 人力资源职能
    Human(human::HumanArgs),
    /// 招聘业务线
    Qtrecurit(qtrecurit::QtrecuritArgs),
}

pub fn run() {
    let cli = Cli::parse();

    match &cli.command {
        Some(Commands::Asset(args)) => asset::dispatch(args),
        Some(Commands::Human(args)) => human::dispatch(args),
        Some(Commands::Qtrecurit(args)) => qtrecurit::dispatch(args),
        None => {
            // --version and --help are handled by clap automatically
        }
    }
}
