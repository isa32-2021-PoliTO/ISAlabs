vlib work

vcom -93 -work ./work ../tb/constants_LA.vhd
vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_maker_new_LA.vhd
vcom -93 -work ./work ../tb/data_sink_inn.vhd

vlog -work ./work ../innovus/IIR_filter_LA.v
vlog -work ./work ../tb/tb_iir_LA.v

vsim -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_iir_LA/UUT=../innovus/IIR_filter_LA.sdf work.tb_iir_LA -t 10ps

vcd file ../vcd/myiir_LA_inn.vcd
vcd add /tb_iir_LA/UUT/*

add wave *
run 10 us
quit -f

