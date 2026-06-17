use crate::asset;
use crate::business;
use crate::human;
use crate::project;
use crate::qtcloud;
use crate::qtclass;
use crate::qtconsult;
use crate::qtdata;
use crate::knowl;
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
    /// 商务拓展职能
    Business(business::BusinessArgs),
    /// 项目管理职能
    Project(project::ProjectArgs),
    /// 量潮咨询
    Qtconsult(qtconsult::QtconsultArgs),
    /// 量潮课堂
    Qtclass(qtclass::QtclassArgs),
    /// 量潮云
    Qtcloud(qtcloud::QtcloudArgs),
    /// 量潮数据
    Qtdata(qtdata::QtdataArgs),
    /// 量潮招聘
    Qtrecurit(qtrecurit::QtrecuritArgs),
    /// 知识工程
    Knowl(knowl::KnowlArgs),
}

pub fn run() {
    let cli = Cli::parse();

    match &cli.command {
        Some(Commands::Asset(args)) => asset::dispatch(args),
        Some(Commands::Human(args)) => human::dispatch(args),
        Some(Commands::Business(args)) => business::dispatch(args),
        Some(Commands::Project(args)) => project::dispatch(args),
        Some(Commands::Qtconsult(args)) => qtconsult::dispatch(args),
        Some(Commands::Qtclass(args)) => qtclass::dispatch(args),
        Some(Commands::Qtcloud(args)) => qtcloud::dispatch(args),
        Some(Commands::Qtdata(args)) => qtdata::dispatch(args),
        Some(Commands::Qtrecurit(args)) => qtrecurit::dispatch(args),
        Some(Commands::Knowl(args)) => knowl::dispatch(args),
        None => {
            // --version and --help are handled by clap automatically
        }
    }
}
