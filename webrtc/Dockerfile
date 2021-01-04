FROM golang:1.14

WORKDIR /go/src/app
ENV GO111MODULE=on
RUN go get github.com/GRVYDEV/lightspeed-webrtc

#CMD ["lightspeed-webrtc --addr=XXX.XXX.XXX.XXX", "run"]
EXPOSE 8080
# defaults to localhost:8080, then up to docker compose to bind ports
CMD ["lightspeed-webrtc", "--addr=localhost"]