transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/rtl/tgen {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/rtl/tgen/tgen.v}
vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/rtl/uart {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/rtl/uart/rx_module.v}
vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/rtl/uart {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/rtl/uart/uart.v}
vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/rtl/uart {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/rtl/uart/tx_module.v}
vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/rtl/lcd_display {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/rtl/lcd_display/lcd_display.v}
vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/rtl/mux_decode {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/rtl/mux_decode/mux_decode.v}
vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/rtl/switch {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/rtl/switch/timer.v}
vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/rtl/switch {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/rtl/switch/switch.v}
vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/rtl/switch {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/rtl/switch/glf.v}
vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/rtl/clkrst {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/rtl/clkrst/clkrst.v}
vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/rtl {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/rtl/VT_Demo.v}
vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/rtl/megafunc {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/rtl/megafunc/mypll.v}
vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/db {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/db/mypll_altpll.v}

vlog -vlog01compat -work work +incdir+D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG\ 2.4/simulation/modelsim {D:/Mission/VT/2019-DOE/COG2.4-TE063XVXS01-00-pengshuai/TE063XVXS01-00-VT-COG 2.4/simulation/modelsim/VT_Demo.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneiii_ver -L rtl_work -L work -voptargs="+acc"  VT_Demo_vlg_tst

add wave *
view structure
view signals
run 1 ms
