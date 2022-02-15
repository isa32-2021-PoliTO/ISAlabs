vsim -gui work.alu

add wave *
force -freeze sim:/alu/DATA2 32'd0 0
force -freeze sim:/alu/DATA1 -32'd3 0
force -freeze sim:/alu/FUNC FUNCABS 0

run 1ns
