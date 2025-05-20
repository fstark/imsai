; BOOT IMSAI USING SERIAL PORT

; ---------------------------------------------------------------------------
; Code layout
; ---------------------------------------------------------------------------
START   EQU 0C000H
TEST	EQU 0C3C3H
STACK 	EQU 0C00H



; ---------------------------------------------------------------------------
; Hardware definitions for MIO card (serial only)
; ---------------------------------------------------------------------------
MIO_SIO 	EQU 42H         ; Serial I/O
MIO_CNT 	EQU 43H         ; Control

SSPT	EQU 0FFH 		;SENSE LIGHTS AND SWITCHES

		ORG START
		JMP TEST

HELLO:	DB "HELLO, WORLD",0

		ORG TEST
		DI
		LXI SP,STACK
		CALL SINIT

LOOP1:
		; CALL S1INP
		CALL S1GETHEX2
		CALL SOUTHEX
		JMP LOOP1

LOOP:
		CALL SWITCHES
		CALL SOUTHEX
		MVI A,13
		CALL SOUT
		JMP LOOP

; ---------------------------------------------------------------------------
; Inits serial port #1
; ---------------------------------------------------------------------------
SINIT:
	XRA A 			; SET UP CONTROL REG
	OUT MIO_CNT
	RET

; ---------------------------------------------------------------------------
; Outputs a character on the serial port #1
; ---------------------------------------------------------------------------

SOUT:
	PUSH PSW
L0000:
	IN MIO_CNT			; WAIT FOR TRANSMIT READY
	ANI 01H
	JZ L0000

	POP PSW

	OUT MIO_SIO 		;CHAR OUT
	RET



;INPUT A CHAR WHEN READY. IF AN ERROR
;OCCURS, PUT PE,CE,FE,RRDY,TROY IN 4 TO 0
S1INP: 	IN MIO_CNT 			;SEE IF READY ON ERROR
		ANI 0AH
		JZ S1INP
		; RZ
		XRI 0AH 		;YES, TEST ERROR
		JZ SIN1
		XRI 2 			;SEE IF OLD ERROR PLAG
		JZ S1INP
		; RZ 				; IF SO, RETURN
		IN MIO_SIO 			;NO ERROR, GET CHAR
		RET
SIN1: 	MVI A,80H 		;GET ERROR BITS
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
; Read a hex digit from the serial port
; ---------------------------------------------------------------------------
S1GETHEX1:
	; Read a character
	CALL S1INP

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
; ---------------------------------------------------------------------------
S1GETHEX2:
	PUSH B
	CALL S1GETHEX1
	RAL
	RAL
	RAL
	RAL
	MOV B,A
	CALL S1GETHEX1
	ORA B
	POP B
	RET

; ---------------------------------------------------------------------------
; Reads four hex digits from the serial port into HL
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
; Read and execute an HEX record from the serial port
; ---------------------------------------------------------------------------
HEXPARSE:
	; Read ':'
	CALL S1INP
	CPI ':'
	JNZ	 HEXPARSE

	; Read the length
	CALL S1GETHEX2
	MOV B,A

	; Read the address
	CALL S1GETHEX4
	; -- first time, store in DE for future use

	; Read the type
	CALL S1GETHEX2

	; Type 01: end of record
	CPI 01H
	RZ

	; Type 00: data record
	CPI 00H
	JNZ ERROR

	RET

ERROR:
	RET

HEXDATA:


; ---------------------------------------------------------------------------
; Outputs a string pointed by (HL)
; ---------------------------------------------------------------------------
SOUTSTR:
		MOV A,M
		CPI 0
		RZ
		CALL SOUT
		INX H
		JMP SOUTSTR

; ---------------------------------------------------------------------------
; Outputs A for debug
; ---------------------------------------------------------------------------
S2DBGA:
		PUSH PSW
		PUSH PSW
		MVI A,'['
		CALL SOUT
		POP PSW
		CALL SOUTHEX
		MVI A,']'
		CALL SOUT
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
		JMP SOUT

; ---------------------------------------------------------------------------
; Read the front panel switches
; ---------------------------------------------------------------------------
SWITCHES:
		IN SSPT
		RET


		END
; READPROG:
; 		; Load program address in HL
; 		CALL S1INP
; 		MOV L,A
; 		CALL S2DBGA
; 		CALL S1INP
; 		MOV H,A
; 		CALL S2DBGA

; 		CALL S2CRLF

; 		PUSH H

; NEXT:
; 		CALL S1INP
; 		CALL S2DBGA
; 		MOV M,A
; 		INR H
; 		DCR D
; 		JNZ NEXT

; 		MVI A,'*'
; 		CALL S2OUT

; 		CALL S2CRLF
; 		; CALL S2CRLF

; 		POP H
; 		PCHL

