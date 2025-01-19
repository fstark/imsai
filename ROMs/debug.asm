; ---------------------------------------------------------------------------
; Code layout
; ---------------------------------------------------------------------------
START   EQU 00000H
STACK 	EQU 00C00H
DATA 	EQU 00800H
SWITCHES EQU DATA+0

; PROGRAM EQU 00A00H ; The progam load zone
; PROGRAM EQU 00800H ; The progam load zone

; ---------------------------------------------------------------------------
; IMSAI HARDWARE DEFS
; ---------------------------------------------------------------------------
SSPT 	EQU 0FFH 		; Front panel switches and lights

; ---------------------------------------------------------------------------
; Prefixes:
;   MIO_ : MIO card
; 	SS1_ : System Support 1
;   S: SERIAL
;   S1: SERIAL 1 (MIO)
;   S2: SERIAL 2 (SYSTEM SUPPORT 1)
; S1INIT / S2INIT : Initialize SIO / SSIO
; S1OUT / S2OUT : Output character on SIO / SSIO
; S1OUTSTR / S2OUTSTR : Output string on SIO / SSIO
; S1INP / S2INP : Input character from SIO / SSIO
; ---------------------------------------------------------------------------



; ---------------------------------------------------------------------------
; Hardware definitions for MIO card (serial only)
; ---------------------------------------------------------------------------
MIO_SIO 	EQU 42H         ; Serial I/O
MIO_CNT 	EQU 43H         ; Control

; ---------------------------------------------------------------------------
; Hardware definitions for System Support 1 (serial only)
; ---------------------------------------------------------------------------
SS1_BASE	EQU 0A0H		; base address of System Support 1
SS1_DATA	EQU SS1_BASE+0CH	; UART data register
SS1_STATUS	EQU SS1_BASE+0DH	; UART status register
SS1_MODE	EQU SS1_BASE+0EH	; UART mode register
SS1_CMND	EQU SS1_BASE+0FH	; UART command register
SS1_TBE	EQU 01H		; transmitter buffer empty status bit
; RDA	EQU 02H		; receiver data available status bit

; ---------------------------------------------------------------------------
;   ###     ###     ###     ###
;  #   #   #   #   #   #   #   #
; # #   # # #   # # #   # # #   #
; #  #  # #  #  # #  #  # #  #  #
; #   # # #   # # #   # # #   # #
;  #   #   #   #   #   #   #   #
;   ###     ###     ###     ###
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; Startup code
; ---------------------------------------------------------------------------
        ORG START
		DI
    	LXI SP,STACK

DISPATCH:
		IN SSPT			; READ SWITCHES
		MOV H,A			; High address
		MVI L,00		; Low = 0
		PCHL			; Jump to address in HL

; ---------------------------------------------------------------------------
;	Check if switch changed. If changed, dispatch
; ---------------------------------------------------------------------------

CHK:
		IN SSPT
		MOV B,A
		LDA SWITCHES
		XRA B
		RZ
		MOV A,B
		STA SWITCHES
		JMP DISPATCH

; ---------------------------------------------------------------------------
; In case of RST 7 opcode 0FFH (unmapped memory), we loop with serial spam
; ---------------------------------------------------------------------------

		ORG 038H
ARGH:	JMP ARGH
		; MVI A,'X'
		; ; OUT SS1_DATA
		; OUT MIO_SIO
		; JMP ARGH

; ---------------------------------------------------------------------------
; SSIO UTILITIES
; ---------------------------------------------------------------------------

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
;   ###     ###     ###      #
;  #   #   #   #   #   #    ##
; # #   # # #   # # #   #  # #
; #  #  # #  #  # #  #  #    #
; #   # # #   # # #   # #    #
;  #   #   #   #   #   #     #
;   ###     ###     ###    #####
; ---------------------------------------------------------------------------
; Output 'A' on MIO_SIO in a loop
; ---------------------------------------------------------------------------

		ORG 0100H

		CALL S1INIT
EMITA1:
		CALL CHK
		MVI A,41H
		CALL S1OUT
		JMP EMITA1

S1INIT:
		XRA A 			; SET UP CONTROL REG
		OUT MIO_CNT
		RET

; ---------------------------------------------------------------------------
; Output character on MIO_SIO
; ---------------------------------------------------------------------------
S1OUT: 	MOV B,A 		;WAIT TIL READY
SOUTL1: IN MIO_CNT
		ANI 1
		JZ SOUTL1
		MOV A,B
		OUT MIO_SIO 		;CHAR OUT
		RET



; ---------------------------------------------------------------------------
;   ###     ###      #      ###
;  #   #   #   #    ##     #   #
; # #   # # #   #  # #    # #   #
; #  #  # #  #  #    #    #  #  #
; #   # # #   # #    #    #   # #
;  #   #   #   #     #     #   #
;   ###     ###    #####    ###
; ---------------------------------------------------------------------------
; Read from MIO_SIO, Write to MIO_SIO
; ---------------------------------------------------------------------------

		ORG 0200H

		CALL S1INIT
LOOP2:
		CALL CHK
		CALL S1INP
		JZ LOOP2
		JM LOOP2
		CALL S1OUT
		JMP LOOP2

; ---------------------------------------------------------------------------
; SSIO utility routines
; ---------------------------------------------------------------------------

