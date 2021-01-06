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
<a href="https://discord.gg/KThyC4gkWH"><img src="https://img.shields.io/discord/796390666673324073.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2"></a>

</div>
<br />
<p align="center">
  <p align="center">
    A self contained OBS -> FTL -> WebRTC live streaming server. Comprised of 3 parts once configured anyone can achieve sub-second OBS to the browser livestreaming 
    <!-- <br /> -->
    <!-- <a href="https://github.com/GRVYDEV/Project-Lightspeed"><strong>Explore the docs »</strong></a> -->
    <br />
    <br />
    <a href="https://github.com/GRVYDEV/Project-Lightspeed">View Demo</a>
    ·
    <a href="https://github.com/GRVYDEV/Project-Lightspeed/issues">Report Bug</a>
    ·
    <a href="https://github.com/GRVYDEV/Project-Lightspeed/issues">Request Feature</a>
  </p>
</p>

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#how-it-works">How It Works</a></li>
        <li><a href="#built-with">Built With</a></li>
        <li><a href="#components">Components</a></li>
      </ul>
    </li>
    <li><a href="discord">Discord</a></li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
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
    <li><a href="#streaming-from-obs">Streaming From OBS</a>
        <ul>
            <li><a href="#stream-key">Stream Key</a></li>
        </ul>
    </li>  
    <li><a href="help">Help</a></li>
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

Project Lightspeed is a fully self contained live streaming server. With Lightspeed you will be able to deploy your own sub-second latency live streaming platform. The Lightspeed repository contains the instructions for installing and deploying the entire application. So far, Lightspeed includes an ingest service, broadcast service via webRTC and a web application for viewing. Lightspeed is however completely modular. What this means is that you can write your own web app, ingest server or broadcast server. As of right now it is not as modular as it could be and I will be working on improving that in the future.


### How It Works

Lightspeed Ingest listens on port 8084 which is the port used by the FTL protocol. Upon receiving a connection it completes the FTL handshake and negotiates a port (this is currently bugged however and defaults to 65535). Once the negotiation is done Lightspeed WebRTC listens on the negotiated port (in the future Lightspeed WebRTC will listen on the loopback interface so the ingest has more control on what packets we accept) and relays the incoming RTP packets over WebRTC. Lightspeed React communicates via websocket with Lightspeed WebRTC to exchange ICE Candidates and once a connection is established the video can be viewed.
### Built With

- Rust
- Golang
- React

### Components

- [Lightspeed Ingest](https://github.com/GRVYDEV/Lightspeed-ingest)
- [Lightspeed WebRTC](https://github.com/GRVYDEV/Lightspeed-webrtc)
- [Lightspeed React](https://github.com/GRVYDEV/Lightspeed-react)

## Discord
We now have a [Discord](https://discord.gg/UpQZANPYmZ) server! This is a great way to stay up to date with the project and join in on the conversation! Come stop by!

<!-- GETTING STARTED -->

## Getting Started

In order to get Lightspeed running you will need to install all 3 repositories. There are installation instructions in each repository however I will include them here for the sake of simplicity.

### Prerequisites

In order to run Lightspeed, [Golang](https://golang.org/doc/install), [Rust](https://www.rust-lang.org/tools/install), and [npm](https://www.npmjs.com/get-npm) are required. Additionally the Rust repo requires a C compiler. If you get a `linker cc not found` error then you need to install a C compiler.

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
| `--addr` | A valid IP address | This is the local Ip address of your machine. It defaults to localhost but should be set to your local IP. For example 10.17.0.5 This is where the server will listen for UDP packets and where it will host the websocket endpoint for SDP negotiation |

#### Lightspeed React

You should then configure the websocket URL in `config.json` in the `build` directory. If you are using an IP then it will be the public IP of your machine if you have DNS then it will be your hostname.

**Note**: The websocket port is hardcoded meaning that Lightspeed-webrtc will always serve it on port 8080 (this may change in the future) so for the websocket config it needs to be `ws://IP_or_Hostname:8080/websocket

You can host the static site locally using `serve` which can be found [here](https://www.npmjs.com/package/serve)

**Note**: your version of `serve` may require the `-p` flag instead of `-l` for the port
```sh
cd Lightspeed-react
npm run build
serve -s build -l 80
```

The above will serve the build folder on port 80.

View Lightspeed in your web browser by visiting http://hostname or http://your.ip.address.here


<!-- _For more examples, please refer to the [Documentation](https://example.com)_ -->

## Streaming From OBS

By default since we are using the FTL protocol you cannot just use a custom server. You will need to edit your `services.json` file. It can be found at:

**Note**: Not all versions of Linux have access to OBS with the FTL SDK built in. If you are on Linux and you cannot stream to Lightspeed this may be the issue.

Linux: `~/.config/obs-studio/plugin_config/rtmp-services/services.json`

Windows: `%AppData%\obs-studio\plugin_config\rtmp-services\services.json`

Mac: `/Users/YOURUSERNAME/Library/Application\ Support/obs-studio/plugin_config/rtmp-services/services.json`

Paste the below into the services array and change the url to either the IP or the hostname of your Project Lightspeed server

**Note**: for the url it is not prefaced by anything. For example, given an IP of 10.0.0.2 you would put `"url": "10.0.0.2"` You do not need to indicate a port since the FTL protocol always uses 8084
```json
{
    "name": "Project Lightspeed",
    "common": false,
    "servers": [
        {
            "name": "SERVER NAME HERE",
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

After restarting OBS you should be able to see your service in the OBS settings pane
(Special Thanks to [Glimesh](https://github.com/Glimesh) for these instructions)

### Stream Key
By default the stream key is `123456789-aBcDeFgHiJkLmNoPqRsTuVwXyZ123456` This can be changed by editing line 248 in `src/connection.rs` in the Lighspeed Ingest project. In the future I will develop a system that makes it easier to reset and manage your stream key 

## Help
This project is still very much a work in progress and a lot of improvements will be made to the deployment process. If something is unclear or you are stuck there are two main ways you can get help.

1. [Discord](https://discord.gg/UpQZANPYmZ) - this is the quickest and easiest way I will be able to help you through some deployment issues.
2. [Create and Issue](https://github.com/GRVYDEV/Project-Lightspeed/issues) - this is another way you can bring attention to something that you want fixed. 

<!-- ROADMAP -->

## Roadmap

I will be fleshing out the roadmap in the coming days. As of right now I want to get Lightspeed to a point where it is as close to other live streaming services as possible. If there are any features that you want to see then feel free to suggest them!

See the [open issues](https://github.com/GRVYDEV/Project-Lightspeed/issues) for a list of proposed features (and known issues).

## Bugs

I am very far from perfect and there are bound to be bugs and things I've overlooked in the installation process. Please add issues and feel free to reach out if anything is unclear. If Lightspeed gets enough attention I can make a Discord server where I can more easily interact with people.

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**. 

1. Fork the Project
2. Create your Feature Branch: ``git checkout -b feature/AmazingFeature``
3. Commit your Changes: ``git commit -m 'Add some AmazingFeature'``
4. Push to the Branch: ``git push origin feature/AmazingFeature``
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

