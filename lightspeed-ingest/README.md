<p align="center">
<a  href="https://github.com/GRVYDEV/Lightspeed-ingest">
    <img src="images/lightspeedlogo.svg" alt="Logo" width="150" height="150">
</a>
</p>
  <h1 align="center">Project Lightspeed Ingest</h1>
<div align="center">
  <a href="https://github.com/GRVYDEV/Lightspeed-ingest/stargazers"><img src="https://img.shields.io/github/stars/GRVYDEV/Lightspeed-ingest" alt="Stars Badge"/></a>
<a href="https://github.com/GRVYDEV/Lightspeed-ingest/network/members"><img src="https://img.shields.io/github/forks/GRVYDEV/Lightspeed-ingest" alt="Forks Badge"/></a>
<a href="https://github.com/GRVYDEV/Lightspeed-ingest/pulls"><img src="https://img.shields.io/github/issues-pr/GRVYDEV/Lightspeed-ingest" alt="Pull Requests Badge"/></a>
<a href="https://github.com/GRVYDEV/Lightspeed-ingest/issues"><img src="https://img.shields.io/github/issues/GRVYDEV/Lightspeed-ingest" alt="Issues Badge"/></a>
<a href="https://github.com/GRVYDEV/Lightspeed-ingest/graphs/contributors"><img alt="GitHub contributors" src="https://img.shields.io/github/contributors/GRVYDEV/Lightspeed-ingest?color=2b9348"></a>
<a href="https://github.com/GRVYDEV/Lightspeed-ingest/blob/master/LICENSE"><img src="https://img.shields.io/github/license/GRVYDEV/Lightspeed-ingest?color=2b9348" alt="License Badge"/></a>
</div>
<br />
<p align="center">
  <p align="center">
    A FTL handshake server written in Rust. This server listens on port 8084 and performs the FTL handshake with incoming connections
    <!-- <br /> -->
    <!-- <a href="https://github.com/GRVYDEV/Lightspeed-ingest"><strong>Explore the docs »</strong></a> -->
    <br />
    <br />
    <a href="https://youtu.be/Dzin4_A8RDs">View Demo</a>
    ·
    <a href="https://github.com/GRVYDEV/Lightspeed-ingest/issues">Report Bug</a>
    ·
    <a href="https://github.com/GRVYDEV/Lightspeed-ingest/issues">Request Feature</a>
  </p>
</p>

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#streaming-from-obs">Streaming From OBS</a>
        <ul>
            <li><a href="#stream-key">Stream Key</a></li>
        </ul>  
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

<!-- [![Product Name Screen Shot][product-screenshot]](https://example.com) -->

This is one of three components required for Project Lightspeed. Project Lightspeed is a fully self contained live streaming server. With this you will be able to deploy your own sub-second latency live streaming platform. This particular repository performs the FTL handshake with clients. It verifies the stream key and negotiates a port with the client connection that we will accept RTP packets on. In order for this to work the Project Lightspeed WebRTC is required in order to accept and broadcast the RTP packets. In order to view the live stream the Project Lightspeed React is required.

### Built With

- Rust

### Dependencies

- [Lightspeed WebRTC](https://github.com/GRVYDEV/Lightspeed-webrtc)
- [Lightspeed React](https://github.com/GRVYDEV/Lightspeed-react)

<!-- GETTING STARTED -->

## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

In order to run this Rust is required. Installation instructions can be found <a href="https://www.rust-lang.org/tools/install">here</a>. A C compiler is required as well. If you get a `linker cc not found error` try installing a C compiler

### Installation

```sh
git clone https://github.com/GRVYDEV/Lightspeed-ingest.git
cd Lightspeed-ingest
cargo build
```

<!-- USAGE EXAMPLES -->

## Usage
To print out full command line usage information.

```sh
cargo run -- -h
```

To run it with default settings type the following command. 

```sh
cargo run --release
```

To specify which address to bind to.

```sh
cargo run --release -- -a 12.34.56.78
```

<!-- _For more examples, please refer to the [Documentation](https://example.com)_ -->


## Streaming From OBS

By default since we are using the FTL protocol you cannot just use a custom server. You will need to edit your `services.json` file. It can be found at `%AppData%\obs-studio\plugin_config\rtmp-services\services.json` on Windows and `/Users/YOURUSERNAME/Library/Application\ Support/obs-studio/plugin_config/rtmp-services/services.json`

Paste this into the services array and change the url to either the IP or the hostname of your Project Lightspeed server
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
By default on first time startup a new stream key will be generated and output to the terminal for you. In order 
to regenerate this key simply delete the file it generates called `hash`. Simply copy the key output in the terminal 
to OBS and you are all set! This key WILL NOT change unless the `hash` file is deleted.

You can assign a static key by passing `--stream-key mykey` or via environment variable `STREAM_KEY=mykey`. If you 
assign it manually it will become prefixed with `77-` so the result will be `77-mykey`. You can verify this in the boot 
logs.


<img src="images/streamkey-example.png" alt="Streamkey example">

<!-- ROADMAP -->

## Roadmap

See the [open issues](https://github.com/GRVYDEV/Lightspeed-ingest/issues) for a list of proposed features (and known issues).

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

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

Project Link: [https://github.com/GRVYDEV/Lightspeed-ingest](https://github.com/GRVYDEV/Lightspeed-ingest)

<!-- ACKNOWLEDGEMENTS -->

## Acknowledgements

- [Sean Dubois](https://github.com/Sean-Der)
- [Hayden McAfee](https://github.com/haydenmc)


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->


