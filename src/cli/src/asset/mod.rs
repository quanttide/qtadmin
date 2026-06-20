mod archive;
mod quality;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum AssetCommands {
    /// 将 journal 日志归档到 archive
    Archive(archive::ArchiveArgs),
    /// 评估资产质量
    Quality(quality::QualityArgs),
}

#[derive(clap::Args)]
pub struct AssetArgs {
    #[command(subcommand)]
    pub command: AssetCommands,
}

pub fn dispatch(args: &AssetArgs) {
    match &args.command {
        AssetCommands::Archive(archive_args) => {
            if let Err(e) = archive::run(archive_args) {
                eprintln!("错误：{e}");
            }
        }
        AssetCommands::Quality(quality_args) => match quality::run(quality_args) {
            Ok(true) => {}
            Ok(false) => std::process::exit(1),
            Err(e) => {
                eprintln!("错误：{e}");
                std::process::exit(1);
            }
        },
    }
}
