; BOOT IMSAI USING SERIAL PORT

; ---------------------------------------------------------------------------
; Writes Rnn\n on the serial port
; This asks the host to send the the file 'nn' on the port
; nn is the hex corresponding to the front panel switches
; The file is transferred in Intel HEX format
; and loaded where appropriate
; The start address is determined by the start of the first record
; Example:
; bitmarch, loaded at 0000H
; :1A0000003EFED3FF0747DBFF3E3C3C571EFF1DC20E0015C20C0078C3020079
; :00001A01E5
; After receiving each line, we ack with a '+'
; If we fail, we ask for a retry of the current record with a '-'
; The hex record is extended with two new records types:
; FE: sets the stack for the loader (default 0C00H)
; FF: sets the start of the loaded program
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; Code layout
; ---------------------------------------------------------------------------
START   EQU 0C000H
STACK 	EQU 0C00H

; ---------------------------------------------------------------------------
; Hardware definitions for MIO card (serial only)
; ---------------------------------------------------------------------------
MIO_SIO 	EQU 42H         ; Serial I/O
MIO_CNT 	EQU 43H         ; Control

SSPT	EQU 0FFH 			;SENSE LIGHTS AND SWITCHES


CINIT	EQU 0C00H
COUT	EQU 0C03H
CIN		EQU 0C06H

; ---------------------------------------------------------------------------
		ORG START
		DI
		LXI SP,STACK
		; CALL SINIT
		LXI H,SERIAL1
		CALL SETCONSOLE

		JMP HEXPARSE

LOOP1:
		; CALL CIN
		CALL S1GETHEX2
		CALL SOUTHEX
		JMP LOOP1

LOOP:
		; Sends 'Rnn\n'
		MVI A,'R'
		CALL COUT
		CALL SWITCHES
		CALL SOUTHEX
		MVI A,13
		CALL COUT
		LXI D,0FFFH
		JMP HEXPARSE

; ---------------------------------------------------------------------------
; Sets the console to the driver pointer by HL
; Inits the console
; ---------------------------------------------------------------------------
SETCONSOLE:
	MVI A,0C3H
	STA CINIT
	STA COUT
	STA CIN

	MOV A,M
	INX H
	STA CINIT+1
	MOV A,M
	INX H
	STA CINIT+2

	MOV A,M
	INX H
	STA COUT+1
	MOV A,M
	INX H
	STA COUT+1

	MOV A,M
	INX H
	STA CIN+1
	MOV A,M
	INX H
	STA CIN+1

	JMP CINIT

; ---------------------------------------------------------------------------
; The serial port from the MIO card
; ---------------------------------------------------------------------------

SERIAL1:
	DW MIO_SINIT
	DW MIO_SOUT
	DW MIO_SIN

; ---------------------------------------------------------------------------
; INIT
; ---------------------------------------------------------------------------
MIO_SINIT:
	XRA A 			; SET UP CONTROL REG
	OUT MIO_CNT

	RET

; ---------------------------------------------------------------------------
; OUTPUT
; ---------------------------------------------------------------------------

MIO_SOUT:
	PUSH PSW
L0000:
	IN MIO_CNT			; WAIT FOR TRANSMIT READY
	ANI 01H
	JZ L0000

	POP PSW

	OUT MIO_SIO 		;CHAR OUT
	RET

; ---------------------------------------------------------------------------
; INPUT
; ---------------------------------------------------------------------------

;INPUT A CHAR WHEN READY. IF AN ERROR
;OCCURS, PUT PE,CE,FE,RRDY,TROY IN 4 TO 0
MIO_SIN:
		IN MIO_CNT 			;SEE IF READY ON ERROR
		ANI 0AH
		JZ MIO_SIN
		; RZ
		XRI 0AH 		;YES, TEST ERROR
		JZ MIO_SIN1
		XRI 2 			;SEE IF OLD ERROR PLAG
		JZ MIO_SIN
		; RZ 				; IF SO, RETURN
		IN MIO_SIO 			;NO ERROR, GET CHAR
		RET
MIO_SIN1:
		MVI A,80H 		;GET ERROR BITS
		OUT MIO_CNT 		;PARITY ERROR
		IN MIO_CNT
		ANI 3
		RLC
		MOV B,A
		MVI A,0C0H 		;FRAMING ERROR
		OUT MIO_CNT
		IN MIO_CNT
		ANI 8
		RRC
		ADD B
		MOV B,A
		MVI A,40H 		;OVERUN,RRDY AND TRDY
		OUT MIO_CNT
		IN MIO_CNT
		ANI 0BH
		ADD B
		MOV B,A
		IN MIO_SIO 			;CLEAR CHARACTER
		XRA A 			;RESET CONTROL FOR ERROR FLAG
		OUT MIO_CNT
		ORI 80H
		MOV A,B
		RET








