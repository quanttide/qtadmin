mod acquire;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum KnowlCommands {
    /// 知识获取（LLM 从文档中提取结构化知识）
    Acquire(acquire::AcquireArgs),
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
    }
}
