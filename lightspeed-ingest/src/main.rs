#[macro_use]
extern crate clap;
extern crate log;
extern crate simplelog;
use clap::App;
use log::info;
use simplelog::*;

mod connection;
mod ftl_codec;
use std::fs::File;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let default_bind_address = "0.0.0.0";
    // update cli.yml to add more flags
    let cli_cfg = load_yaml!("cli.yml");
    let matches = App::from_yaml(cli_cfg).get_matches();

    // Find an address and port to bind to. The search order is as follows:
    // 1.) command line argument
    // 2.) environment variable (LS_INGEST_ADDR)
    // 3.) Default to 0.0.0.0
    let bind_address: &str = match matches.value_of("address") {
        Some(addr) => {
            if addr.is_empty() {
                default_bind_address
            } else {
                addr
            }
        }
        None => default_bind_address,
    };

    let mut loggers: Vec<Box<dyn SharedLogger>> =
        vec![
            match TermLogger::new(LevelFilter::Info, Config::default(), TerminalMode::Mixed) {
                Some(termlogger) => termlogger,
                None => SimpleLogger::new(LevelFilter::Info, Config::default()),
            },
        ];
    if let Some(path) = matches.value_of("log-file") {
        if !path.is_empty() {
            loggers.push(WriteLogger::new(
                LevelFilter::Info,
                Config::default(),
                File::create(path).unwrap(),
            ))
        }
    };
    let _ = CombinedLogger::init(loggers);

    let stream_key_env = matches.value_of("stream-key");
    let _ = connection::read_stream_key(true, stream_key_env);
    info!("Listening on {}:8084", bind_address);
    let listener = TcpListener::bind(format!("{}:8084", bind_address)).await?;

    loop {
        // Wait until someone tries to connect then handle the connection in a new task
        let (socket, _) = listener.accept().await?;
        tokio::spawn(async move {
            connection::Connection::init(socket);
            // handle_connection(socket).await;
        });
    }
}
