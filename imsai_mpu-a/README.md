# MPU-A Rev. 4 CPU board

## State

Working but A6 line is internally disconnected in the CPU. CPU needs to be replaced (8080A, not 8080)

## Modifications

One cut trace to disable the "Sense Switch Disable" signal. Between A2 pin 5 and S-100 pin 53.

As per the errata, the following are not installed (only required for a big quartz):
* C4: .1uF cap
* L1: 1.0uH inductor
* C17: 56pF capacitor

## Documentation

Manual available [here](https://deramp.com/downloads/mfe_archive/010-S100%20Computers%20and%20Boards/00-Imsai/10-Imsai%20S100%20Boards/Imsai%20MPU-A%208080%20CPU/05-Imsai%20MPU-A%20Manual%202002.pdf)

TODO: Scan errata
