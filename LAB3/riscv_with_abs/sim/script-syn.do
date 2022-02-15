vsim -gui -L /software/dk/nangate45/verilog/msim6.2g -sdftyp /tb_riscv/UUT=../netlist/riscv.sdf work.tb_riscv -t 10ps -vopt -voptargs=+acc

vcd file ../vcd/riscv.vcd
vcd add /tb_riscv/UUT/*

do {wave.do}
run 1us
