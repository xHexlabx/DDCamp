library IEEE;
use IEEE.std_logic_1164.ALL;
-- (Testbench ไม่จำเป็นต้องใช้ unsigned แต่ถ้าคุณอยากเช็คค่า ก็ใส่ได้)

-- 1. ENTITY: Testbench ไม่มี Port
ENTITY tb_DownCounter4bit IS
END ENTITY tb_DownCounter4bit;

-- 2. ARCHITECTURE
ARCHITECTURE test OF tb_DownCounter4bit IS
    
    -- 2.1 ประกาศ Component ที่เราจะเทส
    COMPONENT DownCounter4bit
        PORT (
            Clk        : IN  STD_LOGIC;
            RstB       : IN  STD_LOGIC;
            Ena        : IN  STD_LOGIC;
            Count_out  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    -- 2.2 สร้าง "สายไฟ" ภายใน Testbench
    SIGNAL s_Clk       : STD_LOGIC := '0';
    SIGNAL s_RstB      : STD_LOGIC;
    SIGNAL s_Ena       : STD_LOGIC;
    SIGNAL s_Count_out : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- 2.3 ค่าคงที่สำหรับสร้าง Clock (50 MHz)
    CONSTANT CLK_PERIOD : TIME := 20 ns;

BEGIN

    -- 3. "วาง" วงจร (UUT) ลงใน Testbench
    uut : DownCounter4bit
        PORT MAP (
            Clk        => s_Clk,
            RstB       => s_RstB,
            Ena        => s_Ena,
            Count_out  => s_Count_out
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
        s_RstB <= '0';  -- กด Reset
        s_Ena  <= '0';
        WAIT FOR 40 ns; -- รอ 2 สัญญาณนาฬิกา
        
        s_RstB <= '1';  -- ปล่อย Reset (Count_out ควรเป็น "1111")
        WAIT FOR 20 ns;
        
        -- Test 1: Ena = '0' (Hold)
        -- Count_out ควรจะค้างที่ "1111"
        s_Ena  <= '0';
        WAIT FOR 60 ns; -- รอ 3-4 cycles
        
        -- Test 2: Ena = '1' (Count)
        -- Count_out ควรจะนับลง: "1110", "1101", "1100", ...
        s_Ena  <= '1';
        WAIT FOR 100 ns; -- รอ 5 cycles
        
        -- Test 3: Ena = '0' (Hold again)
        -- Count_out ควรจะ "หยุดนับ" ค้างไว้
        s_Ena  <= '0';
        WAIT FOR 60 ns;

        -- Test 4: Ena = '1' (Count again)
        -- นับต่อจนวนลูป (Wrap around)
        s_Ena  <= '1';
        WAIT FOR 400 ns; -- รออีกซัก 20 cycles
        
        -- Test 5: Reset อีกครั้ง
        s_RstB <= '0';
        s_Ena  <= '0';
        WAIT FOR 40 ns;
        s_RstB <= '1';

        -- จบการทดสอบ
        WAIT;
        
    END PROCESS;

END ARCHITECTURE test;