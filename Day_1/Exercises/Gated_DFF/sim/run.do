# 1. สร้าง library ชื่อ 'work' (ถ้ายังไม่มี)
vlib work

# 2. Compile ดีไซน์ของเรา (Gated_DFF.vhd)
# (แก้ path ../hdl/ ให้ถูกต้องตามโครงสร้างโฟลเดอร์ของคุณ)
vcom -work work ../hdl/Gated_DFF.vhd

# 3. Compile testbench ของเรา
vcom -work work tb_Gated_DFF.vhd

# 4. เริ่ม Simulator โดยเล็งไปที่ testbench ของเรา
# (work.tb_Gated_DFF คือ library.entity)
vsim -t 1ps -L work work.tb_Gated_DFF

# 5. (สำคัญ) เพิ่มสัญญาณ "ทั้งหมด" ใน testbench เข้าหน้าต่าง Wave
add wave -r /*

# 6. สั่งให้รัน simulation จนจบ (ตามที่ testbench เขียนไว้)
run -all
