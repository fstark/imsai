# Compupro System Support 1

Swiss army knife type of board:
* Interrupts
* Math coprocessor (not installed on ours)
* Serial
* 4K RAM or ROM (2 * 2k sockets)
* Timers
* RTC

## Configuration

Pins 20 and 70 have been isolated with kapton tape, to prevent them from causing issues with the Imsai CPA front panel.
They are grounded on IEEE-696 boards.

TODO:
* Make sure J13 is properly configured, see page 12 (pdf page 16) of manual.
* Make sure rest of RAM responds to PHANTOM*. See manual page 12
* pSTVAL: cut J11 trace between B and C, wire A to C. See manual page 17

## Documentation

[Manual](https://www.hartetechnologies.com/manuals/CompuPro/CompuPro%20System%20Support%201.pdf)
