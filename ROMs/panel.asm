; A simple program that reads the switches and displays the value on the LEDs
	ORG 01200H

START:
		IN 0FFH
		OUT 0FFH
		JMP START

		END
