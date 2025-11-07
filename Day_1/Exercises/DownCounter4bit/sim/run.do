# 1. สร้าง library ชื่อ 'work'
vlib work

# 2. Compile ดีไซน์ของเรา (DownCounter4bit.vhd)
# (ต้องมั่นใจว่า path ../hdl/ ถูกต้อง)
vcom -work work ../hdl/DownCounter4bit.vhd

# 3. Compile testbench ของเรา
vcom -work work tb_DownCounter4bit.vhd

# 4. เริ่ม Simulator โดยเล็งไปที่ testbench
# (work.tb_DownCounter4bit คือ library.entity)
vsim -t 1ps -L work work.tb_DownCounter4bit

# 5. เพิ่มสัญญาณ "ทั้งหมด" ใน testbench เข้าหน้าต่าง Wave
add wave -r /*

# 6. สั่งให้รัน simulation จนจบ
run -all