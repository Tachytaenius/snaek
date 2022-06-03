Init::
	; Game Boy Colour?
	cp $11
	ld a, 1
	jr z, .cgb
	xor a
.cgb
	ldh [hGBCFlag], a
	
	di
	ld sp, wStack.bottom
	call StopLCD
	
	; Copy OAM DMA routine to HRAM
	Copy hOAMDMA, OAMDMASource
	
	; Set palettes
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a
	
	xor a
	ld [hFrameStatus], a
	; Clear joypad
	ld hl, hJoypad
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	; Clear shadow OAM
	Fill wShadowOAM, 0
	
	; Enable sprites
	ld a, [rLCDC]
	or LCDCF_OBJON | LCDCF_OBJ16
	ld [rLCDC], a
	
	call GameInit
	
	; Start LCD and enable interrupts
	call StartLCD
	ei
	ld a, IEF_VBLANK
	ldh [rIE], a
	
	jp MainLoop
