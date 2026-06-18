pub mod user;

use clap::Subcommand;

#[derive(Subcommand)]
pub enum AuthCommands {
    /// 用户档案管理
    User(user::UserArgs),
}

#[derive(clap::Args)]
pub struct AuthArgs {
    #[command(subcommand)]
    pub command: AuthCommands,
}

pub fn dispatch(args: &AuthArgs) {
    match &args.command {
        AuthCommands::User(user_args) => user::dispatch(user_args),
    }
}
