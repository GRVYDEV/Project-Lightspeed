//go:build !js
// +build !js

package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"strconv"
	"strings"
	"sync"

	"github.com/GRVYDEV/lightspeed-webrtc/ws"
	"github.com/gorilla/websocket"

	"github.com/pion/interceptor"
	"github.com/pion/rtp"
	"github.com/pion/webrtc/v3"
)

var (
	addr     = flag.String("addr", "localhost", "http service address")
	ip       = flag.String("ip", "none", "IP address for webrtc")
	wsPort   = flag.Int("ws-port", 8080, "Port for websocket")
	rtpPort  = flag.Int("rtp-port", 65535, "Port for RTP")
	ports    = flag.String("ports", "20000-20500", "Port range for webrtc")
	iceSrv   = flag.String("ice-servers", "none", "Comma seperated list of ICE / STUN servers (optional)")
	sslCert  = flag.String("ssl-cert", "", "Ssl cert for websocket (optional)")
	sslKey   = flag.String("ssl-key", "", "Ssl key for websocket (optional)")
	upgrader = websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool { return true },
	}

	videoTrack *webrtc.TrackLocalStaticRTP

	audioTrack *webrtc.TrackLocalStaticRTP

	hub *ws.Hub
)

func main() {
	flag.Parse()
	log.SetFlags(0)

	// Open a UDP Listener for RTP Packets on port 65535
	listener, err := net.ListenUDP("udp", &net.UDPAddr{IP: net.ParseIP(*addr), Port: *rtpPort})
	if err != nil {
		panic(err)
	}
	defer func() {
		if err = listener.Close(); err != nil {
			panic(err)
		}
	}()

	fmt.Println("Waiting for RTP Packets")

	// Create a video track
	videoTrack, err = webrtc.NewTrackLocalStaticRTP(webrtc.RTPCodecCapability{MimeType: "video/H264"}, "video", "pion")
	if err != nil {
		panic(err)
	}

	// Create an audio track
	audioTrack, err = webrtc.NewTrackLocalStaticRTP(webrtc.RTPCodecCapability{MimeType: "audio/opus"}, "audio", "pion")
	if err != nil {
		panic(err)
	}

	hub = ws.NewHub()
	go hub.Run()

	// start HTTP server
	go func() {
		http.HandleFunc("/websocket", websocketHandler)

		wsAddr := *addr + ":" + strconv.Itoa(*wsPort)
		if *sslCert != "" && *sslKey != "" {
			log.Fatal(http.ListenAndServeTLS(wsAddr, *sslCert, *sslKey, nil))
		} else {
			log.Fatal(http.ListenAndServe(wsAddr, nil))
		}
	}()

	inboundRTPPacket := make([]byte, 4096) // UDP MTU

	var once sync.Once

	// Read RTP packets forever and send them to the WebRTC Client
	for {

		n, _, err := listener.ReadFrom(inboundRTPPacket)

		once.Do(func() { fmt.Print("houston we have a packet") })

		if err != nil {
			fmt.Printf("error during read: %s", err)
			panic(err)
		}

		packet := &rtp.Packet{}
		if err = packet.Unmarshal(inboundRTPPacket[:n]); err != nil {
			//It has been found that the windows version of OBS sends us some malformed packets
			//It does not effect the stream so we will disable any output here
			//fmt.Printf("Error unmarshaling RTP packet %s\n", err)

		}

		if packet.Header.PayloadType == 96 {
			if _, writeErr := videoTrack.Write(inboundRTPPacket[:n]); writeErr != nil {
				panic(writeErr)
			}
		} else if packet.Header.PayloadType == 97 {
			if _, writeErr := audioTrack.Write(inboundRTPPacket[:n]); writeErr != nil {
				panic(writeErr)
			}
		}

	}

}

// Create a new webrtc.API object that takes public IP addresses and port ranges into account.
func createWebrtcApi() *webrtc.API {
	s := webrtc.SettingEngine{}

	// Set a NAT IP if one is given -- only if no ICE servers are provided
	if *ip != "none" && *iceSrv == "none" {
		s.SetNAT1To1IPs([]string{*ip}, webrtc.ICECandidateTypeHost)
	}

	// Split given port range into two sides, pass them to SettingEngine
	pr := strings.SplitN(*ports, "-", 2)

	pr_low, err := strconv.ParseUint(pr[0], 10, 16)
	if err != nil {
		panic(err)
	}
	pr_high, err := strconv.ParseUint(pr[1], 10, 16)
	if err != nil {
		panic(err)
	}

	s.SetEphemeralUDPPortRange(uint16(pr_low), uint16(pr_high))

	// Default parameters as specified in Pion's non-API NewPeerConnection call
	// These are needed because CreateOffer will not function without them
	m := &webrtc.MediaEngine{}
	if err := m.RegisterDefaultCodecs(); err != nil {
		panic(err)
	}

	i := &interceptor.Registry{}
	if err := webrtc.RegisterDefaultInterceptors(m, i); err != nil {
		panic(err)
	}

	return webrtc.NewAPI(webrtc.WithMediaEngine(m), webrtc.WithInterceptorRegistry(i), webrtc.WithSettingEngine(s))
}

