EASYFLASH ?= 0

all:
	mkdir -p build
	ca65 -g src/ccgmsterm.s -o build/ccgmsterm.o -DEASYFLASH=$(EASYFLASH)
	ca65 -g src/80columns.s -o build/80columns.o -DEASYFLASH=$(EASYFLASH)
	ca65 -g src/charset.s -o build/charset.o -DEASYFLASH=$(EASYFLASH)
	cl65 -g -C src/ccgmsterm.cfg build/ccgmsterm.o build/80columns.o build/charset.o -o build/ccgmsterm.prg -Ln build/ccgmsterm.sym -m build/ccgmsterm.map

clean:
	rm -rf build
