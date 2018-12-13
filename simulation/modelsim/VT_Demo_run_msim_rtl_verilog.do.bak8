transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/rtl/tgen {D:/2.6VT/VT_FPGA/rtl/tgen/tgen.v}
vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/rtl/uart {D:/2.6VT/VT_FPGA/rtl/uart/rx_module.v}
vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/rtl/uart {D:/2.6VT/VT_FPGA/rtl/uart/uart.v}
vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/rtl/uart {D:/2.6VT/VT_FPGA/rtl/uart/tx_module.v}
vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/rtl/lcd_display {D:/2.6VT/VT_FPGA/rtl/lcd_display/lcd_display.v}
vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/rtl/mux_decode {D:/2.6VT/VT_FPGA/rtl/mux_decode/mux_decode.v}
vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/rtl/switch {D:/2.6VT/VT_FPGA/rtl/switch/timer.v}
vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/rtl/switch {D:/2.6VT/VT_FPGA/rtl/switch/switch.v}
vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/rtl/switch {D:/2.6VT/VT_FPGA/rtl/switch/glf.v}
vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/rtl/clkrst {D:/2.6VT/VT_FPGA/rtl/clkrst/clkrst.v}
vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/rtl {D:/2.6VT/VT_FPGA/rtl/VT_Demo.v}
vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/rtl/megafunc {D:/2.6VT/VT_FPGA/rtl/megafunc/mypll.v}
vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/db {D:/2.6VT/VT_FPGA/db/mypll_altpll.v}

vlog -vlog01compat -work work +incdir+D:/2.6VT/VT_FPGA/simulation/modelsim {D:/2.6VT/VT_FPGA/simulation/modelsim/VT_Demo.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiii_ver -L rtl_work -L work -voptargs="+acc"  VT_Demo_vlg_tst

add wave *
view structure
view signals
run 1 ms
