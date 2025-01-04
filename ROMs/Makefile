all: mioa.bin bitmarch.bin bitmarch2.bin

mioa.hex: mioa.asm
	../../a85/a85 mioa.asm -o mioa.ihex -l mioa.lst

mioa.bin: mioa.hex
	objcopy --input-target=ihex --output-target=binary mioa.ihex mioa2k.bin
	truncate -s 2048 mioa2k.bin
	cat mioa2k.bin mioa2k.bin > mioa.bin


bitmarch.hex: bitmarch.asm
	../../a85/a85 bitmarch.asm -o bitmarch.ihex -l bitmarch.lst

bitmarch.bin: bitmarch.hex
	objcopy --input-target=ihex --output-target=binary bitmarch.ihex bitmarch2k.bin
	truncate -s 2048 bitmarch2k.bin
	cat bitmarch2k.bin bitmarch2k.bin > bitmarch.bin


bitmarch2.hex: bitmarch2.asm
	../../a85/a85 bitmarch2.asm -o bitmarch2.ihex -l bitmarch2.lst

bitmarch2.bin: bitmarch2.hex
	objcopy --input-target=ihex --output-target=binary bitmarch2.ihex bitmarch22k.bin
	truncate -s 2048 bitmarch22k.bin
	cat bitmarch22k.bin bitmarch22k.bin > bitmarch2.bin
