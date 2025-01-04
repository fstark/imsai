
# MIO Configuration

Below are some notes related to the IMSAI MIO REV 2 board configurations.

The main references are the 3 last pages from these schematics:
http://www.s100computers.com/Hardware%20Manuals/IMSAI/IMSAI_Schematics.pdf

Our board has the following configuration:
* Direction: made to run with a terminal
* Baud rate: 9600
* UART: 8 bit, no parity, 1 stop bit
* Cassette: 800bps
* Input jumpers: same config used for test programs (see Appendix D - Figure 8)
  * 0: TRDY
  * 1: RRDY
  * 2: CRIS
  * 3: SIOS
  * 4: PIOS
  * 5: REIA4
  * 6: REIA3
  * 7: REIA2
* Internal address: IMSAI SIO (3-14, 8-9):
  * CRI=0, PIO=1, SIO=2, CONT=3

Two bodges:
* U7 pin 4 (Receiver Register Disconnect) to SIO connector pin 18
* 10pF cap between U34 pin 12 and 14 (see errata)

### U1: DIRECTION JUMPER AREA

```
    ┌──────┐
TD  ╡9    8╞ O
RD  ╡      ╞ I
RTS ╡      ╞ O
CTS ╡      ╞ I
DTR ╡      ╞ O
DSR ╡      ╞ I
    ╡      ╞ O
CF  ╡16   1╞ I
    └──────┘
```

### U2: OUTPUT JUMPER AREA (OJA)

See section III, page 2-9

```
           ┌──────┐
   GROUND  ╡9    8╞ 1 EIA
    TTL 2  ╡      ╞ 2 EIA
        1  ╡      ╞ 3 EIA
        T  ╡      ╞ 4 EIA
CR BITS 3  ╡      ╞ OC1
CR BITS 2  ╡      ╞ OC2
CR BITS 1  ╡      ╞ OC3
CR BITS 0  ╡16   1╞ CL
           └──────┘
```

### INPUT JUMPER AREA (IJA)

```

      F E   D  C  B  A

  7   o o   o  o  o  o
  6   o o   o  o  o  o
  5   o o   o  o  o  o
  4   o o   o  o  o  o
  3   o o   o  o  o  o
  2   o o   o  o  o  o
  1   o o   o  o  o  o
  0   o o   o  o  o  o
```

See table 6, page 2-15 for roles

  | F           | E      | D     | C     | B     | A
- | ----------- | ------ | ----- | ----- | ----- | ---
7 | Interrupt 7 | Ground | ITTL1 | O1DR  | PE    | SI7
6 | Interrupt 6 | Ground | ITTL2 | I1DA  | RRDY  | SI6
5 | Interrupt 5 | Ground | ITTL3 | O2DR  | FE    | SI5
4 | Interrupt 4 | Ground | CRIS  | I2DA  | TRDY  | SI4
3 | Interrupt 3 | Ground | REIA1 | PIOS  | /TRDY | SI3
2 | Interrupt 2 | Ground | REIA2 | PRDY  | /RRDY | SI2
1 | Interrupt 1 | Ground | REIA3 | CLI   | SIOS  | SI1
0 | Interrupt 0 | Ground | REIA4 | RDATA | OE    | SI0

Silkscreen does not match schematics, the schematics are true, silk is wrong (see errata)

### UART CONFIGURATION JUMPER AREA (T7)

Direct TR1602 (= TMS6011) configuration. See [datasheet](https://deramp.com/downloads/mfe_archive/050-Component%20Specifications/Western%20Digital/TR1602B%20UART.pdf)

```
      A  B  C

  4   o  o  o
  3   o  o  o
  2   o  o  o
  1   o  o  o
  0   o  o  o
```

Columns (See Table 7, page 2-18)
* A = GND
* B = 5V
* C4 = WLS1 = Word Length Select bit 1 = character length, parity excluded
* C3 = SBS = Stop Bit(s) Select = High for 2 stop bits, Low for 1 stop bit
* C2 = PI = Parity Inhibit = Set high to disable parity checks
* C1 = WLS2 = Word Length Select bit 2
* C0 = EPE = Even Parity Enable = Set high for even parity, low for odd parity

### STROBE EDGE CONTROL JUMPER AREA

TODO

### BOARD ADDRESS JUMPER AREA (BD.AD)

TODO

### PIO STROBE POLARITY JUMPER

TODO

### SIO BAUD RATE JUMPER AREA

* Column A = GND
* Column B = 5V
* Column C = bits

Careful, Column order isn't the same in the 3 sections

Baud rate to bit setup (Table 8, page 2-19):

 BAUD | HEX | 11| 10| 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0
 ---- | --- | - | - | - | - | - | - | - | - | - | - | - | -
 9600 | FE8 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 1 | 0 | 0 | 0
 4800 | FDB | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 1 | 1 | 0 | 1 | 1
 2400 | FC1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1
 1200 | F8D | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0 | 1 | 1 | 0 | 1
  600 | F25 | 1 | 1 | 1 | 1 | 0 | 0 | 1 | 0 | 0 | 1 | 0 | 1
  300 | E54 | 1 | 1 | 1 | 0 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 0
  150 | CB4 | 1 | 1 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 1 | 0 | 0
134.5 | C54 | 1 | 1 | 0 | 0 | 0 | 1 | 0 | 1 | 0 | 1 | 0 | 0
  110 | B85 | 1 | 0 | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 1
   75 | 972 | 1 | 0 | 0 | 1 | 0 | 1 | 1 | 1 | 0 | 0 | 1 | 0
 45.5 | 53A | 0 | 1 | 0 | 1 | 0 | 0 | 1 | 1 | 1 | 0 | 1 | 0


### INTERNAL ADDRESS JUMPER AREA

See table 2, page 2-8

Specific combinations to map port numbers to devices

### CRI INPUT JUMPER AREA

TODO

### CRI BIT RATE JUMPER AREA

Cassette bit rate:

* Column A: GND
* Column B: 5V

See page 2-31 + erratas ECN 77-0014

Bit rate | Hex | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0
-------- | --- | - | - | - | - | - | - | - | -
800      | 64  | 0 | 1 | 1 | 0 | 0 | 1 | 0 | 0
1500     | AD  | 1 | 0 | 1 | 0 | 1 | 1 | 0 | 1
1689     | B6  | 1 | 0 | 1 | 1 | 0 | 1 | 1 | 0
2400     | CC  | 1 | 1 | 0 | 0 | 1 | 1 | 0 | 0
4800     | E6  | 1 | 1 | 1 | 0 | 0 | 1 | 1 | 0
