# Mapping Caravel / AgriDrone

La puce est soumise via le framework Efabless Caravel. Le design complet est intégré dans `user_project_wrapper.v`.

## Broches I/O (Pads)

Sur les 38 pads configurables de Caravel, l'AgriDrone utilise les GPIO [8] à [24], laissant les 0-7 (souvent réservés au boot/flash du SoC hôte) et les 25-37 libres.

| GPIO Pad | Nom AgriDrone | Direction | Description |
|---|---|---|---|
| `io_in[8]` | `spi_sclk` | IN | Horloge SPI du MCU externe |
| `io_in[9]` | `spi_mosi` | IN | Données MOSI du MCU |
| `io_out[10]` | `spi_miso` | OUT | Données MISO vers le MCU |
| `io_in[11]` | `spi_cs_n` | IN | Chip Select SPI |
| `io_out[12]` | `pwm_out[0]` | OUT | PWM Moteur 1 (Canal 0) |
| `io_out[13]` | `pwm_out[1]` | OUT | PWM Moteur 2 (Canal 1) |
| `io_out[14]` | `pwm_out[2]` | OUT | PWM Moteur 3 (Canal 2) |
| `io_out[15]` | `pwm_out[3]` | OUT | PWM Moteur 4 (Canal 3) |
| `io_out[16]` | `pwm_out[4]` | OUT | PWM Moteur 5 (Canal 4) |
| `io_out[17]` | `pwm_out[5]` | OUT | PWM Moteur 6 (Canal 5) |
| `io_out[18]` | `pwm_out[6]` | OUT | PWM Moteur 7 (Canal 6) |
| `io_out[19]` | `pwm_out[7]` | OUT | PWM Moteur 8 (Canal 7) |
| `io_out[20]` | `spray_pwm` | OUT | PWM de la valve de pulvérisation |
| `io_in[21]` | `flow_pulse` | IN | Compteur d'impulsions du débitmètre |
| `io_out[22]` | `kill_n` | OUT | Signal d'arrêt d'urgence |
| `io_out[23]` | `armed_led` | OUT | LED d'armement du contrôleur |
| `io_out[24]` | `wdog_trip_led` | OUT | LED indiquant une défaillance du watchdog |

## Signaux Système Internes

- `clk` : Connecté au `wb_clk_i` du bus Wishbone (fourni par la PLL interne de Caravel, typiquement 50 MHz).
- `rst_n` : Connecté à `~wb_rst_i` (le reset synchrone du SoC).

## Configuration du Firmware (SoC RISC-V)

Lors du boot de la puce, le SoC Management (le RISC-V intégré de Caravel) doit exécuter un firmware C configurant les multiplexeurs de pads (via la Management SoC GPIO matrix).

```c
// Exemple Firmware de boot Caravel
void main() {
    // Configurer le SPI Peripheral
    reg_mprj_io_8 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_9 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_11 = GPIO_MODE_USER_STD_INPUT_NOPULL;

    // Configurer les PWM moteurs et le Spray
    reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;
    // ... configurer 13 à 19 ...
    reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT;

    // Entrée Flow Meter
    reg_mprj_io_21 = GPIO_MODE_USER_STD_INPUT_NOPULL;

    // Sorties Status
    reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_USER_STD_OUTPUT;

    // Appliquer la configuration
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);
    
    // La zone utilisateur AgriDrone est maintenant connectée aux broches externes !
}
```
