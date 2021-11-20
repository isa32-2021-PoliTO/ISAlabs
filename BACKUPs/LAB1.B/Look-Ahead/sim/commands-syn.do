vlib work

vcom -93 -work ./work ../src/constants_LA.vhd
vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_maker_new_LA.vhd
vcom -93 -work ./work ../tb/data_sink_syn.vhd

vlog -work ./work ../netlist/IIR_filter_LA.v
vlog -work ./work ../tb/tb_iir_LA.v

vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_iir_LA/UUT=../netlist/IIR_filter_LA.sdf work.tb_iir_LA -t 10ps
#vsim -t 10ps -L /software/dk/nangate45/verilog/msim6.2g work.tb_iir_LA

vcd file ../vcd/myiir_LA_syn.vcd
vcd add /tb_iir_LA/UUT/*

add wave *
run 10 us
quit -f

