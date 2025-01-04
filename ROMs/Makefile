all: mioa.bin

mioa.hex: mioa.asm
	../../a85/a85 mioa.asm -o mioa.ihex -l mioa.lst

mioa.bin: mioa.hex
	objcopy --input-target=ihex --output-target=binary mioa.ihex mioa2k.bin
	truncate -s 2048 mioa2k.bin
	cat mioa2k.bin mioa2k.bin > mioa.bin
