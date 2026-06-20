mod archive;
mod audit;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum AssetCommands {
    /// 将 journal 日志归档到 archive
    Archive(archive::ArchiveArgs),
    /// 审计资产规范（结构审计）或评估内容质量（--quality）
    Audit(audit::AuditArgs),
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
    }
}
