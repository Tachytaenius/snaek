MainLoop::
	call UpdateJoypad
	
	; Wait for enough VBlanks
	ldh a, [hFrameStatus]
	and a
	jr z, MainLoop
	
	ld b, a
	
	ld a, [wGameState]
	cp STATE_TITLE
	jp z, .titleScreen
	
	; ld b, a done above
	ld a, [wFramesUntilMoveCounter]
	add b
	ld [wFramesUntilMoveCounter], a
	
	xor a
	ldh [hFrameStatus], a
	
	ld a, HIGH(wShadowOAM)
	call hOAMDMA
	
	ld a, [wGameState]
	cp STATE_PLAYING
	jp nz, .finishMainLoop
	
	; get tile at head position of snake and change if input
	ld hl, wHeadPos
	call GetTileAddressFromPosAtHLInHL
	call WaitVRAMAccess
	
	; a directional input will change the facing of the current head tile, which is then carried on as normal, changed or not
	ldh a, [hJoypad.down]
	and JOY_UP
	jr z, :+
	ld a, [wPreviousHeadTile]
	cp TILE_SNAKE_DOWN
	jr z, .dontChange
	ld a, TILE_SNAKE_UP
	jr .changeHeadTypeToA
:
	ldh a, [hJoypad.down]
	and JOY_DOWN
	jr z, :+
	ld a, [wPreviousHeadTile]
	cp TILE_SNAKE_UP
	jr z, .dontChange
	ld a, TILE_SNAKE_DOWN
	jr .changeHeadTypeToA
:
	ldh a, [hJoypad.down]
	and JOY_LEFT
	jr z, :+
	ld a, [wPreviousHeadTile]
	cp TILE_SNAKE_RIGHT
	jr z, .dontChange
	ld a, TILE_SNAKE_LEFT
	jr .changeHeadTypeToA
:
	ldh a, [hJoypad.down]
	and JOY_RIGHT
	jr z, .dontChange
	ld a, [wPreviousHeadTile]
	cp TILE_SNAKE_LEFT
	jr z, .dontChange
	ld a, TILE_SNAKE_RIGHT
.changeHeadTypeToA
	call WaitVRAMAccess
	ld [hl], a
.dontChange
	; don't do anything (besides joypad input) unless enough frames have passed
	; that's: move if [wFramesUntilMoveCounter] >= VBLANKS_TO_WAIT_UNTIL_MOVE
	ld a, [wFramesUntilMoveCounter]
	cp VBLANKS_TO_WAIT_UNTIL_MOVE
	jr c, .finishMainLoop
	xor a
	ld [wFramesUntilMoveCounter], a
	
	ld a, [hl]
	ld [wPreviousHeadTile], a
	; change head position to where the head is pointing
	ld hl, wHeadPos
	call .handleChangingHeadOrTailPos
	; check what is at the new (attempted) head position
	ld hl, wHeadPos
	call GetTileAddressFromPosAtHLInHL
	call WaitVRAMAccess
	ld a, [hl]
	cp TILE_FOOD
	jr z, .food
	cp TILE_EMPTY
	jr z, :+ ; if it wasn't food or empty, the head was trying to move into a snake tile, and that means game over
	jp .gameOver
:
	; remove tail tile and make tail pos where previous tail tile was pointing
	ld hl, wTailPos
	push hl
	call GetTileAddressFromPosAtHLInHL
	call WaitVRAMAccess
	ld a, [hl] ; get tail tile type
	push af
	ld a, TILE_EMPTY ; remove tail
	ld [hl], a
	pop af ; old tail tile type
	pop hl ; wTailPos
	call .handleChangingHeadOrTailPos
	
.skipRemovingTail
	; copy previous head tile into new position
	ld hl, wHeadPos
	call GetTileAddressFromPosAtHLInHL
	call WaitVRAMAccess
	ld a, [wPreviousHeadTile]
	ld [hl], a
	
.finishMainLoop
	; xor a
	; ldh [hFrameStatus], a ; avoid situation where vblank flag checking starts in the middle of a vblank TODO: Rework this
	jp MainLoop

.food
	call PlaceNewFoodTile
	jr .skipRemovingTail ; because we will be moving the head, not removing the tail is adding to the length

.gameOver
	ld a, STATE_GAME_OVER
	ld [wGameState], a
	jr .finishMainLoop

.titleScreen
	ldh a, [hJoypad.down]
	and JOY_START
	jr nz, .start
	LoadHLFromAddress wTicksUntilStartPressedCounter
	inc hl
	LoadHLIntoAddress wTicksUntilStartPressedCounter
	jr .finishMainLoop

.start
	call PlaceNewFoodTile
	ld a, STATE_PLAYING
	ld [wGameState], a
	jr .finishMainLoop

.checkIfYIsOutOfBounds
	cp -1
	jr z, .gameOver
	cp SCRN_Y_B
	jr z, .gameOver
	ret

.checkIfXIsOutOfBounds
	cp -1
	jr z, .gameOver
	cp SCRN_X_B
	jr z, .gameOver
	ret

.handleChangingHeadOrTailPos ; tile type at a, pos address at hl
	cp TILE_SNAKE_UP
	jr nz, :+
	; up
	inc hl ; the y part
	ld a, [hl]
	dec a
	ld [hl], a
	call .checkIfYIsOutOfBounds ; bounds checks will only ever come up with a "no" for the head (when you hit a wall)
	ret
:
	cp TILE_SNAKE_DOWN
	jr nz, :+
	; down
	inc hl ; the y part
	ld a, [hl]
	inc a
	ld [hl], a
	call .checkIfYIsOutOfBounds
	ret
:
	cp TILE_SNAKE_LEFT
	jr nz, :+
	; left
	ld a, [hl]
	dec a
	ld [hl], a
	call .checkIfXIsOutOfBounds
	ret
:
	cp TILE_SNAKE_RIGHT
	jr nz, :+ ; don't move, i guess. but that case shouldn't happen
	; right
	ld a, [hl]
	inc a
	ld [hl], a
	call .checkIfXIsOutOfBounds
	ret
:
	Breakpoint ; head/tail wasn't pointing to a snake tile
	ret
