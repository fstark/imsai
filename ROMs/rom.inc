; Includes APIs for serial boot room usage

; ---------------------------------------------------------------------------
; Harware definitions
; ---------------------------------------------------------------------------

MEMSTART	EQU 01000H
MEMEND		EQU 02000H

VARSTART	EQU MEMSTART+200H

; ---------------------------------------------------------------------------
; Hooks definitions
; ---------------------------------------------------------------------------

HOOKS   	EQU VARSTART
CINITHOOK 	EQU 0
COUTHOOK 	EQU 1
CINHOOK 	EQU 2
HOOKS_SIZE	EQU 3

CINIT		EQU HOOKS+CINITHOOK*3
COUT		EQU HOOKS+COUTHOOK*3
CIN			EQU HOOKS+CINHOOK*3

; ---------------------------------------------------------------------------
; 'EXPORTED' ROM functions
; ---------------------------------------------------------------------------
FUNCTIONS	EQU 00080H
COUTSTR		EQU FUNCTIONS+0
