library IEEE;
use IEEE.std_logic_1164.ALL;

-- 1. ENTITY: Testbench ไม่มี Port
ENTITY tb_Mux2to1 IS
END ENTITY tb_Mux2to1;

-- 2. ARCHITECTURE
ARCHITECTURE test OF tb_Mux2to1 IS
    
    -- 2.1 ประกาศ Component ที่เราจะเทส
    COMPONENT Mux2to1
        PORT (
            A   : IN  STD_LOGIC;
            B   : IN  STD_LOGIC;
            SEL : IN  STD_LOGIC;
            Y   : OUT STD_LOGIC
        );
    END COMPONENT;

    -- 2.2 สร้าง "สายไฟ" ภายใน Testbench
    SIGNAL s_A   : STD_LOGIC;
    SIGNAL s_B   : STD_LOGIC;
    SIGNAL s_SEL : STD_LOGIC;
    SIGNAL s_Y   : STD_LOGIC; -- สายไฟที่รับค่า Y ออกมาดู

BEGIN

    -- 3. "วาง" วงจร (UUT) ลงใน Testbench
    uut : Mux2to1
        PORT MAP (
            A   => s_A,
            B   => s_B,
            SEL => s_SEL,
            Y   => s_Y
        );

    -- 4. PROCESS สร้าง "บททดสอบ" (Stimulus)
    stim_process : PROCESS
    BEGIN
        -- Test 1: เลือก A (A=1, B=0)
        -- Y ควรจะเป็น 1
        s_A <= '1';
        s_B <= '0';
        s_SEL <= '0';
        WAIT FOR 100 ns; -- รอ 100 ns เพื่อให้เราเห็น Waveform

        -- Test 2: เปลี่ยนไปเลือก B (A=1, B=0)
        -- Y ควรจะเปลี่ยนเป็น 0 ทันที
        s_SEL <= '1';
        WAIT FOR 100 ns;

        -- Test 3: เปลี่ยนค่า B (A=1, B=1)
        -- Y ควรจะเปลี่ยนเป็น 1 ทันที (เพราะยังเลือก B อยู่)
        s_B <= '1';
        WAIT FOR 100 ns;

        -- Test 4: เปลี่ยนค่า A (A=0, B=1)
        -- Y ควรจะ "ไม่เปลี่ยน" (ยังเป็น 1) เพราะเรายังเลือก B อยู่
        s_A <= '0';
        WAIT FOR 100 ns;

        -- Test 5: เปลี่ยนกลับไปเลือก A (A=0, B=1)
        -- Y ควรจะเปลี่ยนเป็น 0
        s_SEL <= '0';
        WAIT FOR 100 ns;

        -- จบการทดสอบ
        WAIT;
        
    END PROCESS;

END ARCHITECTURE test;