mod status;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum QtconsultCommands {
    /// 量潮咨询项目总览
    Status(status::StatusArgs),
}

#[derive(clap::Args)]
pub struct QtconsultArgs {
    #[command(subcommand)]
    pub command: QtconsultCommands,
}

pub fn dispatch(args: &QtconsultArgs) {
    match &args.command {
        QtconsultCommands::Status(status_args) => {
            if let Err(e) = status::run(status_args) {
                eprintln!("错误: {}", e);
            }
        }
    }
}
