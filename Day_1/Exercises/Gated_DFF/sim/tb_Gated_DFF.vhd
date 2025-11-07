
library IEEE;
use IEEE.std_logic_1164.ALL;

-- 1. ENTITY: Testbench ไม่มี Port
ENTITY tb_Gated_DFF IS
END ENTITY tb_Gated_DFF;

-- 2. ARCHITECTURE
ARCHITECTURE test OF tb_Gated_DFF IS
    
    -- 2.1 ประกาศ Component ที่เราจะเทส (UUT = Unit Under Test)
    -- (คัดลอก ENTITY ของ Gated_DFF มาวาง แล้วเปลี่ยน ENTITY เป็น COMPONENT)
    COMPONENT Gated_DFF
        PORT (
            Clk    : IN  STD_LOGIC;
            RstB   : IN  STD_LOGIC;
            Ena    : IN  STD_LOGIC;
            D_in   : IN  STD_LOGIC;
            Q_out  : OUT STD_LOGIC
        );
    END COMPONENT;

    -- 2.2 สร้าง "สายไฟ" ภายใน Testbench เพื่อป้อนให้ UUT
    SIGNAL s_Clk    : STD_LOGIC := '0';
    SIGNAL s_RstB   : STD_LOGIC;
    SIGNAL s_Ena    : STD_LOGIC;
    SIGNAL s_D_in   : STD_LOGIC;
    SIGNAL s_Q_out  : STD_LOGIC; -- สายไฟที่รับค่า Q_out ออกมาดู

    -- 2.3 ค่าคงที่สำหรับสร้าง Clock
    CONSTANT CLK_PERIOD : TIME := 20 ns; -- 50 MHz (เหมือนในสไลด์)

BEGIN

    -- 3. "วาง" วงจร (UUT) ลงใน Testbench
    uut : Gated_DFF
        PORT MAP (
            Clk    => s_Clk,
            RstB   => s_RstB,
            Ena    => s_Ena,
            D_in   => s_D_in,
            Q_out  => s_Q_out
        );

    -- 4. PROCESS สร้าง Clock (ทำงานตลอดไป)
    clk_process : PROCESS
    BEGIN
        s_Clk <= '0';
        WAIT FOR CLK_PERIOD / 2;
        s_Clk <= '1';
        WAIT FOR CLK_PERIOD / 2;
    END PROCESS;

    -- 5. PROCESS สร้าง "บททดสอบ" (Stimulus)
    stim_process : PROCESS
    BEGIN
        -- เริ่มต้น: ทำการ Reset
        WAIT FOR 10 ns;
        s_RstB <= '0';  -- กด Reset
        s_Ena  <= '0';
        s_D_in <= '1';  -- ป้อน '1' แต่ไม่ควรเข้า
        WAIT FOR 40 ns; -- รอ 2 สัญญาณนาฬิกา
        
        s_RstB <= '1';  -- ปล่อย Reset (Q_out ควรเป็น '0')
        WAIT FOR 20 ns;
        
        -- Test 1: Ena = '0' (Hold)
        -- Q_out ควรจะค้างที่ '0'
        s_Ena  <= '0';
        s_D_in <= '1';
        WAIT FOR 40 ns;
        
        -- Test 2: Ena = '1' (Load '1')
        -- Q_out ควรจะเปลี่ยนเป็น '1'
        s_Ena  <= '1';
        s_D_in <= '1';
        WAIT FOR 40 ns;
        
        -- Test 3: Ena = '1' (Load '0')
        -- Q_out ควรจะเปลี่ยนเป็น '0'
        s_Ena  <= '1';
        s_D_in <= '0';
        WAIT FOR 40 ns;

        -- Test 4: Ena = '0' (Hold '0')
        -- Q_out ควรจะค้างที่ '0'
        s_Ena  <= '0';
        s_D_in <= '1';
        WAIT FOR 40 ns;

        -- จบการทดสอบ
        WAIT;
        
    END PROCESS;

END ARCHITECTURE test;