# Architecture — AgriDrone Co-Processor ASIC

## Vue d'ensemble

```
              ┌─────────────────────────────────────────────┐
              │                   top                       │
              │                                             │
  spi_* ─────▶│ ┌─────────────┐    ┌──────────────────────┐ │
              │ │  spi_peripheral  │◀──▶│   register_file      │ │
              │ └─────────────┘    └──┬──────┬──────┬─────┘ │
              │                       │      │      │       │
              │                       ▼      ▼      ▼       │
              │             ┌──────────┐ ┌────────┐ ┌─────┐ │
              │             │pwm_multi │ │ spray  │ │ alt │ │
              │             │ channel  │ │  ctrl  │ │fusion│ │
              │             └────┬─────┘ └───┬────┘ └──┬──┘ │
              │                  │           │         │    │
              │                  │    ┌──────▼───┐     │    │
              │                  │    │ safety   │     │    │
              │                  │    │ watchdog │     │    │
              │                  │    └──┬───────┘     │    │
              │                  │       │             │    │
              └──────────────────┼───────┼─────────────┼────┘
                                 ▼       ▼             ▼
                              pwm_out  spray_pwm    (read via SPI)
                                      kill_n
```

## Domaine d'horloge

Tout est synchrone sur `clk` (50 MHz). Les entrées asynchrones (SPI, flow_pulse)
sont synchronisées par un double flip-flop.

## Stratégie de reset

- Reset asynchrone `rst_n` actif bas, dé-asserté de façon synchrone.
- Tous les registres de configuration passent à leurs valeurs par défaut
  (voir `register_map.md`).

## Sécurité (watchdog)

Le MCU hôte doit écrire périodiquement dans `WDOG_KICK` (typiquement toutes les
50 ms). Si le watchdog expire :

1. `kill_n` tombe à 0
2. Tous les `pwm_out[7:0]` sont forcés à 0
3. `spray_pwm` est forcé à 0
4. `STATUS.wdog_trip` est armé (sticky)

Le recovery nécessite une séquence explicite : écrire `CTRL.arm=1` puis `WDOG_KICK`.

## Fusion altitude (IIR)

Filtre IIR premier ordre :

```
alt_fused[n] = alpha * sonar[n] + (1 - alpha) * (baro[n] + alt_fused[n-1]) / 2
```

Simplification pratique implémentée :

```
alt_fused[n+1] = alt_fused[n] + (alpha * (measurement[n] - alt_fused[n])) >> 15
```

avec `measurement = (baro + sonar) / 2`. `alpha` est un coefficient Q1.15 configurable.

## Surface estimée

| Module | Flops | Surface approx (SKY130HD) |
|---|---|---|
| spi_peripheral | ~50 | 0.01 mm² |
| register_file | ~200 | 0.04 mm² |
| pwm_multichannel | ~150 | 0.03 mm² |
| spray_controller | ~40 | 0.01 mm² |
| altitude_fusion | ~80 | 0.05 mm² (multiplieur) |
| safety_watchdog | ~30 | 0.01 mm² |
| **Total core** | ~550 | **~0.15 mm²** |

Largement dans la zone gratuite OpenMPW (user_project_wrapper ~10 mm²).
