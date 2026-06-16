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
        AssetCommands::Backup(backup_args) => {
            if let Err(e) = backup::run(backup_args) {
                eprintln!("错误：{e}");
            }
        }
        AssetCommands::Audit(audit_args) => {
            match audit::run(audit_args) {
                Ok(true) => {}
                Ok(false) => std::process::exit(1),
                Err(e) => {
                    eprintln!("错误：{e}");
                    std::process::exit(1);
                }
            }
        }
    }
}
