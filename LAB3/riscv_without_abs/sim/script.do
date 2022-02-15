vsim -gui work.tb_riscv -t 10ps -vopt -voptargs=+acc
do {wave.do}
run 1us
