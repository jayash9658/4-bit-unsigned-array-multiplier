# 4-Bit Array Multiplier from RTL to GDSII
 
Team: Jayakanth M V (2025122004), Tushar Gupta (2025122001)
 
A 4-bit by 4-bit unsigned array multiplier (8-bit product) designed in Verilog and taken through RTL simulation, synthesis, static timing analysis and place and route on the SkyWater SKY130 (130 nm) `sky130_fd_sc_hd` library, typical corner `tt_025C_1v80`.
 
The assignment describes an open-source flow (Yosys, OpenSTA, LibreLane). We used the Cadence flow instead:
 
| Stage | Tool |
|---|---|
| RTL and gate-level simulation | Cadence Xcelium |
| Logic synthesis | Cadence Genus |
| Static timing analysis | Cadence Tempus |
| Place and route | Cadence Innovus |
 
Because Innovus does not write `config.json` or `metrics.json`, the Innovus Tcl scripts replace `config.json` and the Innovus reports replace `metrics.json`.
 
## Design
 
- `a` and `b` are registered on every rising clock edge, the array is built from the registered values, and the result is registered into `p`.
- 16 AND gates and 12 full adders in the array, 16 flip-flops (4 + 4 + 8) with asynchronous active-low reset `rst_n`.
- Latency is 2 clock cycles and throughput is one result per cycle.
Ports: `clk`, `rst_n`, `a[3:0]`, `b[3:0]`, `p[7:0]`.
 
## Repository layout
 
```
rtl/      full_adder.v, mult_array.v
tb/       tb_mult.v
synth/    synth.tcl, mult_array_netlist.v, mult_array_stat.rpt, mult_array_out.sdc
sta/      sta.tcl, mult_array_timing.rpt
pnr/      pnr.tcl, mmmc.tcl, mult_array_out.sdc, sky130.map, sky130_fd_sc_hd.tlef,
          mult_array.gds, summary.rpt, area.rpt, power.rpt, drc.rpt, connectivity.rpt,
          timing_setup/, timing_hold/, layout screenshots
report/   report.pdf
```
 
The SKY130 library files (`.lib`, LEF, GDS) are not stored in the repository.
 
## How to run
 
Load the Cadence environment first, then run each step from the project root.
 
```
source /home/cadence/cshrc
```
 
Part A, RTL simulation:
 
```
xrun -sv -timescale 1ns/1ps rtl/full_adder.v rtl/mult_array.v tb/tb_mult.v -access +r
```
 
Part B, synthesis and netlist simulation:
 
```
genus -f synth/synth.tcl
xrun -sv -timescale 1ns/1ps tb/tb_mult.v synth/mult_array_netlist.v synth/sky130_cells_min.v -access +r
```
 
Part C, static timing analysis (the clock period is the variable `T` at the top of `sta/sta.tcl`):
 
```
tempus -no_gui -init sta/sta.tcl
```
 
Part D, place and route:
 
```
/home/cadence/INNOVUS211/bin/innovus -init pnr/pnr.tcl
```
 
## Results
 
### Part A: verification
 
```
PASS: 256 vectors checked, 0 errors
```
 
Changing `sum` in `full_adder.v` to `a ^ b` makes the testbench print a `FAIL` line, and restoring it gives `PASS` again. Hand-worked example: A = 6 (last digit of roll number 2025122001, plus 5), B = 7, P = 42.
 
### Part B: synthesis
 
| Metric | Value |
|---|---|
| Total number of cells | 62 |
| Number of flip-flops | 16 |
| Total cell area | 711.933 µm² |
| Flip-flop area | 400.384 µm² (56.2 %) |
| Most-used cells | `dfrtp_1` (16), `nand2_1` (14), `o2bb2ai_1` (8) |
| Netlist simulation | `PASS: 256 vectors checked, 0 errors` |
 
### Part C: static timing analysis
 
| Metric | Value |
|---|---|
| Worst slack at T = 10 ns | 7.116 ns |
| Tmin | 2.884 ns |
| Fmax | 346.7 MHz |
| Slack at T = 2.88 ns | -0.004 ns |
| Critical path | `b_r_reg[1]/CLK` to `p_reg[6]/D` |
| Cells on the critical path | 11 (9 combinational + 2 flip-flops) |
| Latency (2 x Tmin) | 5.768 ns |
| Throughput | 346.7 million results per second |
 
### Part D: place and route
 
CLOCK_PERIOD = 1.2 x Tmin = 3.46 ns, rounded up to the next 0.5 ns, gives 3.5 ns. The die is fixed at 150 x 150 µm.
 
| Metric | Value |
|---|---|
| CLOCK_PERIOD used | 3.5 ns |
| Number of runs needed | 1 |
| Core area | 19318.215 µm² |
| Cells after synthesis | 62 |
| Cells after place and route | 2696 |
| Kinds of cells added | 306 tap cells, 2328 filler cells (`fill_1` 329, `fill_2` 281, `fill_4` 27, `fill_8` 1691); no buffers or decap cells |
| Wirelength | 1922.68 µm |
| Setup slack | 0.676 ns |
| Hold slack | 0.566 ns |
| Post-route Fmax | 354.1 MHz (Part C: 346.7 MHz) |
| Total power | 0.298 mW |
| DRC errors | 0 |
| LVS | not run in Innovus (it has no LVS); the connectivity check reports no opens or shorts on signal nets |
 
Where the numbers come from: `summary.rpt` (cells, area, wirelength), `timing_setup/mult_array_postRoute.summary` (setup slack), `timing_hold/mult_array_postRoute_hold.summary` (hold slack), `drc.rpt` (DRC), `power.rpt` (power).
 
### Run attempts
 
| Attempt | CLOCK_PERIOD | Setup slack | Hold slack | DRC errors | Result |
|---|---|---|---|---|---|
| 1 | 3.5 ns | 0.676 ns | 0.566 ns | 0 | Accepted |
 
Timing was met on the first attempt, so the period was not increased. The flow was also run a few times while setting up the scripts (technology LEF, clock waveform in the SDC file, pin placement). None of those runs failed because of timing, so they are not counted as attempts.
 
## Notes on the Innovus flow
 
- Innovus needs the technology LEF and the cell LEF. The PDK tech LEF is copied to `pnr/sky130_fd_sc_hd.tlef` with one dummy cut layer (`licon1`) added so that Innovus 21.1 can read it.
- `streamOut` merges the standard-cell layouts from the PDK GDS into `pnr/mult_array.gds`, using the layer map in `pnr/sky130.map`.
- The well-bias pins VPB and VNB of the cells are not routed as signals. The tap cells tie the wells to the supply.
- The connectivity report lists 9 dangling `met4` wire ends, which are the ends of the power stripes.
## Report
 
The full report with all tables, screenshots and answers to the six questions is in `report/report.pdf`.
 
