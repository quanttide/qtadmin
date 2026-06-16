pub mod config;
pub mod report;
mod status;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum HumanCommands {
    /// 招聘计划与进度（面向内部管理）
    Status(status::StatusArgs),
}

#[derive(clap::Args)]
pub struct HumanArgs {
    #[command(subcommand)]
    pub command: HumanCommands,
}

pub fn dispatch(args: &HumanArgs) {
    match &args.command {
        HumanCommands::Status(status_args) => {
            if let Err(e) = status::run(status_args) {
                eprintln!("错误: {}", e);
            }
        }
    }
}
