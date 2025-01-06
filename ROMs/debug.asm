; ---------------------------------------------------------------------------
; Code layout
; ---------------------------------------------------------------------------
START   EQU 00000H
STACK 	EQU 00C00H
DATA: 	EQU 00800H

; ---------------------------------------------------------------------------
; Hardware definitions
; ---------------------------------------------------------------------------
SIO 	EQU 42H         ; Serial I/O
CNT 	EQU 43H         ; Control
SSPT 	EQU 0FFH 		; Front panel switches and lights

; ---------------------------------------------------------------------------
; Startup code
; ---------------------------------------------------------------------------
        ORG START
    	LXI SP,STACK
		XRA A 			; SET UP CONTROL REG
		OUT CNT
EMITA1:
		MVI A,41H
		CALL COUT
		JMP EMITA1

; ---------------------------------------------------------------------------
; Output character on serial port
; ---------------------------------------------------------------------------
SOUT: 	MOV B,A 		;WAIT TIL READY
SOUT1: 	IN CNT
		ANI 1
		JZ SOUT1
		MOV A,B
		OUT SIO 		;CHAR OUT
		RET

COUT 	EQU SOUT

LEN     EQU $-START

        END
