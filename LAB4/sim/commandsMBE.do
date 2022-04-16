#Compiling units
vcom ../src/src_mbe_dadda/*.vhd
vlog -sv ../tb/top.sv

#Start simulation
vsim top
run 4 us