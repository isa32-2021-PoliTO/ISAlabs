vlib work

vcom -93 -work ./work ../src/constants_LA.vhd
vcom -93 -work ./work ../src/adder.vhd
vcom -93 -work ./work ../src/multiplier.vhd
vcom -93 -work ./work ../src/reg.vhd
vcom -93 -work ./work ../src/reg_bit.vhd
vcom -93 -work ./work ../src/subEXT.vhd
vcom -93 -work ./work ../src/IIR_filter_LA.vhd

vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_maker_new_LA.vhd
vcom -93 -work ./work ../tb/data_sink.vhd
vlog -work ./work ../tb/tb_iir_LA.v

vsim work.tb_iir_LA -t 10ps

add wave *
run 10 us
quit -f

