set T 10

read_lib /data/cad_users/1tops_1/DVD_assigment/pdk/tcbn28hpcplusbwp30p140_180a_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp30p140_180a/tcbn28hpcplusbwp30p140tt0p9v25c.lib
read_verilog synth/mult_array_netlist.v
set_top_module mult_array

create_clock -name clk -period $T [get_ports clk]
set_input_delay  1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 1.0 -clock clk [all_outputs]

report_timing -late -max_paths 1 -path_type full > sta/mult_array_timing.rpt
report_timing -late -max_paths 1 -path_type full -from [all_registers -clock_pins] -to [all_registers -data_pins] > sta/mult_array_timing_reg2reg.rpt
report_timing -late -max_paths 1

exit
