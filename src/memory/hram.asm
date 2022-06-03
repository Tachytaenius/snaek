section "HRAM", HRAM
hFrameStatus::
	ds 1
hGBCFlag::
	ds 1
hOAMDMA::
	ds OAMDMASource.end - OAMDMASource
hJoypad::
.down
	ds 1
.pressed
	ds 1
.released
	ds 1
