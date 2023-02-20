#!/usr/bin/env sh

cargo build --release

mkdir -p ../dist/

cp target/debug/lightspeed-ingest ../dist
