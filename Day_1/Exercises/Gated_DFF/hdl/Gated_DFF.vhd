library IEEE;
use IEEE.std_logic_1164.ALL;

-- 1. ENTITY: ประกาศหน้าตาของกล่อง
ENTITY Gated_DFF IS
    PORT (
        Clk    : IN  STD_LOGIC;
        RstB   : IN  STD_LOGIC;
        Ena    : IN  STD_LOGIC;
        D_in   : IN  STD_LOGIC;
        Q_out  : OUT STD_LOGIC
    );
END ENTITY Gated_DFF;

-- 2. ARCHITECTURE: อธิบายการทำงานข้างใน
ARCHITECTURE rtl OF Gated_DFF IS
    
    -- สร้าง "สัญญาณภายใน" (Internal Signal)
    -- *** นี่คือเทคนิคสำคัญ ***
    -- เราไม่สามารถ "อ่าน" ค่าจาก Port 'OUT' (Q_out) กลับมาใช้ได้
    -- เราจึงต้องสร้างสัญญาณภายใน (r_Q_out) เพื่อใช้จำค่า
    SIGNAL r_Q_out : STD_LOGIC;

BEGIN

    -- 3. PROCESS: สร้างวงจรที่ทำงานตาม Clock (Sequential Logic)
    -- นี่คือการสร้าง D-Flip-Flop
    u_Gated_DFF : PROCESS (Clk)
    BEGIN
        -- ทำงานเฉพาะ "ขอบขาขึ้น" ของ Clock เท่านั้น
        IF (rising_edge(Clk)) THEN
            
            -- Priority 1: Reset มาก่อนเสมอ
            IF (RstB = '0') THEN
                r_Q_out <= '0';
                
            -- Priority 2: ถ้าไม่ Reset, ก็เช็คว่า Enable?
            ELSIF (Ena = '1') THEN
                r_Q_out <= D_in;
                
            -- Priority 3: ถ้าไม่ Reset และไม่ Enable
            -- ก็ไม่ต้องทำอะไร (จำค่าเดิมไว้) ซึ่งคือ 'r_Q_out <= r_Q_out;'
            -- แต่ใน VHDL เราละไว้ได้เลย มันจะ "จำค่าเดิม" ให้อัตโนมัติ
            END IF;
            
        END IF;
    END PROCESS u_Gated_DFF;

    -- 4. CONCURRENT: ต่อสัญญาณภายใน (r_Q_out) ออกไปที่ Port (Q_out)
    -- โค้ดบรรทัดนี้อยู่นอก PROCESS และจะทำงาน "ตลอดเวลา"
    Q_out <= r_Q_out;

END ARCHITECTURE rtl;