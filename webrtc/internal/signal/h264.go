package signal

type NAL struct {
	PictureOrderCount uint32

	// NAL header
	ForbiddenZeroBit bool
	RefIdc           uint8
	UnitType         NalUnitType

	Data []byte // header byte + rbsp
}

func NewNal(data []byte) *NAL {
	return &NAL{PictureOrderCount: 0, ForbiddenZeroBit: false, RefIdc: 0, UnitType: NalUnitTypeUnspecified, Data: data}
}

func (h *NAL) ParseHeader() {
	firstByte := h.Data[0]
	h.ForbiddenZeroBit = (((firstByte & 0x80) >> 7) == 1) // 0x80 = 0b10000000
	h.RefIdc = (firstByte & 0x60) >> 5                    // 0x60 = 0b01100000
	h.UnitType = NalUnitType((firstByte & 0x1F) >> 0)     // 0x1F = 0b00011111
}