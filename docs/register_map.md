# Register Map — AgriDrone Co-Processor

Accès via SPI peripheral (mode 0). Protocole trame 24 bits :

```
bit 23    : R/W (1 = write, 0 = read)
bits 22:16: adresse registre (7 bits)
bits 15:0 : donnée 16 bits
```

## Carte des registres

| Addr  | Nom              | Accès | Reset | Description |
|-------|------------------|-------|-------|-------------|
| 0x00  | `CTRL`           | R/W   | 0x0000 | bit0=enable global, bit1=spray_en, bit2=arm |
| 0x01  | `STATUS`         | R     | —     | bit0=wdog_trip, bit1=armed, bit2=spray_active |
| 0x02  | `WDOG_TIMEOUT`   | R/W   | 0x00C8 | Timeout heartbeat en ms (default 200 ms) |
| 0x03  | `WDOG_KICK`      | W     | —     | Écriture = reset du watchdog (heartbeat) |
| 0x04  | `PWM_PERIOD`     | R/W   | 0x9C40 | Période PWM (ticks horloge). 40000 @ 50 MHz = 1.25 kHz |
| 0x08  | `PWM_DUTY0`      | R/W   | 0x0000 | Rapport cyclique canal 0 (moteur 1) |
| 0x09  | `PWM_DUTY1`      | R/W   | 0x0000 | Canal 1 (moteur 2) |
| 0x0A  | `PWM_DUTY2`      | R/W   | 0x0000 | Canal 2 (moteur 3) |
| 0x0B  | `PWM_DUTY3`      | R/W   | 0x0000 | Canal 3 (moteur 4) |
| 0x0C  | `PWM_DUTY4`      | R/W   | 0x0000 | Canal 4 (moteur 5) |
| 0x0D  | `PWM_DUTY5`      | R/W   | 0x0000 | Canal 5 (moteur 6) |
| 0x0E  | `PWM_DUTY6`      | R/W   | 0x0000 | Canal 6 (moteur 7) |
| 0x0F  | `PWM_DUTY7`      | R/W   | 0x0000 | Canal 7 (moteur 8) |
| 0x10  | `SPRAY_DUTY`     | R/W   | 0x0000 | PWM valve pulvérisation (0 = fermée) |
| 0x11  | `SPRAY_FLOW`     | R     | 0x0000 | Compteur impulsions débitmètre depuis dernier read |
| 0x20  | `ALT_BARO_IN`    | W     | —     | Mesure baromètre (fournie par MCU) |
| 0x21  | `ALT_SONAR_IN`   | W     | —     | Mesure sonar (fournie par MCU) |
| 0x22  | `ALT_FUSED`      | R     | 0x0000 | Altitude fusionnée filtrée |
| 0x23  | `ALT_ALPHA`      | R/W   | 0x2000 | Coefficient IIR Q1.15 (default 0.25) |
| 0x7F  | `CHIP_ID`        | R     | 0xA6D1 | "AgriDrone" magic |

## Comportement de sécurité

- Si `WDOG_KICK` n'est pas écrit dans la fenêtre `WDOG_TIMEOUT`, **tous les PWM passent à 0**, `SPRAY_DUTY` est forcé à 0, et `STATUS.wdog_trip` est armé.
- Le reset du watchdog nécessite d'écrire `CTRL.arm = 1` puis `WDOG_KICK`.
- `CTRL.enable = 0` force toutes les sorties PWM à 0 immédiatement.
