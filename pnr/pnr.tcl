set BASE /data/cad_users/1tops_1/DVD_assigment
set SKY  $BASE/sky130hd

set init_lef_file [list $BASE/pnr/sky130_fd_sc_hd.tlef $SKY/lef/sky130_fd_sc_hd_merged.lef]
set init_verilog  $BASE/synth/mult_array_netlist.v
set init_top_cell mult_array
set init_pwr_net  VPWR
set init_gnd_net  VGND
set init_mmmc_file $BASE/pnr/mmmc.tcl
init_design

globalNetConnect VPWR -type pgpin -pin VPWR -inst * -verbose
globalNetConnect VGND -type pgpin -pin VGND -inst * -verbose

setDontUse sky130_fd_sc_hd__probe_p_8 true
setDontUse sky130_fd_sc_hd__probec_p_8 true
setDontUse sky130_fd_sc_hd__lpflow_* true

floorPlan -site unithd -d 150 150 5.52 5.44 5.52 5.44

editPin -pin {clk rst_n a[0] a[1] a[2] a[3] b[0] b[1] b[2] b[3]} -side LEFT -layer 4 -spreadType CENTER -spacing 6 -unit MICRON -fixOverlap 1 -fixedPin 1
editPin -pin {p[0] p[1] p[2] p[3] p[4] p[5] p[6] p[7]} -side RIGHT -layer 4 -spreadType CENTER -spacing 6 -unit MICRON -fixOverlap 1 -fixedPin 1

addWellTap -cell sky130_fd_sc_hd__tapvpwrvgnd_1 -cellInterval 28 -prefix TAP

addRing -nets {VPWR VGND} -type core_rings -follow core \
    -layer {top met5 bottom met5 left met4 right met4} \
    -width 1.6 -spacing 1.6 -offset 0.4

sroute -nets {VPWR VGND} -connect corePin -corePinTarget firstAfterRowEnd

setAddStripeMode -stacked_via_bottom_layer met1 -stacked_via_top_layer met4
addStripe -nets {VPWR VGND} -layer met4 -direction vertical \
    -width 1.6 -spacing 1.6 -set_to_set_distance 30 -start_from left -start_offset 15

place_design

setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS

set_ccopt_property buffer_cells   {sky130_fd_sc_hd__clkbuf_2 sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8}
set_ccopt_property inverter_cells {sky130_fd_sc_hd__clkinv_2 sky130_fd_sc_hd__clkinv_4 sky130_fd_sc_hd__clkinv_8}
create_ccopt_clock_tree_spec
ccopt_design

optDesign -postCTS
optDesign -postCTS -hold

setNanoRouteMode -routeBottomRoutingLayer 2 -routeTopRoutingLayer 6
routeDesign

setExtractRCMode -engine postRoute -effortLevel low
setAnalysisMode -analysisType onChipVariation -cppr both

addFiller -cell {sky130_fd_sc_hd__fill_8 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_1}

timeDesign -postRoute -outDir $BASE/pnr/timing_setup
timeDesign -postRoute -hold -outDir $BASE/pnr/timing_hold

verify_drc -report $BASE/pnr/drc.rpt
verifyConnectivity -type all -report $BASE/pnr/connectivity.rpt

report_area  -out_file $BASE/pnr/area.rpt
report_power -outfile  $BASE/pnr/power.rpt
summaryReport -noHtml -outfile $BASE/pnr/summary.rpt

saveDesign $BASE/pnr/mult_array.enc

streamOut $BASE/pnr/mult_array.gds -mapFile $BASE/pnr/sky130.map -libName mult_array \
    -merge $SKY/gds/sky130_fd_sc_hd.gds -units 1000 -mode ALL
