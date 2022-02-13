; CCGMS Terminal
;
; Copyright (c) 2016,2020, Craig Smith, alwyz. All rights reserved.
; This project is licensed under the BSD 3-Clause License.
;
; Main .s file
;

	.feature labels_without_colons
	.feature string_escapes
	.macpack longbranch

.define VERSION "0.1"

	.include "declare.s"
	.include "encoding.s"

.segment "HEADER"

	.word $0801
	.word entry
	.word 10
	.byte $9e,"2061"
	.word 0
	.byte 0

.segment "CCGMS"

entry:
	jmp start

	.include "punter.s"
	.include "misc2.s"
	.include "init.s"
	.include "terminal.s"
	.include "sound.s"
	.include "screens.s"
	.include "banner.s"
	.include "dir.s"
	.include "ansi.s"
	.include "cursor.s"
	.include "input.s"
	.include "misc.s"
	.include "diskcmd.s"
	.include "macroex.s"
	.include "buffer2.s"
	.include "xmodem.s"
	.include "xfer.s"
	.include "disk.s"
	.include "outstr.s"
	.include "multixfer.s"
	.include "buffer.s"
	.include "phonebook.s"
	.include "configldsv.s"
	.include "instrprint.s"
	.include "macro.s"
	.include "configedit.s"
	.include "rs232_userport.s"
	.include "rs232_swiftlink.s"
	.include "rs232_up9600.s"
	.include "rs232.s"
	.include "reu.s"
	.include "theme.s"
	.include "easyflash.s"
	.include "config.s"
	.include "instr.s"

easyflash_support:
	.byte EASYFLASH

.segment "END"
endprg:
