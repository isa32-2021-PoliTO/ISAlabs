vlib work

vcom -93 -work ./work ../tb/constants.vhd
vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_maker_new.vhd
vcom -93 -work ./work ../tb/data_sink_syn.vhd

vlog -work ./work ../netlist/IIR_filter.v
vlog -work ./work ../tb/tb_iir.v

vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_iir/UUT=../netlist/IIR_filter.sdf work.tb_iir -t 10ps

vcd file ../vcd/myiir_syn.vcd
vcd add /tb_iir/UUT/*

add wave *
run 10 us
quit -f

