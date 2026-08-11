use clap::Parser;

#[derive(Parser)]
#[command(name = "qtadmin", version, about = "QuantTide Admin CLI")]
pub struct Cli;

pub fn run() {
    let _ = Cli::parse();
}
