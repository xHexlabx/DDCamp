# 1. สร้าง library ชื่อ 'work'
vlib work

# 2. Compile ดีไซน์ของเรา (Mux2to1.vhd)
vcom -work work ../hdl/Mux2to1.vhd

# 3. Compile testbench ของเรา
vcom -work work tb_Mux2to1.vhd

# 4. เริ่ม Simulator โดยเล็งไปที่ testbench
vsim -t 1ps -L work work.tb_Mux2to1

# 5. เพิ่มสัญญาณ "ทั้งหมด" ใน testbench เข้าหน้าต่าง Wave
add wave -r /*

# 6. สั่งให้รัน simulation จนจบ
run -all