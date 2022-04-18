#!/bin/bash -ex

## This is a bash script to install GRVYDEV/Project-Lightspeed on Ubuntu 20.04
## See the README for details:
## https://github.com/GRVYDEV/Project-Lightspeed/tree/main/contrib/ubuntu_installer


lightspeed_config() {
    ## You can edit these defaults, or you can override them in your environment.
    ## Environment vars use the same names except without the DEFAULT_ prefix.

    # TLS is off by default.
    # Turn on HTTPS and proxy the websocket by setting TLS_ON=true
    DEFAULT_TLS_ON=false
    # YOUR email address to register Lets Encrypt account (only when TLS_ON=true)
    DEFAULT_ACME_EMAIL=email@example.com

    # Domain name for your stream website (only when TLS_ON=true):
    DEFAULT_DOMAIN=stream.example.com

    # Try to automatically find public IP address
    # Or you can just set IP_ADDRESS=x.x.x.x
    DEFAULT_IP_ADDRESS=$(curl ifconfig.co/)

    # Git repositories:
    DEFAULT_INGEST_REPO=https://github.com/GRVYDEV/Lightspeed-ingest.git
    DEFAULT_WEBRTC_REPO=https://github.com/GRVYDEV/Lightspeed-webrtc.git
    DEFAULT_REACT_REPO=https://github.com/GRVYDEV/Lightspeed-react.git

    # Git branch, tag, or commit to compile (default is HEAD from mainline branch):
    DEFAULT_INGEST_GIT_REF=main
    DEFAULT_WEBRTC_GIT_REF=main
    DEFAULT_REACT_GIT_REF=master

    # Directory to clone git repositories
    DEFAULT_GIT_ROOT=/root/git
}

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
    GIT_ROOT=${GIT_ROOT:-$DEFAULT_GIT_ROOT}

    if [ ${TLS_ON} = 'true' ]; then
        WEBRTC_IP_ADDRESS=${IP_ADDRESS}
        WEBSOCKET_URL=wss://${DOMAIN}/websocket
    else
        WEBRTC_IP_ADDRESS=${IP_ADDRESS}
        WEBSOCKET_URL=ws://${IP_ADDRESS}:8080/websocket
    fi

    export HOME=/root

    ## Install packages:
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get -y install \
            golang \
            git \
            debian-keyring \
            debian-archive-keyring \
            apt-transport-https \
            curl \
            nginx \
            certbot \
            python3-certbot-nginx \
            gcc \
            libc6-dev

    ## Install latest nodejs and npm:
    curl -sL https://deb.nodesource.com/setup_15.x | bash -
    apt-get install -y nodejs

    ## Install latest rust version:
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source /root/.cargo/env

    ## Niceties:
    echo "set enable-bracketed-paste on" >> /root/.inputrc

    ## Install Project Lightspeed from source:
    # ingest:
    mkdir -p ${GIT_ROOT}
    cd ${GIT_ROOT}
    git clone ${INGEST_REPO} Lightspeed-ingest
    cd Lightspeed-ingest
    git checkout ${INGEST_GIT_REF}
    cargo build --release
    install target/release/lightspeed-ingest /usr/local/bin/lightspeed-ingest

    # webrtc:
    cd ${GIT_ROOT}
    git clone ${WEBRTC_REPO} Lightspeed-webrtc
    cd Lightspeed-webrtc
    git checkout ${WEBRTC_GIT_REF}
    GO111MODULE=on go build
    install lightspeed-webrtc /usr/local/bin/lightspeed-webrtc

    # react:
    cd ${GIT_ROOT}
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
Wants=network-online.target
[Service]
TimeoutStartSec=0
Environment=LS_INGEST_ADDR=${IP_ADDRESS}
ExecStart=/usr/local/bin/lightspeed-ingest
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF

    ## Create systemd service for webrtc:

    cat <<EOF | sed 's/@@@/$/g' > /etc/systemd/system/lightspeed-webrtc.service
[Unit]
Description=Project Lightspeed webrtc service
After=network-online.target
Wants=network-online.target
[Service]
TimeoutStartSec=0
Environment=IP_ADDRESS=${WEBRTC_IP_ADDRESS}
ExecStart=/usr/local/bin/lightspeed-webrtc --addr=@@@{IP_ADDRESS}
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
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
        proxy_set_header X-Real-IP @@@remote_addr;
        proxy_set_header X-Forwarded-For @@@proxy_add_x_forwarded_for;
        proxy_set_header Host @@@host;
        proxy_connect_timeout   24h;
        proxy_send_timeout      24h;
        proxy_read_timeout      24h;
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
