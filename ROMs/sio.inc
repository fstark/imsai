; ---------------------------------------------------------------------------
; Serial I/O from MIO card
; ---------------------------------------------------------------------------

; Entry points
SERIAL1:
	DW MIO_SINIT
	DW MIO_SOUT
	DW MIO_SIN

; ---------------------------------------------------------------------------
; Hardware definitions for MIO card (serial only)
; ---------------------------------------------------------------------------
MIO_SIO 	EQU 42H         ; Serial I/O
MIO_CNT 	EQU 43H         ; Control

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


