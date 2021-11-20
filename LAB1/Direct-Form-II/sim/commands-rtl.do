vlib work

vcom -93 -work ./work ../src/constants.vhd
vcom -93 -work ./work ../src/adder.vhd
vcom -93 -work ./work ../src/subtractor.vhd
vcom -93 -work ./work ../src/multiplier.vhd
vcom -93 -work ./work ../src/reg.vhd
vcom -93 -work ./work ../src/reg_bit.vhd
vcom -93 -work ./work ../src/IIR_filter.vhd

vcom -93 -work ./work ../tb/constants.vhd
vcom -93 -work ./work ../tb/clk_gen.vhd
vcom -93 -work ./work ../tb/data_maker_new.vhd
vcom -93 -work ./work ../tb/data_sink.vhd
vlog -work ./work ../tb/tb_iir.v

vsim work.tb_iir -t 10ps

add wave *
run 10 us
quit -f

