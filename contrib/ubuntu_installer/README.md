# Project Lightspeed Ubuntu 20.04 installer

> **Warning**
> This script is designed for use on a **fresh install**. Please backup any existing configurations as some **will be overwritten** to install Lightspeed.
> If you would like an alternate solution that does not require a fresh installation, please consult the [official wiki](https://github.com/GRVYDEV/Project-Lightspeed/README.md) for a docker based setup guide.

Contained in this directory is a bash script to automatically install
[GRVYDEV/Project-Lightspeed](https://github.com/GRVYDEV/Project-Lightspeed) on
Ubuntu 20.04, compiled directly from source repositories, and install systemd
services to run them. This installation method does not use Docker.

## Config

The script can be configured directly via environment variables. Here is a list
of the variables that you can configure:

 * `TLS_ON` - if set `true`, nginx will use port 443 and run TLS encrypted HTTPs
   services (html+websocket). Requests on port 80 will redirect to port 443. A
   TLS certificate will be generated and signed by Let's Encrypt. You must also
   set `DOMAIN` and `ACME_EMAIL`.
 * `DOMAIN` - The domain name you want to use for the stream website. This is
   only required if `TLS_ON=true`.
 * `ACME_EMAIL` - Your email address, that you want to use to register with
   Let's Encrypt. This is only required if `TLS_ON=true`.
 * `IP_ADDRESS` - The public IP address of the server. If you don't set this,
   the script will try to find this automatically.

If you set `TLS_ON=true` (https:// for the stream website), the stream website
requires a domain name, and you need a personal email address to register with
Lets Encrypt. You will need to create a DNS `A` record for the domain pointing
to the IP address of your server. If you don't know the IP address of the server
until after you create it, you just need to be ready to create the DNS record
quickly as soon as you know the IP address. certbot will run at the very end of
the script, so you will have a few minutes with which to create the DNS record
before certbot will need it to be ready.

## Run

Example without TLS (no config necessary):

```bash
#!/bin/bash

curl -L https://raw.githubusercontent.com/GRVYDEV/Project-Lightspeed/main/contrib/ubuntu_installer/ubuntu_installer.sh | sudo -E bash -xe
```

Example with TLS (config is set as env vars):

```bash
#!/bin/bash

export TLS_ON=true
export DOMAIN=stream.example.com
export ACME_EMAIL=email@example.com

curl -L https://raw.githubusercontent.com/GRVYDEV/Project-Lightspeed/main/contrib/ubuntu_installer/ubuntu_installer.sh | sudo -E bash -xe
```

## Get your stream key

Once the script finishes, these new services will have been created:

 * `lightspeed-ingest`
 * `lightspeed-webrtc`
 * `nginx`
 
In order to start streaming, you need the stream key, which is printed in the
log for the `lightspeed-ingest` service. You can view the log this way:

```bash
journalctl --unit lightspeed-ingest.service --no-pager
```

## Run with cloud-init

cloud-init lets you run this script on a new server, automatically, when you
create the server.

You can use this on DigitalOcean, or any other cloud host that supports
cloud-init. Here's the directions for DigitalOcean:

 * Create an account or sign in with your existing one.
 * [Create a new droplet](https://cloud.digitalocean.com/droplets/new)
 * Choose a plan. This is tested to work on the smallest $5 plan.
 * Choose `Ubuntu 20.04 (LTS) x64` (default)
 * Under `Select additional options` check the box `User data`.
 * Enter the install script in the text area marked `Enter user data here...`
 * You can use any of the same examples Run from above. Make sure to include the
   first line `#!/bin/bash` and the exported variables you want (if any).
 * Review the rest of the droplet options and click Create Droplet.
 
Now the droplet is being created. If you chose to set `TLS_ON=true`, you now
need to copy the IP address of the new droplet, and create a DNS `A` record for
your chosen `DOMAIN` (instructions vary depending on your domain DNS provider).

Login to the droplet as root via SSH. (`ssh root@${IP_ADDRESS}`)

From the server, you can watch the cloud-init script log file as it runs:

```bash
tail -f /var/log/cloud-init-output.log
```

You can also show the status:

```bash
cloud-init status -w
```

Using the `-w` argument, cloud-init will wait for the script to finish before
printing anything. After waiting for the script to finish, it will print
`status: done` or `status: error` depending on if the script ran successfully or
not.

