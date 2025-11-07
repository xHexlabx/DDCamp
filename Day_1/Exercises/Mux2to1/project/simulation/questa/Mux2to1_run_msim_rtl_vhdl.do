transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {/home/hextex/Documents/GitHub/DDCamp/Day_1/Exercises/Mux2to1/hdl/Mux2to1.vhd}

