 ; Themnfted from pokecrystal

ByteFill::
; fill bc bytes with the value of a, starting at hl
    inc b ; we bail the moment b hits 0, so include the last run
    inc c ; same thing; include last byte
    jr .HandleLoop
.PutByte:
    ld [hli], a
.HandleLoop:
    dec c
    jr nz, .PutByte
    dec b
    jr nz, .PutByte
    ret

CopyBytes::
; copy bc bytes from hl to de
	inc b ; we bail the moment b hits 0, so include the last run
	inc c ; same thing; include last byte
	jr .HandleLoop
.CopyByte:
	ld a, [hli]
	ld [de], a
	inc de
.HandleLoop:
	dec c
	jr nz, .CopyByte
	dec b
	jr nz, .CopyByte
	ret
