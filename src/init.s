; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Initialization
;

.import col80_init, bgcolor

; PAL/NTSC detection
start
@1:	lda $d012
@2:	cmp $d012
	beq @2
	bmi @1
	cmp #$20
	bcc :+		; NTSC
	ldx #1
	stx is_pal_system
:

; SuperCPU detection
; "it should just tell you to turn that shit off.
;  who needs 20MHz for 9600 baud, anyway?"
	lda $d0bc
	asl a
	bcs :+
	lda #1
	sta supercpu
:

; system setup
	jsr $e3bf	; refresh basic reset - mostly an easyflash fix

	sei
	cld
	ldx #$ff
	txs
	lda #$2f
	sta $00
	lda #$37
	sta $01

.if 1
	jsr col80_init
	lda #$80
	sta is_80_columns
.endif
	jsr setup_ram_nmi

	lda $0326
	sta oldout
	lda $0327
	sta oldout+1
	lda $0314
	sta oldirq
	lda $0315
	sta oldirq+1

; editor/screen setup
	lda #1
	sta BLNSW	; enable cursor blinking
	lda #BCOLOR
	sta backgr
	sta border
	lda #TCOLOR
	sta textcl

	lda #$80
	sta RPTFLA	; key repeat on
	lda #$0e
	sta $d418	; *almost* full volume

	bit is_80_columns
	bmi @skip
; clear secondary screens
	lda #<SCREENS_BASE
	sta locat
	lda #>SCREENS_BASE
	sta locat+1
	lda #>$2000
	ldy #0
:	sta (locat),y
	iny
	bne :-
	inc locat+1
	bne :-
@skip:

	cli

; find first disk drive
	lda FA		; current dev#
	jmp @dsk1
@loop:	inc device_disk
	lda device_disk
	cmp #16		; try #30 here for top drive #?
	beq :+
	jmp @dsk1
:	lda #0
	sta drive_present; we have no drives
	lda #8
	sta device_disk
	jmp @dsk2
@dsk1:	sta device_disk
	jsr drvchk
	bmi @loop
	lda #1
	sta drive_present; we have a drive!
@dsk2:

; REU detection
	lda easyflash_support
	beq @ef1	; skip REU detection if we have EasyFlash
	jsr noreu
	jmp @ef2
@ef1:
	jsr reu_detect
@ef2:

; init. buffer & open rs232
	lda newbuf
	sta buffer_ptr
	lda newbuf+1
	sta buffer_ptr+1

	jsr rsopen
	jsr ercopn
	jmp init	; [XXX the next two functions are in the way]

;----------------------------------------------------------------------
; open rs232 file
rsopen:
	jsr rsuser_disable
	jsr up9600_disable
	jsr enablemodem
	jsr clall
	lda #LFN_MODEM
	ldx #DEV_MODEM
	ldy #SA_MODEM
	jsr setlfs
	lda aciaemu_filename_len
	ldx #<aciaemu_filename
	ldy #>aciaemu_filename
	jsr setnam
	jsr open
	lda #>ribuf	; move rs232 buffers
	sta RIBUF+1	; for the userport 300-2400 modem nmi handling
	jsr disablemodem
	rts		; [XXX jmp]

;----------------------------------------------------------------------
ercopn:
	lda drive_present
	beq :+
	lda #2;file length      ;open err chan
	ldx #<filename_i0
	ldy #>filename_i0
	jsr setnam
	lda #15
	ldx device_disk
	tay
	jsr setlfs
	jsr open
:	rts

;----------------------------------------------------------------------
init
	lda #1
	sta cursor_flag	; non-destructive
	lda #0
	sta $9d		; suppress all KERNAL messages
	lda #1
	sta ascii_mode
	;sta allcap     ; upper/lower
	sta buffer_open
	sta half_duplex	; full duplex
	jsr $e544	; clear screen
	lda config_file_loaded; already loaded config file?
	bne @noload
	lda drive_present
	beq @noload	; no drive exists

; load config file from disk
	jsr disablemodem
	lda #1
	sta config_file_loaded
	ldx #<filename_config
	ldy #>filename_config
	lda #11
	jsr setnam
	lda #2
	ldx device_disk
	ldy #0
	jsr setlfs
	jsr load_config_file

@noload:
	jmp term_entry_first

;----------------------------------------------------------------------
.segment "CODE"
;----------------------------------------------------------------------
is_80_columns:
	.byte 0
oldout:
	.word 0
oldirq:
	.word 0
.assert <oldout <> $ff, error, "JMP () bug"
.assert <oldirq <> $ff, error, "JMP () bug"

;----------------------------------------------------------------------
get_charset:
	lda is_80_columns
	beq :+
	lda #2
	rts
:	lda $d018
	and #2
	rts

;----------------------------------------------------------------------
set_bgcolor:
	sta $d020
	asl
	asl
	asl
	asl
	sta bgcolor
	rts

;----------------------------------------------------------------------
setup_ram_nmi:
	lda #<ramnmi
	sta $fffa
	lda #>ramnmi
	sta $fffb
;	lda #<ramirq
;	sta $fffe
;	lda #>ramirq
;	sta $ffff
	rts

;----------------------------------------------------------------------
ramnmi:
	pha
	lda $01
	pha
	lda #$37
	sta $01
	lda #>ramnm2
	pha
	lda #<ramnm2
	pha
	pha		; P
	lda tempch
	jmp $fe43
ramnm2:
	pla
	sta $01
	pla
	rti

ramirq:
	pha
	lda $01
	pha
	lda #$37
	sta $01
	lda #>ramirq2
	pha
	lda #<ramirq2
	pha
	pha		; P
	lda tempch
	jmp $ff48
ramirq2:
	pla
	sta $01
	pla
	rti
.segment "S1000"
