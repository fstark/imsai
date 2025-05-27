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
START   EQU 00000H

SSPT	EQU 0FFH 			;SENSE LIGHTS AND SWITCHES

	INCL "rom.inc"

STACK 	EQU MEMSTART+100H
CHECKSUM EQU VARSTART+10H

; ---------------------------------------------------------------------------
; Hooks stack
; ---------------------------------------------------------------------------

HOOK_TOP 	EQU VARSTART+20H
HOOK_STACK 	EQU VARSTART+40H

; ---------------------------------------------------------------------------

	ORG 00000H
	JMP COLDSTART

	ORG 00020H
	JMP COLDSTART

	ORG 038H
    JMP 038H

	ORG COUTSTR
	JMP COUTSTRIMP

INIT_HOOKS:
	; Initialize the HOOK stack pointer
	LXI H,HOOK_STACK
	SHLD HOOK_TOP

	; Store 0xC3 in all hooks
	MVI B,0C3H
	MVI A,HOOKS_SIZE
	LXI H,HOOKS
	ORA A
LOOP4:
	RZ
	MOV M,B
	INX H
	INX H
	INX H
	DCR A
	JMP LOOP4

; IN  A  : Hook #
; OUT HL : Hook address
HOOK_GET:
	LHLD HOOKS
	INX H		; Skip the JMP
LOOP3:
	ORA A
	RZ
	DCR A
	INX H
	INX H
	INX H
	JMP LOOP3

; IN  A  : Hook #
; IN  DE : Function address
; WRONG: SHOULD PUSH THE OLD HOOK
HOOK_PUSH:
	PUSH H
	MOV B,A
	CALL HOOK_GET
	MOV E,M
	INX H
	MOV D,M
	LHLD HOOK_TOP
	DCX H
	MOV M,B
	DCX H
	MOV M,D
	DCX H
	MOV M,E
	SHLD HOOK_TOP
	POP D
HOOK_SET:
	CALL HOOK_GET
	MOV M,E
	INX H
	MOV M,D
	RET

; IN  A  : Hook #
HOOK_POP:
	LHLD HOOK_TOP
	MOV E,M
	INX H
	MOV D,M
	INX H
	MOV A,M
	INX H
	SHLD HOOK_TOP
	JMP HOOK_SET

; ---------------------------------------------------------------------------

COLDSTART:
		DI
		LXI SP,STACK
		; CALL SINIT
		CALL INIT_HOOKS
		LXI H,SERIAL1
		CALL SETCONSOLE

		MVI A,'A'
		CALL COUT

		LXI D,0FFFFH
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
		LXI D,0FFFFH
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
	STA COUT+2

	MOV A,M
	INX H
	STA CIN+1
	MOV A,M
	INX H
	STA CIN+2

	JMP CINIT




; ---------------------------------------------------------------------------
; Utilities
; ---------------------------------------------------------------------------

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
	LDA CHECKSUM	; Update checksum
	ADD B
	STA CHECKSUM	; Store checksum
	MOV A,B
	POP B

	PUSH PSW
	CALL S2DBGA
	LDA CHECKSUM
	CALL S2DBGA
	POP PSW

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
	MVI A,0
	STA CHECKSUM

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

	MVI A,'*'
	CALL COUT

	MOV A,H
	CALL S2DBGA
	MOV A,L
	CALL S2DBGA

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
	DCR B
	JMP LOOP2

DATAREAD:
	CALL S1GETHEX2	; Last checksum byte
	LDA CHECKSUM
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
COUTSTRIMP:
		MOV A,M
		CPI 0
		RZ
		CALL COUT
		INX H
		JMP COUTSTRIMP

; ---------------------------------------------------------------------------
; Outputs A for debug
; IN:   A    ; value to display
; ---------------------------------------------------------------------------
S2DBGA:
		PUSH PSW
		MVI A,'['
		CALL COUT
		POP PSW
		PUSH PSW
		CALL SOUTHEX
		MVI A,']'
		CALL COUT
		POP PSW
		RET

; ---------------------------------------------------------------------------
; Outputs A in hex
; IN:   A    ; value to output
; OUT:  none
; Trashed: A ; A is modified during output
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
; OUT:  A    ; switch value returned
; ---------------------------------------------------------------------------
SWITCHES:
		IN SSPT
		RET

; ---------------------------------------------------------------------------
; Drivers
; ---------------------------------------------------------------------------

		INCL "sio.inc"	; Serial I/O from IMSAI MIO card

		END
