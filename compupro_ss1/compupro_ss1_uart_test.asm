; TEST PROGRAM FOR THE 2651 UART

; SETS UP THE UART FOR 9600 BAUD (INTERNALLY GEN)
;  8 BIT CHARACTERS, 2 STOP BITS, NO PARITY, RTS
;    LOW, DTR LOW, AND THEN ECHOES CHARACTERS

	; assumes System Support 1 is addressed
	; to 50 hex (CompuPro Standard)
	; for different addresses, change "BASE" in equates

	ORG 000H

BASE	EQU 0F0H		; base address of System Support 1
DATA	EQU BASE+0CH	; UART data register
STATUS	EQU BASE+0DH	; UART status register
MODE	EQU BASE+0EH	; UART mode register
CMND	EQU BASE+0FH	; UART command register
TBE	EQU 01H		; transmitter buffer empty status bit
RDA	EQU 02H		; receiver data available status bit
CPM	EQU 0000H	; CP/M restart address
CNTLC	EQU 03H		; control C

STACK	EQU 0800H

	DI
	LXI SP,STACK	; Stack in RAM

INIT:	MVI A,11101110B	; data for mode register 1
	OUT MODE	; send it
	MVI A,01111110B	; data for mode register 2
	OUT MODE	; send it
	MVI A,00100111B	; data for command register
	OUT CMND	; send it

GETCHR:	IN STATUS	; read the status register
	ANI RDA		; mask out all bits but RDA
	JZ GETCHR	; if it's not high, loop
	IN DATA		; must be high so read the data
	ANI 7FH		; strip off parity bit
	CPI CNTLC	; was it a control C?
	CZ CPM		; yes, jump to CP/M
			; otherwise....
	PUSH PSW	; save the character on the stack
SNDCHR:	IN STATUS	; read the status register
	ANI TBE		; mask out all bits but TBE
	JZ SNDCHR	; if it's not high, loop
	POP PSW		; must be high, get character back
	OUT DATA	; and send it
	JMP GETCHR	; then repeat the whole thing
