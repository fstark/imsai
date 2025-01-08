# IMSAI CP-A Front Panel

## Documentation

* [Manual](https://deramp.com/downloads/mfe_archive/010-S100%20Computers%20and%20Boards/00-Imsai/20-Imsai%20Systems/Imsai%208080/2002%20Manual%20in%20Sections/04-Imsai%20CPA%20Manual%202002.pdf)
  * Main manual section 4 (4-1 -> 4.28)
  * Rev 4 modification to properly stop at power-up (1977/03)
  * Errata for Rev 4 and earlier, to use with DRAM
  * Optional mod to convert power switch to memory protect
* [Layout](https://deramp.com/downloads/mfe_archive/010-S100%20Computers%20and%20Boards/00-Imsai/20-Imsai%20Systems/Imsai%208080/My%20Manual%20Scans/Imsai%20CPA%20Assembly.pdf)
* Schematics:
  * [Old schematics](https://deramp.com/downloads/mfe_archive/010-S100%20Computers%20and%20Boards/00-Imsai/20-Imsai%20Systems/Imsai%208080/My%20Manual%20Scans/Imsai%20CPA%20Schematic-old.pdf) (1976/02)
  * [Schematics](https://www.parastream.com/downloads/support3rd/IMSAI%20CPA%20Schematic.pdf) (1977/08)
  * [Modern rewite](https://bitsavers.org/pdf/imsai/schematic/IMSAI_CPA_2014.pdf) (2014)

## Modifications

4 bodge wires (recheck numbering):
* Cause front panel to come up in "stop" at power time
  * U16 pin 11 - U16 pin 12 - U18 pin 13
  * U16 pin 13 - U22 pin 11
* U22 pin 6 - U20 pin 11
* U19 pin 9 - U23 11

The "always stop" modification might be missing a cut trace between U22 pin 11 and 4, needs rechecking.

1 cut trace on:
* U17 pin 2 disconnected from what might be U19 pin 2?

TODO: Check cut traces component side

Front facing traces with line power were removed by the previous owner, and the power cables were soldered directly to the switch. Very likely to prevent shocks when touching the front panel without the acrylic glass.
