set T 10

read_lib /data/cad_users/1tops_1/DVD_assigment/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog synth/mult_array_netlist.v
set_top_module mult_array

create_clock -name clk -period $T [get_ports clk]
set_input_delay  1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 1.0 -clock clk [all_outputs]

report_timing -late -max_paths 1 -path_type full > sta/mult_array_timing.rpt
report_timing -late -max_paths 1

exit
