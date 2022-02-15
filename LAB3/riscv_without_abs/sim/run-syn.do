# Compile Sources
# vcom -work work ../*/constants.vhd
vcom -work work ../tb/*.vhd
# vcom -work work ../*/*/*.vhd
vlog -work work ../netlist/*.v

# Run
do script-syn.do
