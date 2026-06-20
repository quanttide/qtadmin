mod archive;
mod audit;
mod evaluate;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum AssetCommands {
    /// 将 journal 日志归档到 archive
    Archive(archive::ArchiveArgs),
    /// 审计 Git 仓库是否符合标准资产体系规范
    Audit(audit::AuditArgs),
    /// p40 手册质量多维度评估
    Evaluate(evaluate::EvaluateArgs),
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
        AssetCommands::Evaluate(evaluate_args) => {
            if let Err(e) = evaluate::run(evaluate_args) {
                eprintln!("错误：{e}");
                std::process::exit(1);
            }
        }
    }
}
