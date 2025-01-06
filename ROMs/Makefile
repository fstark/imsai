ASM_FILES := $(wildcard *.asm)
HEX_FILES := $(ASM_FILES:.asm=.hex)
BIN_FILES := $(ASM_FILES:.asm=.bin)

OBJCOPY=/usr/local/Cellar/binutils/2.43.1/bin/objcopy

all: $(BIN_FILES)

%.hex: %.asm
	../../a85/a85 $< -o $@ -l $*.lst

%.bin: %.hex
	${OBJCOPY} --input-target=ihex --output-target=binary $< $*.2k.bin
	truncate -s 2048 $*.2k.bin
	cat $*.2k.bin $*.2k.bin > $@

clean:
	rm -f $(BIN_FILES) $(HEX_FILES) *.lst *.2k.bin
