# POWER CONSUMPTION ESTIMATION WITH CADENCE INNOVUS
# it assumes that you didn't close innovus before executing modelsim

restoreDesign riscv.enc.dat riscv
reset_parasitics
extractRC
rcOut -setload riscv.setload -rc_corner my_rc
rcOut -setres riscv.setres -rc_corner my_rc
rcOut -spf riscv.spf -rc_corner my_rc
rcOut -spef riscv.spef -rc_corner my_rc
set_power_analysis_mode -reset
set_power_analysis_mode -method static -corner max -create_binary_db true -write_static_currents true -honor_negative_energy true -ignore_control_signals true
set_power_output_dir -reset
set_power_output_dir ./
set_default_switching_activity -reset
set_default_switching_activity -input_activity 0.2 -period 11.84
read_activity_file -reset
read_activity_file -format VCD -scope /tb_riscv/UUT -start {} -end {} -block {} ./riscv.vcd
set_power -reset
set_powerup_analysis -reset
set_dynamic_power_simulation -reset
report_power -rail_analysis_format VS -outfile .//riscv.rpt
report_power -outfile power_report -sort { total }
exit
