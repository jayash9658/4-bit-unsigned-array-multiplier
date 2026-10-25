create_library_set -name lib_tt -timing {/data/cad_users/1tops_1/DVD_assigment/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib}
create_constraint_mode -name func -sdc_files {/data/cad_users/1tops_1/DVD_assigment/pnr/mult_array_out.sdc}

create_delay_corner -name tt_corner -library_set lib_tt
create_analysis_view -name tt_view -delay_corner tt_corner -constraint_mode func

set_analysis_view -setup {tt_view} -hold {tt_view}