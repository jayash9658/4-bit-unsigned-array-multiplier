# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.14-s082_1 on Sat Oct 24 16:04:18 IST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design mult_array

create_clock -name "clk" -period 3.5 -waveform {0.0 1.75} [get_ports clk]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports rst_n]
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {a[3]}]
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {a[2]}]
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {a[1]}]
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {a[0]}]
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {b[3]}]
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {b[2]}]
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {b[1]}]
set_input_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {b[0]}]
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {p[7]}]
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {p[6]}]
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {p[5]}]
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {p[4]}]
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {p[3]}]
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {p[2]}]
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {p[1]}]
set_output_delay -clock [get_clocks clk] -add_delay 1.0 [get_ports {p[0]}]
set_wire_load_mode "top"
