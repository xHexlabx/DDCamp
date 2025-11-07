# 1. สร้าง Clock หลัก (50MHz) ที่เข้ามาที่ Port "Clk_50"
# (คาบเวลา 20.0 ns)
create_clock -name {Clk_50} -period 20.0 [get_ports {Clk_50}]

# 2. บอก Tool ให้ไปหา Clock ที่ถูกสร้างโดย PLL
# (Tool จะหา "inst_pll" และ Clock 65MHz ที่มันสร้างขึ้นมาโดยอัตโนมัติ)
derive_pll_clocks

# 3. บอก Tool ให้คำนวณค่าความไม่แน่นอนของ Clock
derive_clock_uncertainty