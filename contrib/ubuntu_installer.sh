#!/bin/bash -ex

## Note: before running this, you may wish to edit the lightspeed_config
## function below (review all of the variables that start with the `DEFAULT_`
## prefix). You may also set variables in your shell environment to override the
## default values (same names, but without the `DEFAULT_` prefix).

## This is a bash script to install GRVYDEV/Project-Lightspeed on Ubuntu 20.04,
## from source code. In addition, the nginx webserver and certbot will be
## installed (Lets Encrypt TLS certificate will automatically be created if you
## set TLS_ON=true and set DOMAIN). This script should be run as root, or
## invoked from cloud-init. (On DigitalOcean, create a droplet and copy-paste
## this *entire file* into the droplet `User Data` text area, and edit the
## DEFAULT variables below. The droplet will run this script automatically when
## it is created.)

## If you are you using cloud-init, you can watch the output of this script, run:
##   tail -f /var/log/cloud-init-output.log
## Or you can wait for it to finish by running:
##   cloud-init status -w
## (this should eventually say `status: done` and not `status: error`)

## Once the ingest service has started, you can view the logs to find your stream key:
##   journalctl --unit lightspeed-ingest.service --no-pager

## If you set DEFAULT_TLS_ON=true (or TLS_ON=true from the environment), nginx
## will be configured for TLS, and automatically redirect http traffic to https.
## The websocket will be proxied as a secure websocket (wss:// instead of ws://)
## This requires a proper DNS entry for your DOMAIN. If you know your IP address
## ahead of time, create the DNS entry first, before running this script. If you
## are running this on DigitalOcean via cloud-init, you won't know the IP
## address until after you create the droplet, so you must act quickly:
## immediately after you create the droplet, find the IP address, and create the
## DNS entry for the chosen DEFAULT_DOMAIN. certbot runs at the very end of this
## script, so it will not need this for several minutes, so you have a bit of
## time to set the DNS entry before it needs it.

## EDIT THIS CONFIG HERE:
lightspeed_config() {
    # TLS is off by default.
    # Turn on HTTPS and proxy the websocket by setting DEFAULT_TLS_ON=true
    DEFAULT_TLS_ON=false
    # YOUR email address to register Lets Encrypt account (only when TLS_ON=true)
    DEFAULT_ACME_EMAIL=email@example.com

    # Domain name for your stream website (only when TLS_ON=true):
    DEFAULT_DOMAIN=stream.example.com

    # Automatically get the public IP address of DigitalOcean droplet via metadata URL:
    # (You might need a different command if you're not using DigitalOcean)
    # Alternatively, you can set DEFAULT_IP_ADDRESS=x.x.x.x if you know it already:
    DEFAULT_IP_ADDRESS=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)

    # Git repositories:
    DEFAULT_INGEST_REPO=https://github.com/GRVYDEV/Lightspeed-ingest.git
    DEFAULT_WEBRTC_REPO=https://github.com/GRVYDEV/Lightspeed-webrtc.git
    DEFAULT_REACT_REPO=https://github.com/GRVYDEV/Lightspeed-react.git

    # Git branch, tag, or commit to compile (default is HEAD from mainline branch):
    DEFAULT_INGEST_GIT_REF=master
    DEFAULT_WEBRTC_GIT_REF=main
    DEFAULT_REACT_GIT_REF=master
}


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

lightspeed_install() {
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
    ACME_EMAIL=${ACME_EMAIL:-$DEFAULT_ACME_EMAIL}

    if [ ${TLS_ON} = 'true' ]; then
        WEBRTC_IP_ADDRESS=${IP_ADDRESS}
        WEBSOCKET_URL=wss://${DOMAIN}/websocket
    else
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
            curl \
            nginx \
            certbot \
            python3-certbot-nginx

    ## Latest rust version:
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source /root/.cargo/env

    ## Niceties:
    echo "set enable-bracketed-paste on" >> /root/.inputrc


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

    cat <<EOF > /etc/systemd/system/lightspeed-ingest.service
[Unit]
Description=Project Lightspeed ingest service
After=network-online.target

[Service]
TimeoutStartSec=0
Environment=LS_INGEST_ADDR=${IP_ADDRESS}
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

    ## Configure TLS with certbot:

    if [ ${TLS_ON} = 'true' ]; then
        certbot -n register --agree-tos -m ${ACME_EMAIL}
        certbot -n --nginx --domains ${DOMAIN}
        cat <<EOF | sed 's/@@@/$/g' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 301 https://@@@host@@@request_uri;
}

server {
    server_name ${DOMAIN};
    listen 443 ssl;
    listen [::]:443 ssl ipv6only=on;
    root /var/www/html;
    index index.html;
    location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        try_files @@@uri @@@uri/ =404;
    }
    location /websocket {
        proxy_pass http://${IP_ADDRESS}:8080/websocket;
        proxy_http_version 1.1;
        proxy_set_header Upgrade @@@http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host @@@host;
    }
    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}
EOF

        systemctl restart nginx
    fi
}

## Configure and install:
lightspeed_config
lightspeed_install


## END
