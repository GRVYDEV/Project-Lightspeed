FROM rust

WORKDIR /rust/src/
RUN git clone https://github.com/GRVYDEV/Lightspeed-ingest.git
WORKDIR /rust/src/Lightspeed-ingest
RUN cargo build

EXPOSE 8084

CMD cargo run --release
