mod status;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum QtclassCommands {
    /// 量潮课堂项目总览
    Status(status::StatusArgs),
}

#[derive(clap::Args)]
pub struct QtclassArgs {
    #[command(subcommand)]
    pub command: QtclassCommands,
}

pub fn dispatch(args: &QtclassArgs) {
    match &args.command {
        QtclassCommands::Status(status_args) => {
            if let Err(e) = status::run(status_args) {
                eprintln!("错误: {}", e);
            }
        }
    }
}
