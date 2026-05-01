# SPDX-FileCopyrightText: 2024 AgriDrone Team
# SPDX-License-Identifier: Apache-2.0
# openlane/top.sdc
# Contraintes de timing personnalisées pour AgriDrone
# Cible : 50 MHz (période = 20 ns)

# 1. Définition de l'horloge système
create_clock -name clk -period 20.0 [get_ports {clk}]

# Incertitude et transition de l'horloge (modèle réaliste du réseau d'horloge de Caravel)
set_clock_uncertainty 0.5 [get_clocks {clk}]
set_clock_transition 0.5 [get_clocks {clk}]

# 2. Contraintes sur les entrées
# On réserve 5 ns pour le délai de propagation depuis les pads extérieurs jusqu'à notre wrapper
set input_delay_value 5.0
set_input_delay $input_delay_value -clock [get_clocks {clk}] [get_ports {rst_n}]
set_input_delay $input_delay_value -clock [get_clocks {clk}] [get_ports {spi_sclk spi_mosi spi_cs_n flow_pulse}]

# 3. Contraintes sur les sorties
# On réserve 5 ns pour le délai de propagation depuis notre wrapper vers les pads extérieurs
set output_delay_value 5.0
set_output_delay $output_delay_value -clock [get_clocks {clk}] [get_ports {spi_miso}]
set_output_delay $output_delay_value -clock [get_clocks {clk}] [get_ports {pwm_out[*]}]
set_output_delay $output_delay_value -clock [get_clocks {clk}] [get_ports {spray_pwm kill_n armed_led wdog_trip_led}]

# 4. Capacités de charge et transitions (Load & Transition)
# Les I/O conduisent le routage interne vers les pads Caravel.
# Une charge de 50 fF est une bonne approximation.
set_load 0.05 [all_outputs]
# Limite de transition maximale (évite les signaux trop "mous" qui consomment du courant)
set_max_transition 1.5 [current_design]
set_max_fanout 10 [current_design]
