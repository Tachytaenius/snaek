include "hardware.asm"
include "constants.asm"
include "macros.asm"

section	"VBlank IRQ Vector", ROM0 [$40]
VBlankVector::
	push af
	ldh a, [hFrameStatus]
	inc a
	jr nz, :+
	ld a, $FF
:
	ldh [hFrameStatus], a
	pop af
	reti

section "Entry", ROM0 [$0100]
	jp Init ; would be jr

section "Home", ROM0 [$0150]
include "tileset.asm" ; HACK: because the consts made by Enum don't exist by the time they are used
include "init.asm"
include "gameinit.asm"
include "mainloop.asm"
include "map.asm"
include "food.asm"
include "lib/rand.z80"
include "video.asm"
include "joypad.asm"
include "memmanip.asm"

include "memory/wram.asm"
include "memory/hram.asm"
