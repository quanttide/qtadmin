use clap::{Parser, Subcommand};

/// qtadmin CLI——第二大脑结构的名词 API。
///
/// 四个二级子命令按第二大脑结构组织（设计正本 `docs/dev-guide/cli.md`），
/// 每级下按现有结构再挂下一级；以名词为主，叶子先显性化、数据源后接。
#[derive(Parser)]
#[command(
    name = "qtadmin",
    version,
    about = "QuantTide Admin CLI——第二大脑结构的名词 API"
)]
pub struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// 主体
    Entity {
        #[command(subcommand)]
        subject: EntityCommand,
    },
    /// 领域
    Domain {
        #[command(subcommand)]
        subject: DomainCommand,
    },
    /// 适配
    Adapter {
        #[command(subcommand)]
        subject: AdapterCommand,
    },
    /// 范畴（结构待定）
    Category,
}

#[derive(Subcommand)]
enum EntityCommand {
    /// 创始人主体
    Founder,
    /// 公司
    Company,
    /// 联盟
    Alliance,
    /// 学院
    Academy,
}

#[derive(Subcommand)]
enum DomainCommand {
    /// 数据（data/）
    Data,
}

#[derive(Subcommand)]
enum AdapterCommand {
    /// 飞书（feishu/）
    Feishu,
}

pub fn run() {
    let cli = Cli::parse();
    let path = match cli.command {
        Command::Entity { subject } => {
            let name = match subject {
                EntityCommand::Founder => "founder",
                EntityCommand::Company => "company",
                EntityCommand::Alliance => "alliance",
                EntityCommand::Academy => "academy",
            };
            format!("entity/{name}")
        }
        Command::Domain { subject } => {
            let name = match subject {
                DomainCommand::Data => "data",
            };
            format!("domain/{name}")
        }
        Command::Adapter { subject } => {
            let name = match subject {
                AdapterCommand::Feishu => "feishu",
            };
            format!("adapter/{name}")
        }
        Command::Category => {
            println!("category：范畴结构待定（0.1.0-alpha.1 骨架）");
            return;
        }
    };
    // 诚实标注：骨架已挂、数据源未接，不演戏
    println!("{path}：结构已挂，数据源未接（0.1.0-alpha.1 骨架）");
}
