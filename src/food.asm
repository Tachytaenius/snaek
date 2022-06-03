PlaceNewFoodTile::
	; random b 0 to SCRN_X_B
	; random c 0 to SCRN_Y_B
	call rand
	
	; b = b mod SCRN_X_B
	ld a, b
:
	cp SCRN_X_B + 1
	jr c, :+
	sub SCRN_X_B
	jr :-
:
	ld b, a
	
	; c = c mod SCRN_Y_B
	ld a, c
:
	cp SCRN_Y_B + 1
	jr c, :+
	sub SCRN_Y_B
	jr :-
:
	ld c, a
	
	call GetTileAddressFromBCAsXYInHL ; has multiplication loop that would be slow to do for every single attempted tile
	; store address of originally tried tile in DE
	ld d, h
	ld l, e
.try
	call WaitVRAMAccess
	ld a, [hl]
	cp TILE_EMPTY
	jr nz, .next
	ld a, TILE_FOOD
	ld [hl], a
	ret

.next
	; is this the last tile on the map?
	ld a, h
	cp HIGH($9A33)
	jr nz, .notLastTileOnMap
	ld a, l
	cp LOW($9A33)
	jr nz, .notLastTileOnMap
	; last tile on map, wrap
	ld hl, _SCRN0
	jr .checkCurrentAddress ; don't increment if we've just wrapped
	
.notLastTileOnMap
	; handle getting to next tile
	inc hl
	; did we go out of the window?
	ld a, l
	and %00011111 ; get x component
	jr nz, .checkCurrentAddress
	; we went out, add extra to current address
	Breakpoint
	ld a, l
	add SCRN_VX_B - SCRN_X_B
	ld l, a
	ld a, h
	adc 0
	ld h, a
	
.checkCurrentAddress
	; have we returned to the originally tried tile?
	ld a, h
	cp d
	jr nz, .try ; no, continue with this tile
	ld a, l
	cp e
	jr nz, .try ; no, continue with this tile
	ld a, STATE_NO_MORE_SPACE ; epic win B-)
	ld [wGameState], a
	ret
