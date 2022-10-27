// oifvctl is the OIFV caddle tool
use std::path::PathBuf;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]

struct Cli {
    /// Optional name to operate on
    name: Option<String>,

    /// Sets a custom config file
    #[arg(short, long, value_name = "FILE")]
    config: Option<PathBuf>,

    /// Turn debugging information on
    #[arg(short, long, action = clap::ArgAction::Count)]
    debug: u8,

    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Starts a command shell in the OIFV virtual driver
    Shell,
    /// Starts OIFV.
    Start,
}

fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Some(Commands::Shell) => {
            println!("Launch an OIFV shell.");
        }
        Some(Commands::Start) => {
            println!("Start OIFV.");
        }
        None => {}
    }
}
