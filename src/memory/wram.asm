section "WRAM0", WRAM0

; align 8
wShadowOAM::
	ds sizeof_OAM_ATTRS * OAM_COUNT
.end

wStack::
	ds STACK_SIZE * 2 - 1
.bottom
	ds 1

wFramesUntilMoveCounter::
	ds 1

wGameState::
	ds 1

wPreviousHeadTile::
	ds 1

wTicksUntilStartPressedCounter::
	ds 2

wHeadPos::
.x
	ds 1
.y
	ds 1
wTailPos::
.x
	ds 1
.y
	ds 1
