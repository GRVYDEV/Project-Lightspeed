use bytes::{Buf, BufMut, BytesMut};

use std::collections::HashMap;
use std::{fmt, io};
use tokio_util::codec::{Decoder, Encoder};

#[derive(Debug)]
pub enum FtlCommand {
    HMAC,
    Connect { data: HashMap<String, String> },
    Ping,
    Dot,
    Attribute { data: HashMap<String, String> },
    Disconnect,
}
#[derive(Clone, Debug, Eq, PartialEq, Ord, PartialOrd, Hash)]
pub struct FtlCodec {
    command_buffer: std::vec::Vec<u8>,
}

impl FtlCodec {
    pub fn new() -> FtlCodec {
        FtlCodec {
            command_buffer: Vec::new(),
        }
    }

    pub fn reset(&mut self) {
        self.command_buffer = Vec::new();
    }
}

impl Decoder for FtlCodec {
    type Item = FtlCommand;
    type Error = FtlError;
    fn decode(&mut self, buf: &mut BytesMut) -> Result<Option<FtlCommand>, FtlError> {
        let command: String;
        let mut data: HashMap<String, String> = HashMap::new();
        match buf.windows(4).position(|window| window == b"\r\n\r\n") {
            Some(index) => {
                command = String::from_utf8_lossy(&buf[..index]).to_string();
                buf.advance(index + 4);
                if command.as_str().contains("HMAC") {
                    self.reset();
                    Ok(Some(FtlCommand::HMAC))
                } else if command.as_str().contains("DISCONNECT") {
                    self.reset();
                    Ok(Some(FtlCommand::Disconnect))
                } else if command.as_str().contains("CONNECT") {
                    let commands: Vec<&str> = command.split(' ').collect();
                    let mut key = commands[2].to_string();
                    key.remove(0);
                    data.insert("channel_id".to_string(), commands[1].to_string());
                    data.insert("stream_key".to_string(), key);
                    self.reset();
                    Ok(Some(FtlCommand::Connect { data }))
                } else if command.as_str().contains(':') {
                    let commands: Vec<&str> = command.split(':').collect();
                    data.insert("key".to_string(), commands[0].to_string());
                    data.insert("value".to_string(), commands[1].trim().to_string());
                    self.reset();
                    Ok(Some(FtlCommand::Attribute { data }))
                } else if command.as_str().contains('.') && command.len() == 1 {
                    self.reset();
                    Ok(Some(FtlCommand::Dot))
                } else if command.as_str().contains("PING") {
                    self.reset();
                    Ok(Some(FtlCommand::Ping))
                } else {
                    self.reset();
                    Err(FtlError::Unsupported(command))
                }
            }
            None => Ok(None),
        }
    }
}
impl<T> Encoder<T> for FtlCodec
where
    T: AsRef<str>,
{
    type Error = FtlError;

    fn encode(&mut self, line: T, buf: &mut BytesMut) -> Result<(), FtlError> {
        let line = line.as_ref();
        buf.reserve(line.len());
        buf.put(line.as_bytes());
        Ok(())
    }
}
#[derive(Debug)]
pub enum FtlError {
    // ConnectionClosed,
    Unsupported(String),
    // CommandNotFound,
    Io(io::Error),
}
impl fmt::Display for FtlError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            // FtlError::ConnectionClosed => write!(f, "Connection Closed"),
            // FtlError::CommandNotFound => write!(f, "Command not read"),
            FtlError::Io(e) => write!(f, "{}", e),
            FtlError::Unsupported(s) => {
                write!(f, "Unsupported FTL Command {}! Bug GRVY to support this", s)
            }
        }
    }
}
impl From<io::Error> for FtlError {
    fn from(e: io::Error) -> FtlError {
        FtlError::Io(e)
    }
}
impl std::error::Error for FtlError {}