; ---------------------------------------------------------------------------
; Read a hex digit from STDIN
; ---------------------------------------------------------------------------
S1GETHEX1:
	; Read a character
	CALL CIN

	; Convert to hex
	CPI '0'
	JC S1GETHEX1  ; <'0' => retry
	CPI '9' + 1
	JNC CONT0000  ; <'9' => convert to hex
	SUI '0'
	RET

CONT0000:
	; Convert to hex
	CPI 'A'
	JC S1GETHEX1
	CPI 'F' + 1
	JNC S1GETHEX1
	SUI 'A' - 10
	RET

; ---------------------------------------------------------------------------
; Reads two hex digits from the serial port
; Update C with the checksum
; ---------------------------------------------------------------------------
S1GETHEX2:
	PUSH B
	CALL S1GETHEX1	; Get first digit
	RAL
	RAL
	RAL
	RAL
	MOV B,A			; *16
	CALL S1GETHEX1	; Get second digit
	ORA B			; Mix with first digit
	MOV B,A
	ADC C			; Update checksum
	MOV C,A			; Store checksum
	MOV B,A
	POP B
	RET

; ---------------------------------------------------------------------------
; Reads four hex digits from the serial port into HL
; Update C with the checksum
; ---------------------------------------------------------------------------
S1GETHEX4:
	PUSH PSW
	CALL S1GETHEX2
	MOV H,A
	CALL S1GETHEX2
	MOV L,A
	POP PSW
	RET

; ---------------------------------------------------------------------------
; Read and execute HEX file from the serial port
; ---------------------------------------------------------------------------
HEXPARSE:
	; Read ':'
	CALL CIN
	CPI ':'
	JNZ	 HEXPARSE

	; DEBUG
	MVI A,':'
	CALL COUT

	; Checksum starts at 0
	MVI C,0

	; Read the length
	CALL S1GETHEX2
	MOV B,A

		; Read the address
	CALL S1GETHEX4
		; Check if start address already set
	MOV A,D
	ANA E
	CPI 0FFH
	JNZ CONT0001	; DE != 0FFFFH

		; Load new start address
	MOV D,H
	MOV E,L

CONT0001:
	; Read the type
	CALL S1GETHEX2

	; Type 01: end record
	CPI 01H
	JNZ CONT0002

; Type 01: END RECORD, START
	MOV H,D
	MOV L,E
	PCHL

CONT0002:
	; Type 00: data record
	CPI 00H
	JNZ ERROR

; Type 00: DATA RECORD
LOOP2:
	MOV A,B
	CPI 0
	JZ DATAREAD
	CALL S1GETHEX2
	MOV M,A
	INX H
	ADD C
	MOV C,A
	DCR B
	JMP LOOP2

DATAREAD:
	CALL S1GETHEX2	; Last checksum byte
	MOV A,C
	CPI 0
	JNZ ERROR

	MVI A,'+'
	CALL COUT
	JMP HEXPARSE

ERROR:
	MVI A,'-'
	CALL COUT
	JMP HEXPARSE

; ---------------------------------------------------------------------------
; Outputs a string pointed by (HL)
; ---------------------------------------------------------------------------
SOUTSTR:
		MOV A,M
		CPI 0
		RZ
		CALL COUT
		INX H
		JMP SOUTSTR

; ---------------------------------------------------------------------------
; Outputs A for debug
; ---------------------------------------------------------------------------
S2DBGA:
		PUSH PSW
		PUSH PSW
		MVI A,'['
		CALL COUT
		POP PSW
		CALL SOUTHEX
		MVI A,']'
		CALL COUT
		POP PSW
		RET

; ---------------------------------------------------------------------------
; Outputs A in hex on the serial port #2
; ---------------------------------------------------------------------------
SOUTHEX:
		PUSH PSW
		RRC
		RRC
		RRC
		RRC
		CALL SOUTHEX1
		POP PSW
SOUTHEX1:				; OUTPUT LOW NIBBLE OF A IN HEX
		ANI 0FH
		CPI 0AH
		JC SOH1
		ADI 7
SOH1:	ADI 30H
		JMP COUT

; ---------------------------------------------------------------------------
; Read the front panel switches
; ---------------------------------------------------------------------------
SWITCHES:
		IN SSPT
		RET


		END
