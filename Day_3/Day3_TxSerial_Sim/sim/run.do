##
quit -sim
vlib work

#--------------------------------#
#--      Compile Source        --#
#--------------------------------#
vcom -work work ../source/TxSerial.vhd

#--------------------------------#
#--     Compile Test Bench     --#
#--------------------------------#
vcom -work work ../Testbench/TbTxSerial.vhd

vsim -t 100ps -novopt work.TbTxSerial
view wave

do wave.do

view structure
view signals

run 100 us	

