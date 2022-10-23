// oifv_client runs within the host operating system and transfers
// NVIDIA device driver access into RPC that is then sent to the
// oifv_server running within the hypervisor
  
use clap::{Arg, App, crate_authors, crate_version};
use tokio::io::AsyncReadExt;
use tokio::net::{UnixListener, UnixStream};

#[tokio::main]
async fn main() {
    let matches = App::new("oifv_server")
        .version(crate_version!())
        .author(crate_authors!())
        .about("The oifv test server")
        .arg(
            Arg::with_name("listen")
                .long("listen")
                .short("l")
                .help("Port to listen for Virtio connections")
                .required(true)
                .takes_value(true),
        )
        .get_matches();

    let listen_port = matches
        .value_of("listen")
        .expect("port is required")
        .parse::<u32>()
        .expect("port must be a valid integer");

    let sock_path = format!("/tmp/ch.vsock_{}", listen_port);
    println!("Socket Path {:#?}", sock_path);

    let listener = UnixListener::bind(&sock_path).unwrap();

    loop {
        let (stream, _) = listener.accept().await.unwrap();
        handle_connection(stream).await;
    }
}

async fn handle_connection(mut stream: UnixStream) {
    let mut buffer = [0; 16];
    stream.read_exact(&mut buffer).await.unwrap();

    println!("buf {:#?}", buffer)
}
