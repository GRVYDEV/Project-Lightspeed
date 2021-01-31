<p align="center">
<a  href="https://github.com/GRVYDEV/Project-Lightspeed">
    <img src="images/lightspeedlogo.svg" alt="Logo" width="150" height="150">
</a>
</p>
  <h1 align="center">Project Lightspeed</h1>
<div align="center">
    <a href="https://github.com/GRVYDEV/Project-Lightspeed/stargazers"><img src="https://img.shields.io/github/stars/GRVYDEV/Project-Lightspeed" alt="Stars Badge"/></a>
    <a href="https://github.com/GRVYDEV/Project-Lightspeed/network/members"><img src="https://img.shields.io/github/forks/GRVYDEV/Project-Lightspeed" alt="Forks Badge"/></a>
    <a href="https://github.com/GRVYDEV/Project-Lightspeed/pulls"><img src="https://img.shields.io/github/issues-pr/GRVYDEV/Project-Lightspeed" alt="Pull Requests Badge"/></a>
    <a href="https://github.com/GRVYDEV/Project-Lightspeed/issues"><img src="https://img.shields.io/github/issues/GRVYDEV/Project-Lightspeed" alt="Issues Badge"/></a>
    <a href="https://github.com/GRVYDEV/Project-Lightspeed/graphs/contributors"><img alt="GitHub contributors" src="https://img.shields.io/github/contributors/GRVYDEV/Project-Lightspeed?color=2b9348"></a>
    <a href="https://github.com/GRVYDEV/Project-Lightspeed/blob/master/LICENSE"><img src="https://img.shields.io/github/license/GRVYDEV/Project-Lightspeed?color=2b9348" alt="License Badge"/></a>
</div>
<br />
<p align="center">
    A self contained OBS -> FTL -> WebRTC live streaming server. Comprised of 3 parts once configured anyone can achieve sub-second OBS to the browser livestreaming 
    <!-- <br /> -->
    <!-- <a href="https://github.com/GRVYDEV/Project-Lightspeed"><strong>Explore the docs »</strong></a> -->
    <br />
    <br />
    <a href="https://github.com/GRVYDEV/Project-Lightspeed">View Demo</a>
    ·
    <a href="https://github.com/GRVYDEV/Project-Lightspeed/issues">Report a Bug</a>
    ·
    <a href="https://github.com/GRVYDEV/Project-Lightspeed/issues">Request Features</a>
</p>

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
        <li><a href="#components">Components</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#docker">Docker / Compose</a></li>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a>
            <ul>
                <li><a href="#lightspeed-ingest">Lightspeed Ingest</a></li>
                <li><a href="#lightspeed-webrtc">Lightspeed WebRTC</a></li>
                <li><a href="#lightspeed-react">Lightspeed React</a></li>
            </ul>
        </li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#streaming-from-obs">Streaming From OBS</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#bugs">Bugs</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

