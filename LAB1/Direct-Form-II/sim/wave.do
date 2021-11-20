onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group IIR_filter /tb_iir/UUT/CLK
add wave -noupdate -expand -group IIR_filter /tb_iir/UUT/RST_n
add wave -noupdate -expand -group IIR_filter /tb_iir/UUT/VIN
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/DIN
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/A_1
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/B_0
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/B_1
add wave -noupdate -expand -group IIR_filter /tb_iir/UUT/VOUT
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/DOUT
add wave -noupdate -expand -group IIR_filter /tb_iir/UUT/VALID
add wave -noupdate -expand -group IIR_filter /tb_iir/UUT/RSTN
add wave -noupdate -expand -group IIR_filter /tb_iir/UUT/ENIN
add wave -noupdate -expand -group IIR_filter /tb_iir/UUT/ENOUT
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/DIN_EX
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/PIN
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/POUT
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/DOUT_EX
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/B_0_EX
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/B_1_EX
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/A_1_EX
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/P1
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/P2
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/P3
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/P4
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/P5
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/P5shifted
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/P3shifted
add wave -noupdate -expand -group IIR_filter -radix decimal /tb_iir/UUT/P4shifted
add wave -noupdate -expand -group {Control Unit} /tb_iir/UUT/CU_U/state
add wave -noupdate -expand -group {Data Maker} /tb_iir/SM/tco
add wave -noupdate /tb_iir/SM/line__38/x
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3715500 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 302
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits fs
update
WaveRestoreZoom {0 fs} {15282 ps}