// Handle incoming websockets
func websocketHandler(w http.ResponseWriter, r *http.Request) {

	// Upgrade HTTP request to Websocket
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}

	// When this frame returns close the Websocket
	defer conn.Close() //nolint

	// Create API that takes IP and port range into account
	api := createWebrtcApi()

	// Create the WebRTC config with ICE server configuration
	var webrtcCfg webrtc.Configuration
	if *iceSrv != "none" {
		iceUrls := strings.Split(*iceSrv, ",")
		iceServers := make([]webrtc.ICEServer, len(iceUrls))
		for idx, url := range iceUrls {
			iceServers[idx] = webrtc.ICEServer{
				URLs: []string{url},
			}
		}
		webrtcCfg = webrtc.Configuration{
			ICEServers: iceServers,
		}
	} else {
		webrtcCfg = webrtc.Configuration{}
	}

	// Create new PeerConnection
	peerConnection, err := api.NewPeerConnection(webrtcCfg)
	if err != nil {
		log.Print(err)
		return
	}

	// When this frame returns close the PeerConnection
	defer peerConnection.Close() //nolint

	// Accept one audio and one video track Outgoing
	transceiverVideo, err := peerConnection.AddTransceiverFromTrack(videoTrack,
		webrtc.RTPTransceiverInit{
			Direction: webrtc.RTPTransceiverDirectionSendonly,
		},
	)
	transceiverAudio, err := peerConnection.AddTransceiverFromTrack(audioTrack,
		webrtc.RTPTransceiverInit{
			Direction: webrtc.RTPTransceiverDirectionSendonly,
		},
	)
	if err != nil {
		log.Print(err)
		return
	}
	go func() {
		rtcpBuf := make([]byte, 1500)
		for {
			if _, _, rtcpErr := transceiverVideo.Sender().Read(rtcpBuf); rtcpErr != nil {
				return
			}
			if _, _, rtcpErr := transceiverAudio.Sender().Read(rtcpBuf); rtcpErr != nil {
				return
			}
		}
	}()

	c := ws.NewClient(hub, conn, peerConnection)

	go c.WriteLoop()

	// Add to the hub
	hub.Register <- c

	// Trickle ICE. Emit server candidate to client
	peerConnection.OnICECandidate(func(i *webrtc.ICECandidate) {
		if i == nil {
			return
		}

		candidateString, err := json.Marshal(i.ToJSON())
		if err != nil {
			log.Println(err)
			return
		}

		if msg, err := json.Marshal(ws.WebsocketMessage{
			Event: ws.MessageTypeCandidate,
			Data:  candidateString,
		}); err == nil {
			hub.RLock()
			if _, ok := hub.Clients[c]; ok {
				c.Send <- msg
			}
			hub.RUnlock()
		} else {
			log.Println(err)
		}
	})

	// If PeerConnection is closed remove it from global list
	peerConnection.OnConnectionStateChange(func(p webrtc.PeerConnectionState) {
		switch p {
		case webrtc.PeerConnectionStateFailed:
			if err := peerConnection.Close(); err != nil {
				log.Print(err)
			}
			hub.Unregister <- c

		case webrtc.PeerConnectionStateClosed:
			hub.Unregister <- c
		}
	})

	offer, err := peerConnection.CreateOffer(nil)
	if err != nil {
		log.Print(err)
	}

	if err = peerConnection.SetLocalDescription(offer); err != nil {
		log.Print(err)
	}

	offerString, err := json.Marshal(offer)
	if err != nil {
		log.Print(err)
	}

	if msg, err := json.Marshal(ws.WebsocketMessage{
		Event: ws.MessageTypeOffer,
		Data:  offerString,
	}); err == nil {
		hub.RLock()
		if _, ok := hub.Clients[c]; ok {
			c.Send <- msg
		}
		hub.RUnlock()
	} else {
		log.Printf("could not marshal ws message: %s", err)
	}

	c.ReadLoop()
}
