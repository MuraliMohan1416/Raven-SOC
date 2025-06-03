

set_clock_uncertainty -setup 1.0 [get_clock *clk]

set_clock_uncertainty -hold 0.1 [get_clock *clk]

set_clock_latency -max 0.10 [get_clock *clk]

set_clock_latency -min 0.05 [get_clock *clk]

#################################################################
#################### input and output timing#####################
#################################################################

set_input_delay 0.5 -clock pll_clk {pll_clk}
set_input_delay 0.5 -clock ext_clk {ext_clk}
set_output_delay 0.5 [all_outputs]

#################################################################
#################### Design Rules ###############################
#################################################################
set_max_fanout 200 [current_design]

set_max_transition 0.5 [current_design]

set_max_capacitance 50 [current_design]

set_load -pin_load 0.2 [all_outputs]

                    