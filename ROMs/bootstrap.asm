; Bootstrap loader, as described in the IMSAI manual.

	ORG 0

	MVI A,0CEH              ; Async mode byte; sets 2 stop, 8 data bits, no parity, 16x bitrate divisor.
	OUT 3
	MVI A,17H               ; Command byte; reset error flag, set receive enable, DTR, transmit enable
	OUT 3
READ_BOOTSTRAP:
	LXI H,20H               ; Destination
	MVI B,0F8H          	; Byte counter (248)
WAIT_RDY:
	IN 3                    ; Read the USART status
	ANI 2                   ; isolate bit 1 (RxRDY)
	JZ 0DH                  ; loop if no data
	IN 2                    ; Read data
	MOV M,A                 ; Store byte in DATA+index
	INR A                   ; Compare to 0FFH
	JZ 8
	INX H                   ; Next address
	DCR B
	JNZ 0DH                 ; After 248 chars, we'll continue in 0020H
	END