S2INIT:
		MVI A,11101110B	; data for mode register 1
		OUT SS1_MODE	; send it
		MVI A,01111110B	; data for mode register 2
		OUT SS1_MODE	; send it
		MVI A,00100111B	; data for command register
		OUT SS1_CMND	; send it
		RET

S2OUT:
		MOV B,A		; save character
SOUTL2:
		IN SS1_STATUS	; read the status register
		ANI SS1_TBE		; mask out all bits but SS1_TBE
		JZ SOUTL2	; if it's not high, loop
		MOV A,B
		OUT SS1_DATA	; and send it
		RET

; ---------------------------------------------------------------------------
;   ###     ###      #       #
;  #   #   #   #    ##      ##
; # #   # # #   #  # #     # #
; #  #  # #  #  #    #       #
; #   # # #   # #    #       #
;  #   #   #   #     #       #
;   ###     ###    #####   #####
; ---------------------------------------------------------------------------
; Output 'A' on SSIO
; ---------------------------------------------------------------------------

		ORG 0300H
		CALL S2INIT

		MVI A,'X'
		CALL S2OUT

EMITC1:
		CALL CHK
		MVI A,'C'
		CALL S2OUT
		JMP EMITC1


; ---------------------------------------------------------------------------
;   ###      #      ###     ###
;  #   #    ##     #   #   #   #
; # #   #  # #    # #   # # #   #
; #  #  #    #    #  #  # #  #  #
; #   # #    #    #   # # #   # #
;  #   #     #     #   #   #   #
;   ###    #####    ###     ###
; ---------------------------------------------------------------------------
; Read from MIO_SIO, Write to SSIO
; ---------------------------------------------------------------------------

		ORG 0400H

		CALL S1INIT
		CALL S2INIT
LOOP4:
		CALL S1INP		; Wait for user key
		CALL S1OUT		; Echo
		CALL S2OUT		; Send to modem

		JMP LOOP4

; ---------------------------------------------------------------------------
;   ###      #      ###      #
;  #   #    ##     #   #    ##
; # #   #  # #    # #   #  # #
; #  #  #    #    #  #  #    #
; #   # #    #    #   # #    #
;  #   #     #     #   #     #
;   ###    #####    ###    #####
; ---------------------------------------------------------------------------
; Simple netboot over wifi modem
; ---------------------------------------------------------------------------

		ORG 0500H

		CALL S1INIT
		CALL S2INIT
NETBOOT:
		; Load HL with MODEM
		LXI H,MODEM
		CALL S1OUTSTR

		; Wait for a '#'
LOOP5:	CALL S1INP
		CALL S2DBGA
		CPI '#'
		JNZ LOOP5

		CALL S2CRLF

		; Load data size in DE (#### SHOULD BE BC)
		CALL S1INP
		MOV D,A
		CALL S2DBGA
		CALL S1INP
		MOV E,A
		CALL S2DBGA

		CALL S2CRLF

		JMP READPROG

S2CRLF:			; CRLF on serial 2
		MVI A,13
		CALL S2OUT
		MVI A,10
		JMP S2OUT


MODEM:	DB "ATD8080",13,"BOOT",13, 0
; ---------------------------------------------------------------------------
; Outputs a string pointed by (HL)
; ---------------------------------------------------------------------------
S1OUTSTR:
		MOV A,M
		CALL S1OUT
		CALL S2DBGA
		INX H
		MOV A,M
		CPI 0
		JNZ S1OUTSTR
		RET

; ---------------------------------------------------------------------------
; Outputs a string pointed by (HL)
; ---------------------------------------------------------------------------
S2OUTSTR:
		MOV A,M
		CALL S2OUT
		INX H
		MOV A,M
		CPI 0
		JNZ S2OUTSTR
		RET

; ---------------------------------------------------------------------------
; Outputs A for debug
; ---------------------------------------------------------------------------
S2DBGA:
		PUSH PSW
		PUSH PSW
		MVI A,'['
		CALL S2OUT
		POP PSW
		CALL S2OUTHEX
		MVI A,']'
		CALL S2OUT
		POP PSW
		RET

		ORG 0600H

; ---------------------------------------------------------------------------
; Outputs A in hex on the serial port #2
; ---------------------------------------------------------------------------
S2OUTHEX:
		PUSH PSW
		RRC
		RRC
		RRC
		RRC
		CALL S2OUTHEX1
		POP PSW
S2OUTHEX1:				; OUTPUT LOW NIBBLE OF A IN HEX
		ANI 0FH
		CPI 0AH
		JC S2OH1
		ADI 7
S2OH1:	ADI 30H
		JMP S2OUT

READPROG:
		; Load program address in HL
		CALL S1INP
		MOV L,A
		CALL S2DBGA
		CALL S1INP
		MOV H,A
		CALL S2DBGA

		CALL S2CRLF

		PUSH H

NEXT:
		CALL S1INP
		CALL S2DBGA
		MOV M,A
		INR H
		DCR D
		JNZ NEXT

		MVI A,'*'
		CALL S2OUT

		CALL S2CRLF
		; CALL S2CRLF

		POP H
		PCHL



COUT 	EQU S1OUT

LEN     EQU $-START

        END
