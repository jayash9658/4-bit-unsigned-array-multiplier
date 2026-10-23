set_db init_lib_search_path /data/cad_users/1tops_1/DVD_assigment/pdk/tcbn28hpcplusbwp30p140_180a_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp30p140_180a
set_db library tcbn28hpcplusbwp30p140tt0p9v25c.lib

read_hdl -sv {rtl/full_adder.v rtl/mult_array.v}
elaborate mult_array

create_clock -name clk -period 10 [get_ports clk]
set_input_delay  1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 1.0 -clock clk [all_outputs]

ungroup -all -flatten

syn_generic
syn_map
syn_opt

report_area   > synth/mult_array_stat.rpt
report_gates >> synth/mult_array_stat.rpt
report_timing > synth/mult_array_timing_synth.rpt

write_hdl > synth/mult_array_netlist.v
write_sdc > synth/mult_array_out.sdc
exit
