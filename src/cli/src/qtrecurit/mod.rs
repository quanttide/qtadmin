mod status;
pub mod config;
mod connect;
mod human;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum QtrecuritCommands {
    /// 招聘数据统计
    Status(status::StatusArgs),
}

#[derive(clap::Args)]
pub struct QtrecuritArgs {
    #[command(subcommand)]
    pub command: QtrecuritCommands,
}

pub fn dispatch(args: &QtrecuritArgs) {
    match &args.command {
        QtrecuritCommands::Status(status_args) => {
            if let Err(e) = status::run(status_args) {
                eprintln!("错误: {}", e);
            }
        }
    }
}
