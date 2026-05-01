# AgriDrone Co-Processor ASIC

ASIC compagnon pour drone agricole de pulvérisation, destiné à être soumis à
[Efabless OpenMPW](https://efabless.com/open_shuttle_program) sur PDK **SKY130**.

Cette puce ne remplace PAS le MCU principal (STM32/RPi) — elle lui offre des
fonctions temps-réel déterministes et une couche de sécurité matérielle.

## Rôle dans le système drone

```
     ┌──────────────────────────────────┐
     │   MCU hôte (STM32H7 / RPi)       │
     │   - Navigation GPS               │
     │   - Traitement image (NDVI)      │
     │   - Communication radio          │
     └──────────┬───────────────────────┘
                │ SPI (MCU = master)
                ▼
     ┌──────────────────────────────────┐
     │   AgriDrone Co-Processor ASIC    │
     │  ┌────────────────────────────┐  │
     │  │ 8× PWM (moteurs ESC)       │──┼──► Moteurs
     │  │ Spray Controller (PWM+ADC) │──┼──► Valve + flow
     │  │ Altitude Fusion (IIR)      │  │
     │  │ Safety Watchdog            │──┼──► Kill-switch
     │  │ SPI Peripheral + Register File│  │
     │  └────────────────────────────┘  │
     └──────────────────────────────────┘
```

## Blocs fonctionnels

| Module | Fichier RTL | Rôle |
|---|---|---|
| `pwm_multichannel` | `rtl/pwm_multichannel.v` | 8 canaux PWM 16-bit, période commune, jitter < 1 cycle |
| `spray_controller` | `rtl/spray_controller.v` | PWM valve + compteur débitmètre |
| `altitude_fusion` | `rtl/altitude_fusion.v` | Filtre IIR fusionnant baromètre + sonar |
| `safety_watchdog` | `rtl/safety_watchdog.v` | Coupe PWM si pas de heartbeat SPI |
| `spi_peripheral` | `rtl/spi_peripheral.v` | SPI mode 0, registres 16-bit |
| `top` | `rtl/top.v` | Intégration + mapping I/O |

Voir `docs/register_map.md` pour la carte des registres et `docs/pinout.md` pour le brochage.

## Structure du dépôt (Efabless chipIgnite)

```
agridrone-asic/
├── verilog/
│   ├── rtl/              ← Sources RTL (user_project_wrapper + sous-modules)
│   ├── gl/               ← Netlist gate-level (sortie OpenLane)
│   └── dv/               ← Testbenches DV (Efabless)
├── gds/                  ← Layout GDS (sortie OpenLane) – Git LFS
├── def/                  ← DEF post-route
├── lef/                  ← Vue abstraite LEF
├── maglef/               ← Magic LEF
├── spi/lvs/              ← SPICE pour LVS
├── sdf/{nom,min,max}/    ← Standard Delay Format (3 coins)
├── spef/{nom,min,max}/   ← Parasitiques SPEF (3 coins)
├── tb/                   ← Testbenches RTL
├── sim/                  ← Scripts simulation et setup
├── openlane/             ← Config OpenLane + SDC
├── docs/                 ← Caravel mapping, signoff, register map
├── info.yaml             ← Manifeste Efabless
├── dependencies.json     ← Versions PDK/Caravel/OpenLane
├── Makefile              ← Cibles : sim-all, openlane, finalize, precheck
└── .github/workflows/    ← CI : lint, simulation, precheck Docker
```

## Simulation

```bash
make sim-all          # lint + tb_top + tb_pwm + tb_safety_watchdog
make sim-gls          # gate-level simulation avec SDF
```

Nécessite `iverilog`. Voir `sim/run_tb.sh` et `sim/run_gls.sh`.

## Synthèse / Layout (OpenLane)

```bash
make openlane         # lance openlane/run_openlane.sh via Docker
```

Configuration dans `openlane/config.json` + `openlane/top.sdc`.  
Cible : **50 MHz** sur SKY130HD — WNS = 0 ns (run `pipelined4`).

## Finalisation soumission

```bash
make finalize         # copie artefacts OpenLane → gds/ def/ lef/ …
make precheck         # mpw-precheck Efabless via Docker
```

## Signoff (résultats obtenus)

| Vérification | Résultat |
|---|---|
| DRC (Magic) | **0 erreur** |
| LVS (Netgen) | **0 erreur** |
| Antenna | **0 violation** |
| STA WNS (slow-slow) | **0.00 ns** (50 MHz OK) |
| IR Drop max | < 50 mV |

Rapport complet : `docs/signoff_review.md`

## Spécifications cibles

- **Techno** : SKY130 (130 nm)
- **Fréquence** : 50 MHz
- **Tension** : 1.8 V core / 3.3 V I/O
- **Surface estimée** : < 2 mm² (zone gratuite OpenMPW)
- **Pins** : 19 signaux → 38 GPIO Caravel (voir `docs/caravel_mapping.md`)

## Licence

Apache 2.0 — requis pour chipIgnite / OpenMPW.
