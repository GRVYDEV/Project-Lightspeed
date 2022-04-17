FROM rust:latest as builder
WORKDIR /rust/src/
COPY . .
RUN cargo install --path .


FROM debian:buster-slim as lightspeed-ingest
RUN useradd -M -s /bin/bash lightspeed
WORKDIR /data
RUN chown lightspeed:root /data
COPY --from=builder --chown=lightspeed:lightspeed /usr/local/cargo/bin/lightspeed-ingest /usr/local/bin/lightspeed-ingest

USER lightspeed
CMD ["lightspeed-ingest"]

EXPOSE 8084