; ---------------------------------------------------------------------------
; Code layout
; ---------------------------------------------------------------------------
START   EQU 0C000H
TEST	EQU 0C3C3H

; ---------------------------------------------------------------------------
; Hardware definitions for MIO card (serial only)
; ---------------------------------------------------------------------------
MIO_SIO 	EQU 42H         ; Serial I/O
MIO_CNT 	EQU 43H         ; Control

		ORG START
		JMP TEST

		ORG TEST
		DI
		XRA A 			; SET UP CONTROL REG
		OUT MIO_CNT

						; Outputs 0-7F in a loop
		MVI B,0

SOUTL1: IN MIO_CNT
		ANI 1
		JZ SOUTL1

		MOV A,B
		ANI 7FH
		INR B
		OUT MIO_SIO 		;CHAR OUT
		JMP	SOUTL1

		END
