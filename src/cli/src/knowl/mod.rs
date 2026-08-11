pub mod acquire;
pub mod extract;
pub mod summary;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum KnowlCommands {
    /// 知识获取（LLM 从文档中提取结构化知识）
    Acquire(acquire::AcquireArgs),
    /// 知识抽取（本体 YAML → 结构化产物）
    Extract(extract::ExtractArgs),
    /// 知识总结（忠实总结现有知识，不生成新产物）
    Summary(summary::SummaryArgs),
}

#[derive(clap::Args)]
pub struct KnowlArgs {
    #[command(subcommand)]
    pub command: KnowlCommands,
}

pub fn dispatch(args: &KnowlArgs) {
    match &args.command {
        KnowlCommands::Acquire(acquire_args) => {
            if let Err(e) = acquire::run(acquire_args) {
                eprintln!("错误: {}", e);
            }
        }
        KnowlCommands::Extract(extract_args) => {
            if let Err(e) = extract::run(extract_args) {
                eprintln!("错误: {}", e);
            }
        }
        KnowlCommands::Summary(summary_args) => {
            if let Err(e) = summary::run(summary_args) {
                eprintln!("错误: {}", e);
            }
        }
    }
}
