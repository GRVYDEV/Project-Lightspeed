package ws

import "encoding/json"

const (
	MessageTypeAnswer    = "answer"
	MessageTypeCandidate = "candidate"
	MessageTypeOffer     = "offer"
	MessageTypeInfo      = "info"
)

type WebsocketMessage struct {
	Event string          `json:"event"`
	Data  json.RawMessage `json:"data"`
}
