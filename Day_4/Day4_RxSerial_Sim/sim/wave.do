onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbrxserial/SerDataIn
add wave -noupdate /tbrxserial/RxFfFull
add wave -noupdate -radix hexadecimal /tbrxserial/RxFfWrData
add wave -noupdate /tbrxserial/RxFfWrEn
add wave -noupdate /tbrxserial/u_RxSerial/rState
add wave -noupdate /tbrxserial/u_RxSerial/rSerDataIn
add wave -noupdate /tbrxserial/u_RxSerial/rBuadCnt
add wave -noupdate /tbrxserial/u_RxSerial/rBuadEnd
add wave -noupdate -radix hexadecimal /tbrxserial/u_RxSerial/rDataCnt
add wave -noupdate -radix hexadecimal /tbrxserial/u_RxSerial/rSerData
add wave -noupdate /tbrxserial/u_RxSerial/rRxFfWrEn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {99999700 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
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
WaveRestoreZoom {0 ps} {91781600 ps}
