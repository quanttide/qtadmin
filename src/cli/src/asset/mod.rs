mod archive;
mod audit;
mod status;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum AssetCommands {
    /// 将 journal 日志归档到 archive
    Archive(archive::ArchiveArgs),
    /// 审计资产仓库是否符合标准规范
    Audit(audit::AuditArgs),
    /// 评估资产内容质量状态
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
        AssetCommands::Audit(audit_args) => match audit::run(audit_args) {
            Ok(true) => {}
            Ok(false) => std::process::exit(1),
            Err(e) => {
                eprintln!("错误：{e}");
                std::process::exit(1);
            }
        },
        AssetCommands::Status(status_args) => {
            if let Err(e) = status::run(status_args) {
                eprintln!("错误：{e}");
                std::process::exit(1);
            }
        }
    }
}
