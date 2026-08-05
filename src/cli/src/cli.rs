use crate::asset;
use crate::business;
use crate::connect;
use crate::human;
use crate::knowl;
use crate::project;
use crate::share;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "qtadmin", version, about = "QuantTide Admin CLI")]
pub struct Cli {
    /// 使用 Provider API 模式 (替代本地文件操作)
    #[arg(short = 'p', long = "provider", global = true)]
    pub provider: bool,

    #[command(subcommand)]
    pub command: Option<Commands>,
}

#[derive(Subcommand)]
pub enum Commands {
    /// 数字资产职能
    Asset(asset::AssetArgs),
    /// 商务拓展职能
    Business(business::BusinessArgs),
    /// 连接基础设施
    Connect(connect::ConnectArgs),
    /// 人力资源职能
    Human(human::HumanArgs),
    /// 项目管理职能
    Project(project::ProjectArgs),
    /// 知识工程
    Knowl(knowl::KnowlArgs),
    /// 代码脱敏发布
    Share(share::ShareArgs),
}

pub fn run() {
    let cli = Cli::parse();
    let provider = cli.provider;

    match &cli.command {
        Some(Commands::Asset(args)) => asset::dispatch(args),
        Some(Commands::Business(args)) => business::dispatch(args),
        Some(Commands::Connect(args)) => connect::dispatch(args),
        Some(Commands::Human(args)) => human::dispatch(args, provider),
        Some(Commands::Project(args)) => project::dispatch(args),
        Some(Commands::Knowl(args)) => knowl::dispatch(args),
        Some(Commands::Share(args)) => {
            if let Err(e) = share::run(args) {
                eprintln!("错误: {}", e);
                std::process::exit(1);
            }
        }
        None => {}
    }
}
