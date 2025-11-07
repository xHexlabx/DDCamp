##
quit -sim
vlib work

#--------------------------------#
#--      Compile Source        --#
#--------------------------------#
vcom -work work ../source/RxSerial.vhd

#--------------------------------#
#--     Compile Test Bench     --#
#--------------------------------#
vcom -work work ../Testbench/TbRxSerial.vhd

vsim -t 100ps -novopt work.TbRxSerial
view wave

do wave.do

view structure
view signals

run 500 us	

