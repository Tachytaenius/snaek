StopLCD::
	ld a, [rLCDC]
	rlca
	ret nc
.wait
	ld a, [rLY]
	cp 144
	jr c, .wait
	ld a, [rLCDC]
	res 7, a
	ld [rLCDC], a
	ret

StartLCD::
	ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ16|LCDCF_OBJOFF
	ld [rLCDC], a
	ret

OAMDMASource::
	ldh [rDMA], a
	ld a, 40
:
	dec a
	jr nz, :-
	ret
.end

WaitVRAMAccess::
	push af
:
	ldh a, [rSTAT]
	and a, STATF_BUSY
	jr nz, :-
	pop af
	ret
