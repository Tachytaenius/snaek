INIT_X = 10
INIT_Y = 9
INIT_SNAKE_TILE = TILE_SNAKE_DOWN

GameInit::
	xor a
	ld [wFramesUntilMoveCounter], a
	
	Copy _VRAM, Tileset
	
	; clear map
	ld bc, _SCRN0
	ld d, SCRN_X_B ; number of times to loop
	
.rowLoop
	; this was taken from a "load map" routine with dynamic map sizes, so it may have some odd choices
	ld a, TILE_EMPTY
	ld [bc], a
	inc bc
	
	ld a, c
	and %00011111 ; get x component
	cp SCRN_X_B - 1
	jr nz, .rowLoop
	
.nextRow
	dec d
	jr z, .done
	
	ld a, c
	add SCRN_VX_B - SCRN_X_B
	ld c, a
	ld a, b
	adc 0
	ld b, a
	
	jr .rowLoop
.done
	
	; place snake
	ld a, INIT_X
	ld [wHeadPos.x], a
	ld [wTailPos.x], a
	ld a, INIT_Y
	ld [wHeadPos.y], a
	ld [wTailPos.y], a
	ld hl, wHeadPos
	call GetTileAddressFromPosAtHLInHL
	ld a, INIT_SNAKE_TILE
	ld [hl], a
	
	ld a, TILE_EMPTY
	ld [wPreviousHeadTile], a ; used to stop player from moving back into self, can be empty (which means can turn 180 degrees around if wanted) for first turn, unless the starting state is a snake longer than 1 tile
	
	ld a, STATE_TITLE
	ld [wGameState], a
	
	ret
