onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbtxserial/TM
add wave -noupdate /tbtxserial/RstB
add wave -noupdate /tbtxserial/Clk
add wave -noupdate /tbtxserial/TxFfEmpty
add wave -noupdate /tbtxserial/TxFfRdData
add wave -noupdate /tbtxserial/TxFfRdEn
add wave -noupdate /tbtxserial/SerDataOut
add wave -noupdate /tbtxserial/u_TxSerial/rState
add wave -noupdate /tbtxserial/u_TxSerial/rTxFfRdEn
add wave -noupdate /tbtxserial/u_TxSerial/rBuadCnt
add wave -noupdate /tbtxserial/u_TxSerial/rBuadEnd
add wave -noupdate /tbtxserial/u_TxSerial/rSerData
add wave -noupdate /tbtxserial/u_TxSerial/rDataCnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {99999700 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 188
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {101264 ns}
