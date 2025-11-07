library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity TxSerial Is
Port(
    RstB        : in    std_logic;
    Clk         : in    std_logic;
    
    TxFfEmpty   : in    std_logic;
    TxFfRdData  : in    std_logic_vector( 7 downto 0 );
    TxFfRdEn    : out   std_logic;
    
    SerDataOut  : out   std_logic
);
End Entity TxSerial;

Architecture rtl Of TxSerial Is

----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------
constant cbuadCnt : integer := 434; -- For 115200 Baud Rate with 50MHz Clk

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
-- State Machine
type SerStateType is (
    stIdle,
    stRdReq,
    stWtData,
    stWtEnd
);
signal rState : SerStateType;

-- Read Enable
signal rTxFfRdEn : std_logic_vector(1 downto 0);

-- Baud Rate Generator
signal rBuadCnt : std_logic_vector(9 downto 0); -- 10 bits to hold 434
signal rBuadEnd : std_logic;

-- Serial Data Shift Register
signal rSerData : std_logic_vector(9 downto 0); -- 1 Start + 8 Data + 1 Stop

-- Data Bit Counter
signal rDataCnt : std_logic_vector(3 downto 0); -- 4 bits to count 10 bits (0-9)

Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
TxFfRdEn   <= rTxFfRdEn(0);
SerDataOut <= rSerData(0);

----------------------------------------------------------------------------------
-- DFF (Processes)
----------------------------------------------------------------------------------

-- Process 1: Main State Machine (Reconstructed from)
u_rState : process (Clk) is
begin
    if (rising_edge(Clk)) then
        if (RstB = '0') then
            rState <= stIdle;
        else
            case (rState) is
                when stIdle =>
                    if (TxFfEmpty = '0') then
                        rState <= stRdReq;
                    else
                        rState <= stIdle;
                    end if;
                    
                when stRdReq =>
                    rState <= stWtData; -- Move to wait data
                    
                when stWtData => -- Wait for first bit (Start bit) to be sent
                    if (rTxFfRdEn(1) = '1') then
                        rState <= stWtEnd;
                    end if;
                    
                when stWtEnd => -- Wait for remaining 9 bits to be sent
                    if (rBuadEnd = '1' and rDataCnt = conv_std_logic_vector(9, 4)) then -- Waited for 10 bits (0..9)
                        rState <= stIdle;
                    else
                        rState <= stWtEnd;
                    end if;
                    
                when others =>
                    rState <= stIdle;
                    
            end case;
        end if;
    end if;
end process u_rState;


-- Process 2: Read Enable Logic (from slide 36)
u_rTxFfRdEn : process (Clk) is
begin
    if (rising_edge(Clk)) then
        if (RstB = '0') then
            rTxFfRdEn <= "00";
        else
            rTxFfRdEn(1) <= rTxFfRdEn(0); -- Delayed version for data loading
            if (rState = stRdReq) then
                rTxFfRdEn(0) <= '1';
            else
                rTxFfRdEn(0) <= '0';
            end if;
        end if;
    end if;
end process u_rTxFfRdEn;


-- Process 3: Baud Rate Counter (แก้ไขขั้นต่ำ)
-- สมมติว่ายังใช้ library 'std_logic_unsigned'
u_rBuadCnt : process (Clk) is
begin
    if (rising_edge(Clk)) then
        if (RstB = '0') then
            rBuadCnt <= conv_std_logic_vector(cbuadCnt, 10);
        else
            if (rBuadCnt = conv_std_logic_vector(1, 10)) then
                rBuadCnt <= conv_std_logic_vector(cbuadCnt, 10);
            else 
                -- แก้ไข Syntax Error (ลบ ')' ที่เกินมา)
                if (rState = stWtEnd) then
                    rBuadCnt <= rBuadCnt - 1;
                else
                    -- แก้ไข Magic Number (ใช้ค่าคงที่แทน)
                    rBuadCnt <= conv_std_logic_vector(cbuadCnt, 10);
                end if;
            end if;
        end if;
    end if;
end process u_rBuadCnt;


-- Process 4: Baud Rate Pulse Generator (from slide 20)
u_rBuadEnd : process (Clk) is
begin
    if (rising_edge(Clk)) then
        if (RstB = '0') then
            rBuadEnd <= '0';
        else
            if (rBuadCnt = conv_std_logic_vector(1, 10)) then
                rBuadEnd <= '1';
            else
                rBuadEnd <= '0';
            end if;
        end if;
    end if;
end process u_rBuadEnd;


-- Process 5: Serial Data Shift Register (from slide 36)
u_rSerData : process (Clk) is
begin
    if (rising_edge(Clk)) then
        if (RstB = '0') then
            rSerData <= (others => '1'); -- Idle line is high
        else
            if (rTxFfRdEn(1) = '1') then -- Load data
                rSerData(9) <= '1'; -- Stop Bit
                rSerData(8 downto 1) <= TxFfRdData;
                rSerData(0) <= '0'; -- Start Bit
            elsif (rBuadEnd = '1' and rState /= stIdle) then -- Shift data
                rSerData <= '1' & rSerData(9 downto 1);
            else
                rSerData <= rSerData; -- Hold
            end if;
        end if;
    end if;
end process u_rSerData;


-- Process 6: Data Bit Counter (Reconstructed from)
u_rDataCnt : process (Clk) is
begin
    if (rising_edge(Clk)) then
        if (RstB = '0') then
            rDataCnt <= (others => '0');
        else
            if (rState = stIdle) then -- Reset counter when idle
                rDataCnt <= (others => '0');
            elsif (rBuadEnd = '1' and (rState = stWtData or rState = stWtEnd)) then -- Count when sending
                rDataCnt <= rDataCnt + 1;
            end if;
        end if;
    end if;
end process u_rDataCnt;

    
End Architecture rtl;