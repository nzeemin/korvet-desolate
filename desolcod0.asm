
;----------------------------------------------------------------------------
; Korvet consts

DOSG1   EQU	3CH

;----------------------------------------------------------------------------

StartCode	EQU	200h		; Code block starts at
Start		EQU	8000h		; Code entry point

	ORG	100h

	di
	ld	sp,100h

; Set memory mode
        ld   a,DOSG1
        ld   (0FA7Fh),a		; set SYSREG = DOSG1

; Setup the screen
	ld hl,0FFFBh		; LUT register
	ld (hl),00h		; black
	ld (hl),02h		; black
	ld (hl),04h		; black
	ld (hl),06h		; black
	ld (hl),08h		; black
	ld (hl),0Ah		; black
	ld (hl),0Ch		; black
	ld (hl),0Eh		; black
	ld (hl),0F1h		; white
	ld (hl),0F3h		; white
	ld (hl),0F5h		; white
	ld (hl),0F7h		; white
	ld (hl),0F9h		; white
	ld (hl),0FBh		; white
	ld (hl),0FDh		; white
	ld (hl),0FFh		; white
	xor a
	ld (0FF3Ah),a		; set VIREG = 0
	ld a,00001101b
	ld (0FFBFh),a		; set NCREG = 00001100

; Move encoded block from StartCode to C000h
	ld	de,StartCode		; source addr
	ld	hl,0C000h		; destination addr
	ld	bc,03E00h		; length
Init_1:
	ld a,(de)
	inc de
	ld (hl),a
	inc hl
	dec bc
	ld a,b
	or c
	jp nz,Init_1

; Decompress the encoded block from C000h to Start
	ld	de,0C000h
	ld	bc,StartCode
	call	dzx0

; Clear memory from C000h to FFFFh
;	lxi	b,0C000h	; destination addr
;Init_2:
;	stax	b
;	inr	c
;	jnz	Init_2
;	inr	b
;	jnz	Init_2

	jp Start

; Short sound on look/shoot action
;SoundLookShoot:
;	MVI  H, 00Ah	; Counter 1
;	XRA  A
;SoundLookShoot_1:
;	MVI  L, 080h	; Counter 2
;SoundLookShoot_2:
;	DCR  L
;	JNZ     SoundLookShoot_2  ; delay
;	XRI     001h	; inverse bit 0
;	OUT     000h
;	DCR  H
;	JNZ     SoundLookShoot_1  ; Loop 30 times
;	ret

;----------------------------------------------------------------------------
; ZX0 decompressor code by Ivan Gorodetsky
; https://github.com/ivagorRetrocomp/DeZX/blob/main/ZX0/8080/OLD_V1/dzx0_CLASSIC.asm
; input:	de=compressed data start
;		bc=uncompressed destination start
; Распаковщик для сжатия ZX0 forward, код для 8080 в мнемонике Z80
dzx0:
		ld hl,0FFFFh
		push hl
		inc hl
		ld a,080h
dzx0_literals:
		call dzx0_elias
		call dzx0_ldir
		jp c,dzx0_new_offset
		call dzx0_elias
dzx0_copy:
		ex de,hl
		ex (sp),hl
		push hl
		add hl,bc
		ex de,hl
		call dzx0_ldir
		ex de,hl
		pop hl
		ex (sp),hl
		ex de,hl
		jp nc,dzx0_literals
dzx0_new_offset:
		call dzx0_elias
		ld h,a
		pop af
		xor a
		sub l
		ret z
		push hl
		rra
		ld h,a
		ld a,(de)
		rra
		ld l,a
		inc de
		ex (sp),hl
		ld a,h
		ld hl,1
		call nc,dzx0_elias_backtrack
		inc hl
		jp dzx0_copy
dzx0_elias:
		inc l
dzx0_elias_loop:
		add a,a
		jp nz,dzx0_elias_skip
		ld a,(de)
		inc de
		rla
dzx0_elias_skip:
		ret c
dzx0_elias_backtrack:
		add hl,hl
		add a,a
		jp nc,dzx0_elias_loop
		jp dzx0_elias
dzx0_ldir:
		push af
dzx0_ldir1:
		ld a,(de)
		ld (bc),a
		inc de
		inc bc
		dec hl
		ld a,h
		or l
		jp nz,dzx0_ldir1
		pop af
		add a,a
		ret

;----------------------------------------------------------------------------
; Filler
	ORG	StartCode - 1
	DB 0

	END

;----------------------------------------------------------------------------
