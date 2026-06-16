mod backup;
mod audit;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum AssetCommands {
    /// 将 journal 日志归档到 archive
    Backup(backup::BackupArgs),
    /// 审计 Git 仓库是否符合标准资产体系规范
    Audit(audit::AuditArgs),
}

#[derive(clap::Args)]
pub struct AssetArgs {
    #[command(subcommand)]
    pub command: AssetCommands,
}

pub fn dispatch(args: &AssetArgs) {
    match &args.command {
        AssetCommands::Backup(backup_args) => backup::run(backup_args),
        AssetCommands::Audit(audit_args) => audit::run(audit_args),
    }
}
