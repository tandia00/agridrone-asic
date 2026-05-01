# Brochage — AgriDrone Co-Processor

## Pins fonctionnels

| Pin | Nom | Dir | Description |
|-----|-----|-----|-------------|
| 1 | `clk` | IN | Horloge système 50 MHz |
| 2 | `rst_n` | IN | Reset asynchrone actif bas |
| 3 | `spi_sclk` | IN | SPI clock (du MCU master) |
| 4 | `spi_mosi` | IN | SPI data MCU→ASIC |
| 5 | `spi_miso` | OUT | SPI data ASIC→MCU |
| 6 | `spi_cs_n` | IN | SPI chip select actif bas |
| 7-14 | `pwm_out[7:0]` | OUT | 8 canaux PWM moteurs ESC |
| 15 | `spray_pwm` | OUT | PWM valve pulvérisation |
| 16 | `flow_pulse` | IN | Entrée débitmètre (impulsions) |
| 17 | `kill_n` | OUT | Signal kill-switch actif bas (safety) |
| 18 | `armed_led` | OUT | LED d'état armé |
| 19 | `wdog_trip_led` | OUT | LED watchdog déclenché |

## Pins d'alimentation (PDK SKY130)

| Pin | Nom | Description |
|-----|-----|-------------|
| — | `VPWR` | 1.8 V core |
| — | `VGND` | Ground core |
| — | `VDDIO` | 3.3 V I/O |
| — | `VSSIO` | Ground I/O |

**Total pins fonctionnels : 19** (+ alims). Tient largement dans un boîtier 40 pins OpenMPW standard.
