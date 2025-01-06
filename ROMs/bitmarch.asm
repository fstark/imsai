
		ORG 0H

BITMARCH:
		MVI A,0FEH  ; Load initial display value (inverted)
LOOP:
		OUT 0FFH    ; Display it
		RLC         ; Rotate the bit left 1 position
		MOV B,A     ; Save it
		; IN  0FFH    ; Read the switches for the delay
		MVI A,03CH
		INR A       ; Make sure it's greater than zero
		MOV D,A     ; Load it into outer loop counter
LOOP2:
		MVI E,0FFH  ; Load the inner loop counter
LOOP1:
		DCR E       ; Decrement the inner loop counter
		JNZ LOOP1   ; Loop until zero
		DCR D       ; Decrement the outer loop counter
		JNZ LOOP2   ; Loop until zero
		MOV A,B     ; Restore the display value
		JMP LOOP    ; Loop forever

		END
