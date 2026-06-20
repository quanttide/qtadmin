mod archive;
mod git_utils;
mod quality;
mod status;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum AssetCommands {
    /// 将 journal 日志归档到 archive
    Archive(archive::ArchiveArgs),
    /// 评估资产内容质量
    Quality(quality::QualityArgs),
    /// 查看资产状态（结构合规）
    Status(status::StatusArgs),
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
        AssetCommands::Quality(quality_args) => {
            if let Err(e) = quality::run(quality_args) {
                eprintln!("错误：{e}");
                std::process::exit(1);
            }
        }
        AssetCommands::Status(status_args) => match status::run(status_args) {
            Ok(true) => {}
            Ok(false) => std::process::exit(1),
            Err(e) => {
                eprintln!("错误：{e}");
                std::process::exit(1);
            }
        },
    }
}
