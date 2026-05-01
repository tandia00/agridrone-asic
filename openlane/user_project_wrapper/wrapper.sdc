# SPDX-FileCopyrightText: 2024 AgriDrone Team
# SPDX-License-Identifier: Apache-2.0
#
# wrapper.sdc – Timing constraints for user_project_wrapper.
# Caravel feeds wb_clk_i at up to 50 MHz (period = 20 ns).

set ::env(CLOCK_PORT) "wb_clk_i"

create_clock -name wb_clk_i -period 20.0 [get_ports {wb_clk_i}]

set_clock_uncertainty 0.5 [get_clocks {wb_clk_i}]
set_clock_transition  0.5 [get_clocks {wb_clk_i}]

# I/O delays (5 ns – Caravel pad propagation budget)
# Note: OpenSTA n'a pas remove_from_collection — on contraint tous les inputs ;
# le port d'horloge wb_clk_i est traité correctement par OpenSTA pour les checks.
set_input_delay  5.0 -clock [get_clocks {wb_clk_i}] [all_inputs]
set_output_delay 5.0 -clock [get_clocks {wb_clk_i}] [all_outputs]

# Drive / load
set_load 0.05 [all_outputs]
set_max_transition 1.5 [current_design]
set_max_fanout     10  [current_design]
