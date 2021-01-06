#!/bin/bash -e

## Note: before running this, you may wish to edit the default variables at the
## top of this script. You may also set variables in your environment to
## override the default values.

## This is a bash script to install GRVYDEV/Project-Lightspeed on Ubuntu 20.04,
## from source code. In addition, the Caddy webserver will be installed (which
## can optionally provide TLS certificate from Lets Encrypt, and secure-proxy
## the websocket). This script should be run as root, or invoked from
## cloud-init. (On DigitalOcean, create a droplet and copy-paste this *entire
## file* into the droplet `User Data` text area, and edit the DEFAULT variables
## below. The droplet will run this script automatically when it is created.)

## If you are you using cloud-init, you can watch the output of this script, run:
##   tail -f /var/log/cloud-init-output.log
## Or you can wait for it to finish by running:
##   cloud-init status -w
## (this should eventually say `status: done` and not `status: error`)

## Once the ingest service has started, you can view the logs to find your stream key:
##   journalctl --unit lightspeed-ingest.service

#### Default variables you may wish to edit:
# TLS is off by default. Turn on HTTPS and proxy the websocket by setting DEFAULT_TLS_ON=true
## NOTE: TLS is BROKEN at the moment, keep this as `false` at least for now:
DEFAULT_TLS_ON=false

# Domain name for your stream website (setting only required if DEFAULT_TLS_ON=true):
DEFAULT_DOMAIN=stream.example.com

# Automatically get the public IP address of DigitalOcean droplet via metadata URL:
# (You might need a different command if you're not using DigitalOcean)
# Alternatively, you can set IP_ADDRESS=x.x.x.x if you know it already:
DEFAULT_IP_ADDRESS=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)

# Generate a new random stream key:
DEFAULT_STREAM_KEY=$RANDOM-$(openssl rand -hex 16)

# Git repositories:
## NOTE: Using ingest fork that includes random stream key generation:
DEFAULT_INGEST_REPO=https://github.com/obviyus/Lightspeed-ingest.git
DEFAULT_WEBRTC_REPO=https://github.com/GRVYDEV/Lightspeed-webrtc.git
DEFAULT_REACT_REPO=https://github.com/GRVYDEV/Lightspeed-react.git

# Git branch, tag, or commit to compile (default is HEAD from mainline branch):
## NOTE: Using streamkey branch that includes random stream key generation:
DEFAULT_INGEST_GIT_REF=streamkey
DEFAULT_WEBRTC_GIT_REF=main
DEFAULT_REACT_GIT_REF=master


## END CONFIG
## You shouldn't need to edit anything below this line.
##
##
##
##
##
##
##
##

## Load environment variables that possibly override default values:
# (env vars are the same names as above, except without `DEFAULT_` prefix)
TLS_ON=${TLS_ON:-$DEFAULT_TLS_ON}
DOMAIN=${DOMAIN:-$DEFAULT_DOMAIN}
IP_ADDRESS=${IP_ADDRESS:-$DEFAULT_IP_ADDRESS}
INGEST_REPO=${INGEST_REPO:-$DEFAULT_INGEST_REPO}
WEBRTC_REPO=${WEBRTC_REPO:-$DEFAULT_WEBRTC_REPO}
REACT_REPO=${REACT_REPO:-$DEFAULT_REACT_REPO}
INGEST_GIT_REF=${INGEST_GIT_REF:-$DEFAULT_INGEST_GIT_REF}
WEBRTC_GIT_REF=${WEBRTC_GIT_REF:-$DEFAULT_WEBRTC_GIT_REF}
REACT_GIT_REF=${REACT_GIT_REF:-$DEFAULT_REACT_GIT_REF}

if [ ${TLS_ON} = 'true' ]; then
    CADDY_DOMAIN=${DOMAIN}
    WEBRTC_IP_ADDRESS=127.0.0.1
    WEBSOCKET_URL=wss://${DOMAIN}/api/websocket
else
    CADDY_DOMAIN=":80"
    WEBRTC_IP_ADDRESS=${IP_ADDRESS}
    WEBSOCKET_URL=ws://${IP_ADDRESS}:8080/websocket
fi

export HOME=/root
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y install \
        golang \
        nodejs \
        npm \
        git \
        debian-keyring \
        debian-archive-keyring \
        apt-transport-https \
        curl

## Latest rust version:
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source /root/.cargo/env

## Niceties:
echo "set enable-bracketed-paste on" >> /root/.inputrc

## Caddy:
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/cfg/gpg/gpg.155B6D79CA56EA34.key' | sudo apt-key add -
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/cfg/setup/config.deb.txt?distro=debian&version=any-version' | sudo tee -a /etc/apt/sources.list.d/caddy-stable.list
apt-get update
apt-get install -y caddy
cat <<EOF > /etc/caddy/Caddyfile
${CADDY_DOMAIN} {
  root * /var/www/html
  file_server
  handle_path /api/* {
    uri strip_prefix /api
    reverse_proxy 127.0.0.1:8080
  }
}
EOF
systemctl restart caddy

## Install Project Lightspeed from source:
# ingest:
mkdir -p /root/git
cd /root/git
git clone ${INGEST_REPO} Lightspeed-ingest
cd Lightspeed-ingest
git checkout ${INGEST_GIT_REF}
cargo build --release
install target/release/lightspeed-ingest /usr/local/bin/lightspeed-ingest

# webrtc:
cd /root/git
git clone ${WEBRTC_REPO} Lightspeed-webrtc
cd Lightspeed-webrtc
git checkout ${WEBRTC_GIT_REF}
GO111MODULE=on go build
install lightspeed-webrtc /usr/local/bin/lightspeed-webrtc

# react:
cd /root/git
git clone ${REACT_REPO} Lightspeed-react
cd Lightspeed-react
git checkout ${REACT_GIT_REF}
npm install
npm run build
mkdir -p /var/www/html
cp -a build/* /var/www/html
cat <<EOF > /var/www/html/config.json
{
  "wsUrl": "${WEBSOCKET_URL}"
}
EOF

## Create systemd service for ingest:

cat <<'EOF' > /etc/systemd/system/lightspeed-ingest.service
[Unit]
Description=Project Lightspeed ingest service
After=network-online.target

[Service]
TimeoutStartSec=0
ExecStart=/usr/local/bin/lightspeed-ingest
Restart=always
RestartSec=60

[Install]
WantedBy=network-online.target
EOF

## Create systemd service for webrtc:

cat <<EOF | sed 's/@@@/$/g' > /etc/systemd/system/lightspeed-webrtc.service
[Unit]
Description=Project Lightspeed webrtc service
After=network-online.target

[Service]
TimeoutStartSec=0
Environment=IP_ADDRESS=${WEBRTC_IP_ADDRESS}
ExecStart=/usr/local/bin/lightspeed-webrtc --addr=@@@{IP_ADDRESS}
Restart=always
RestartSec=60

[Install]
WantedBy=network-online.target
EOF

## Install and start services:

systemctl daemon-reload
systemctl enable --now lightspeed-ingest
systemctl enable --now lightspeed-webrtc

