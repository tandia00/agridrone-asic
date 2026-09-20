create_clock -name clk -period 20.0 [get_ports {wb_clk_i}]

set_clock_uncertainty 0.5 [get_clocks {clk}]
set_clock_transition 0.5 [get_clocks {clk}]

set input_delay_value 5.0
set_input_delay $input_delay_value -clock [get_clocks {clk}] [get_ports {wb_rst_i}]
set_input_delay $input_delay_value -clock [get_clocks {clk}] [get_ports {io_in[*]}]

set output_delay_value 5.0
set_output_delay $output_delay_value -clock [get_clocks {clk}] [get_ports {io_out[*]}]
set_output_delay $output_delay_value -clock [get_clocks {clk}] [get_ports {io_oeb[*]}]

set_load 0.05 [all_outputs]
set_max_transition 1.5 [current_design]
set_max_fanout 10 [current_design]
