mod status;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum QtdataCommands {
    /// 量潮数据项目总览
    Status(status::StatusArgs),
}

#[derive(clap::Args)]
pub struct QtdataArgs {
    #[command(subcommand)]
    pub command: QtdataCommands,
}

pub fn dispatch(args: &QtdataArgs) {
    match &args.command {
        QtdataCommands::Status(status_args) => {
            if let Err(e) = status::run(status_args) {
                eprintln!("错误: {}", e);
            }
        }
    }
}
