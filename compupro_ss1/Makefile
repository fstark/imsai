all: compupro_ss1_uart_test.bin

compupro_ss1_uart_test.bin: compupro_ss1_uart_test.asm
	/home/altomare/software/asm8080/src/asm8080 $<
	truncate $@ -s 2048
	cat $@ > rom.bin
	cat $@ >> rom.bin
