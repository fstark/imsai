; MIO BOARD CRI INITIALISATION PROGRAM
; ADDRESS DEFINITIONS FOR MIO BOARD
; AS DEFINED IN MIO USER GUIDE - SECTION 1.2
SIO EQU 42H
PIO EQU 41H
CNT EQU 43H
CRI EQU 40H
SSPT EQU 0FFH ;SENSE LIGHTS AND SWITCHES
; BASA EQU 3100H
BASA EQU 0C3C3H
BASB EQU 3000H
BUFR EQU 3600H
STACK EQU 3600H

	ORG 0C000H
	DB "TEST ROM"

	ORG BASA
;JUMP TABLE FOR ENTRY TO MIO TESTS
	JMP SIO1
	; JMP SIO2
	; JMP SIO3
	; JMP PIO1
	; JMP PIO2
	; JMP PIO3
	; JMP CRIWT
	; JMP CRIRT

;SIO TEST 1 QUTPUT THE VALUE CONTAINED IN THE
; SENSE SWITCRES TO THE SIO PORT. IF AN
; INPUT CHARACTER IS READY AND NO INPUT
; ERRORS OCCUR DISPLAY THE CHARACTER IN
; THE SENSE LIGHTS. IF AN INPUT ERROR
; OCCURS, DISPLAY ALL ONES. PAUSE 15
; SECONDS EACH TIME THE SWITCHES ARE CHANGED.
SIO1:	LXI SP,STACK
		XRA A ;SET UP CONTROL REG
		OUT CNT
SIO11:	CALL SSIN ;GET SENSE SWITCHES
		CALL SOUT ;OUTPUT CHAR
		CALL SINP ;TEST INPUT
		JZ SIO1 ;IF NO INPUT READY
		CMA
		OUT SSPT ;OUTPUT, CHAR OR ERROR FLAG
		JMP SIO11


;OUTPUT CHARACTER IN A WHEN DEVICE READY.
SOUT: MOV B,A ;WAIT TIL READY
SOUT1: IN CNT
	ANI 1
	JZ SOUT1
	MOV A,B
	OUT SIO ;CHAR OUT
	RET
;INPUT A CHAR WHEN READY. IF AN ERROR
;OCCURS, PUT PE,CE,FE,RRDY,TROY IN 4 TO 0
SINP: IN CNT ;SEE IF READY ON ERROR
	ANI 0AH
	RZ
	XRI 0AH ;YES, TEST ERROR
	JZ SIN1
	XRI 2 ;SEE IF OLD ERROR PLAG
	RZ ; IF SO, RETURN
	IN SIO ;NO ERROR, GET CHAR
	RET
SIN1: MVI A,80H ;GET ERROR BITS
	OUT CNT ;PARITY ERROR
	IN CNT
	 ANI 3
	RLC
	MOV B,A
	MVI A,0C0H ;FRAMING ERROR
	OUT CNT
	IN CNT
	ANI 8
	RRC
	ADD B
	MOV B,A
	MVI A,40H ;OVERUN,RRDY AND TRDY
	OUT CNT
	IN CNT
	ANI 0BH
	ADD B
	MOV B,A
	IN SIO ;CLEAR CHARACTER
	XRA A ;RESET CONTROL FOR ERROR FLAG
	OUT CNT
	ORI 80H
	MOV A,B
	RET
;INPUT SENSE SWITCHES-DELAY IF DIPPERENT
SSIN: IN SSPT ;GET THEM
	MOV B,A
	LDA SSAV ;COMPARE WITH PAST
	XRA B
	MOV A,B
	RZ
	CALL DLA5 ;DIFFERENT WAIT FOR A WHILE
	CALL DLA5
	CALL DLA5
	IN SSPT ;GET NEW VALUE
	STA SSAV
	RET
SSAV: DB 0
;DELAY 5 SECONDS. - REQUIRES 10 MILLION CYCLES (APPROXIMATELY)
DLA5: MVI A,0
	MVI C,201
DLA51: CALL DONE
	INR C
	JNZ DLA51
	INR A
	JNZ DLA51
	RET
DONE: PUSH H ;TAKE 121 CYCLES
	POP H
	PUSH H
	POP H
	PUSH H
	POP H
	PUSH H
	POP H
	PUSH H
	POP H
	MOV A,A
	RET

	END
	