// oifv_client runs within the host operating system and transfers
// NVIDIA device driver access into RPC that is then sent to the
// oifv_server running within the hypervisor
  
use std::path::PathBuf;

use clap::{Parser, Subcommand};
use tokio::io::AsyncReadExt;
use tokio::net::{UnixListener, UnixStream};

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
    /// Start the OIFV client
    Start {
        /// Listen on unix vsock port
        #[arg(short, long)]
        port: u32,
    },
}

#[tokio::main]
async fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Some(Commands::Start { port } ) => {
            println!("Start OIFV client.");
            let sock_path = format!("/tmp/ch.vsock_{}", port);
            println!("Socket Path {:#?}", sock_path);

            let listener = UnixListener::bind(&sock_path).unwrap();

            loop {
                let (stream, _) = listener.accept().await.unwrap();
                handle_connection(stream).await;
            }
        }
        None => {}
    }
}

async fn handle_connection(mut stream: UnixStream) {
    let mut buffer = [0; 16];
    stream.read_exact(&mut buffer).await.unwrap();

    println!("buf {:#?}", buffer)
}
