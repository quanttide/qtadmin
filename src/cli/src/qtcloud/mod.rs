mod status;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum QtcloudCommands {
    /// 量潮云项目总览
    Status(status::StatusArgs),
}

#[derive(clap::Args)]
pub struct QtcloudArgs {
    #[command(subcommand)]
    pub command: QtcloudCommands,
}

pub fn dispatch(args: &QtcloudArgs) {
    match &args.command {
        QtcloudCommands::Status(status_args) => {
            if let Err(e) = status::run(status_args) {
                eprintln!("错误: {}", e);
            }
        }
    }
}
