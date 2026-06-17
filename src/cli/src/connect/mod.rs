pub mod email;
pub mod notice;

use anyhow::Result;

#[derive(Debug, Clone)]
pub struct Message {
    pub subject: String,
    pub date: String,
}

pub trait EmailFetcher {
    fn fetch_all(&self) -> Result<Vec<Message>>;
}

use clap::Subcommand;

#[derive(Subcommand)]
pub enum ConnectCommands {
    /// 发送飞书群通知并 @ 指定成员
    Notice(notice::NoticeArgs),
}

#[derive(clap::Args)]
pub struct ConnectArgs {
    #[command(subcommand)]
    pub command: ConnectCommands,
}

pub fn dispatch(args: &ConnectArgs) {
    match &args.command {
        ConnectCommands::Notice(notice_args) => notice::run(notice_args),
    }
}
