# Compile Sources
vcom -work work ../*/constants.vhd
vcom -work work ../*/*.vhd
# vcom -work work ../*/*/*.vhd
vlog -work work ../tb/*.v

# Run
do script.do
