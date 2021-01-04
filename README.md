<p align="center">
<a  href="https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed">
    <img src="images/lightspeedlogo.svg" alt="Logo" width="150" height="150">
</a>
</p>
  <h1 align="center">Project Lightspeed</h1>
<div align="center">
  <a href="https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed/stargazers"><img src="https://img.shields.io/github/stars/GRVYDEV/Lightspeed-Project-Lightspeed" alt="Stars Badge"/></a>
<a href="https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed/network/members"><img src="https://img.shields.io/github/forks/GRVYDEV/Lightspeed-Project-Lightspeed" alt="Forks Badge"/></a>
<a href="https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed/pulls"><img src="https://img.shields.io/github/issues-pr/GRVYDEV/Lightspeed-Project-Lightspeed" alt="Pull Requests Badge"/></a>
<a href="https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed/issues"><img src="https://img.shields.io/github/issues/GRVYDEV/Lightspeed-Project-Lightspeed" alt="Issues Badge"/></a>
<a href="https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed/graphs/contributors"><img alt="GitHub contributors" src="https://img.shields.io/github/contributors/GRVYDEV/Lightspeed-Project-Lightspeed?color=2b9348"></a>
<a href="https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed/blob/master/LICENSE"><img src="https://img.shields.io/github/license/GRVYDEV/Lightspeed-Project-Lightspeed?color=2b9348" alt="License Badge"/></a>
</div>
<br />
<p align="center">
  <p align="center">
    A self contained OBS -> FTL -> WebRTC live streaming server. Comprised of 3 parts once configured anyone can achieve sub-second OBS to the browser livestreaming 
    <!-- <br /> -->
    <!-- <a href="https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed"><strong>Explore the docs »</strong></a> -->
    <br />
    <br />
    <a href="https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed">View Demo</a>
    ·
    <a href="https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed/issues">Report Bug</a>
    ·
    <a href="https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed/issues">Request Feature</a>
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
        <li><a href="#components">Components</a></li>
      </ul>
    </li>
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

This is one of three components required for Project Lightspeed. Project Lightspeed is a fully self contained live streaming server. With this you will be able to deploy your own sub-second latency live streaming platform. This particular repository takes RTP packets sent to the server and broadcasts them over WebRTC. In order for this to work the Project Lightspeed Ingest server is required to perfrom the FTL handshake with OBS. In order to view the live stream the Project Lightspeed viewer is required.

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

In order to get a copy running you will need to install all 3 repositories. There are installation instructions in each repo however I will include them here for the sake of simplicity.

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

To run type the following command.

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

#### Arguments

| Argument | Supported Values   | Notes                                                                                                                                                                                                                                                   |
| :------- | :----------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `--addr` | A valid IP address | This is the local Ip address of your machine. It defaults to localhost but should be set to your local IP. For example 10.17.0.5 This is where the server will listen for UDP packets and where it will host the websocket endpoint for SDP negotiation |

<!-- _For more examples, please refer to the [Documentation](https://example.com)_ -->

<!-- ROADMAP -->

## Roadmap

See the [open issues](https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed/issues) for a list of proposed features (and known issues).

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

Project Link: [https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed](https://github.com/GRVYDEV/Lightspeed-Project-Lightspeed)

<!-- ACKNOWLEDGEMENTS -->

## Acknowledgements

- [Sean Dubois](https://github.com/Sean-Der)
- [Hayden McAfee](https://github.com/haydenmc)

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/GRVYDEV/repo.svg?style=for-the-badge
[contributors-url]: https://github.com/GRVYDEV/repo/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/GRVYDEV/repo.svg?style=for-the-badge
[forks-url]: https://github.com/GRVYDEV/repo/network/members
[stars-shield]: https://img.shields.io/github/stars/GRVYDEV/repo.svg?style=for-the-badge
[stars-url]: https://github.com/GRVYDEV/repo/stargazers
[issues-shield]: https://img.shields.io/github/issues/GRVYDEV/repo.svg?style=for-the-badge
[issues-url]: https://github.com/GRVYDEV/repo/issues
[license-shield]: https://img.shields.io/github/license/GRVYDEV/repo.svg?style=for-the-badge
[license-url]: https://github.com/GRVYDEV/repo/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/GRVYDEV