<!-- [![Product Name Screen Shot][product-screenshot]](https://example.com) -->

This is Project Lightspeed. Project Lightspeed is a fully self-contained live streaming server. With this you will 
be able to deploy your own sub-second latency live streaming platform. This repository contains the instructions for 
installing and deploying the entire application.

### Built With

- Rust
- Golang
- React

### Components

- [Lightspeed Ingest](https://github.com/GRVYDEV/Lightspeed-ingest)
- [Lightspeed WebRTC](https://github.com/GRVYDEV/Lightspeed-webrtc)
- [Lightspeed React](https://github.com/GRVYDEV/Lightspeed-react)

<!-- GETTING STARTED -->

## Getting Started

In order to get a copy running you will need to install all 3 repositories. There are installation instructions in 
each repo however I will include them here for the sake of simplicity.

### Prerequisites

In order to run this [Golang](https://golang.org/doc/install), [Rust](https://www.rust-lang.org/tools/install), and [npm](https://www.npmjs.com/get-npm) are required. Additionally the Rust repo requires a C compiler. If you get a `linker cc not found` error then you need to install a C compiler.

### Installation

#### Lightspeed Ingest

```sh
git clone https://github.com/GRVYDEV/Lightspeed-ingest.git
cd Lightspeed-ingest
cargo build
```

#### Lightspeed WebRTC

Using go get

```sh
export GO111MODULE=on
go get github.com/GRVYDEV/lightspeed-webrtc
```

Using git

```sh
git clone https://github.com/GRVYDEV/Lightspeed-webrtc.git
cd Lightspeed-webrtc
export GO111MODULE=on
go build
```

#### Lightspeed React

```sh
git clone https://github.com/GRVYDEV/Lightspeed-react.git
cd Lightspeed-react
npm install
```

<!-- USAGE EXAMPLES -->

## Usage

#### Lightspeed Ingest

```sh
cd Lightspeed-ingest
cargo run --release
```

#### Lightspeed WebRTC

Using go get

```sh
lightspeed-webrtc --addr=XXX.XXX.XXX.XXX
```

Using git

```sh
cd Lightspeed-webrtc
go build
./lightspeed-webrtc --addr=XXX.XXX.XXX.XXX
```

##### Arguments

| Argument | Supported Values   | Notes                                                                                                                                                                                                                                                   |
| :------- | :----------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `--addr` | A valid IP address | This is the local Ip address of your machine. It defaults to localhost but 
should be set to your local IP. For example 10.17.0.5 This is where the server will listen for UDP packets and 
where it will host the websocket endpoint for SDP negotiation |

#### Lightspeed React
First you need to configure the websocket url in `src/wsUrl.js`. If you are using an IP then it will be the 
public IP of your machine if you have DNS then it will be your hostname.

You can host the static site locally using `serve` which can be found [here](https://www.npmjs.com/package/serve)

```sh
cd Lightspeed-react
npm build
serve -s build -l 80
```

This will serve the build folder on port 80 of your machine meaning it can be retreived via a browser by either 
going to your machines public IP or hostname

---

<!-- DOCKER -->
# Docker / Compose
Install docker and docker-compose (https://docs.docker.com/compose/install/)

```
# Install Docker
curl -fsSL get.docker.com | sh 

# Install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose
```

### Build

Until docker images are published to Docker Hub you will need to build each container image. In this directories 
parent folder clone the React, Ingest, and WebRTC repo's. See the `build: context:` in the `docker-compose.yaml` if 
you wish to specify different paths.

### Development
Use `docker-compose up` ensures the containers are checked for changes and rebuilt if needed. You will see logs for 
all containers.

### Run as daemon/detached
Use `docker-compose up -d` to start it detached and have it continue to run in the background. Use `docker ps` to
verify uptime, port forwarding, etc. 


### Configure containers
Containers are currently configured with a random stream key on boot. Other variables are set via Environment
Variables, see `.env` file. This is where you need to setup your IP/Hostname.


---

# Streaming From OBS

By default, since we are using the FTL protocol, you cannot just use a Custom server. You will need to edit 
your `services.json` file. It can be found at:
- Windows: `%AppData%\obs-studio\plugin_config\rtmp-services\services.json` 
- OSX: `/Users/YOURUSERNAME/Library/Application\ Support/obs-studio/plugin_config/rtmp-services/services.json`

Paste this into the services array and change the url to either the IP or the hostname of your Project Lightspeed server
```json
{
    "name": "Project Lightspeed",
    "common": false,
    "servers": [
        {
            "name": "SERVER TITLE HERE",
            "url": "your.lightspeed.hostname"
        }
    ],
    "recommended": {
        "keyint": 2,
        "output": "ftl_output",
        "max audio bitrate": 160,
        "max video bitrate": 8000,
        "profile": "main",
        "bframes": 0
    }
},
```

NOTE: You do not need to specify a port.

After restarting OBS you should be able to see your service in the OBS settings Stream pane.
(Special Thanks to [Glimesh](https://github.com/Glimesh) for these instructions)

---
<!-- ROADMAP -->

## Roadmap

I will be fleshing out the roadmap in the coming days. As of right now I want to get this to a point where it is 
as close to other live streaming services as possible. If there are any features that you want to see then feel 
free to suggest them!

See the [open issues](https://github.com/GRVYDEV/Project-Lightspeed/issues) for a list of proposed features 
(and known issues).

## Bugs

I am very from perfect and there are bound to be bugs and things I've overlooked in the installation process. 
Please, add issues and feel free to reach out if anything is unclear. Also, we have a Discord.

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. 
Any contributions you make are **greatly appreciated**. 

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE` for more information.

<!-- CONTACT -->

## Contact

Garrett Graves - [@grvydev](https://twitter.com/grvydev)

Project Link: [https://github.com/GRVYDEV/Project-Lightspeed](https://github.com/GRVYDEV/Project-Lightspeed)

<!-- ACKNOWLEDGEMENTS -->

## Acknowledgements

- [Sean Dubois](https://github.com/Sean-Der)
- [Hayden McAfee](https://github.com/haydenmc)

