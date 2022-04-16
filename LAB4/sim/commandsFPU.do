#Compiling units
vcom ../src/src_mbe_dadda/*.vhd
vcom ../src/src_mbe_dadda/fpmul/*.vhd
vcom ../src/common/*.vhd
vcom ../src/src/fpmul_stage1_struct.vhd
vcom ../src/src/fpmul_stage3_struct.vhd
vcom ../src/src/fpmul_stage4_struct.vhd
vcom ../src/src_input_reg/fpmul_pipeline.vhd

vlog -sv ../tb/top.sv

#Start simulation
vsim top
run 8 us