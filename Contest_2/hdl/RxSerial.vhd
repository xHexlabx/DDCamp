library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity RxSerial is
    port (
        RstB        : in  std_logic;
        Clk         : in  std_logic;

        SerDataIn   : in  std_logic;

        RxFfWrData  : out std_logic_vector(7 downto 0);
        RxFfWrEn    : out std_logic
    );
end entity RxSerial;

architecture rtl of RxSerial is

    ------------------------------------------------------------------------------
    -- Constant Declaration
    ------------------------------------------------------------------------------
    constant cBaudRate      : integer := 108;
    constant cHalfBaudRate  : integer := 54;

    ------------------------------------------------------------------------------
    -- Signal Declaration
    ------------------------------------------------------------------------------
    type SerStateType is (stIdle, stStart, stData, stStop, stLoad);
    signal rState        : SerStateType;

    signal rSerDataIn    : std_logic;
    signal rBaudCnt      : std_logic_vector(9 downto 0);
    signal rBaudEnd      : std_logic;
    signal rDataCnt      : std_logic_vector(3 downto 0);
    signal rRxFfWrData   : std_logic_vector(7 downto 0);
    signal rRxFfWrEn     : std_logic;

begin

    ------------------------------------------------------------------------------
    -- Output Assignments
    ------------------------------------------------------------------------------
    RxFfWrData <= rRxFfWrData;
    RxFfWrEn   <= rRxFfWrEn;

    ------------------------------------------------------------------------------
    -- Baud Rate Counter
    ------------------------------------------------------------------------------
    u_rBaudCnt : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rBaudCnt <= conv_std_logic_vector(cBaudRate, 10);
            elsif (rBaudCnt = 1) or (rState = stIdle) or
                  ((rState = stStart) and (rBaudCnt = conv_std_logic_vector(cHalfBaudRate, 10))) then
                rBaudCnt <= conv_std_logic_vector(cBaudRate, 10);
            else
                rBaudCnt <= rBaudCnt - 1;
            end if;
        end if;
    end process u_rBaudCnt;

    ------------------------------------------------------------------------------
    -- Baud End Flag
    ------------------------------------------------------------------------------
    u_rBaudEnd : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rBaudEnd <= '0';
            elsif rBaudCnt = 1 then
                rBaudEnd <= '1';
            else
                rBaudEnd <= '0';
            end if;
        end if;
    end process u_rBaudEnd;

    ------------------------------------------------------------------------------
    -- Bit Counter
    ------------------------------------------------------------------------------
    u_rDataCnt : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rDataCnt <= (others => '0');
            else
                if rBaudEnd = '1' then
                    if rDataCnt = 7 then
                        rDataCnt <= (others => '0');
                    else
                        rDataCnt <= rDataCnt + 1;
                    end if;
                elsif rState = stStart then
                    rDataCnt <= (others => '0');
                end if;
            end if;
        end if;
    end process u_rDataCnt;

    ------------------------------------------------------------------------------
    -- Input Synchronizer
    ------------------------------------------------------------------------------
    u_rSerDataIn : process(Clk)
    begin
        if rising_edge(Clk) then
            rSerDataIn <= SerDataIn;
        end if;
    end process u_rSerDataIn;

    ------------------------------------------------------------------------------
    -- Shift Register for Receive Data
    ------------------------------------------------------------------------------
    u_rRxFfWrData : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rRxFfWrData <= (others => '0');
            else
                if (rBaudEnd = '1') and (rState /= stStop) then
                    rRxFfWrData(6 downto 0) <= rRxFfWrData(7 downto 1);
                    rRxFfWrData(7) <= rSerDataIn;
                end if;
            end if;
        end if;
    end process u_rRxFfWrData;

    ------------------------------------------------------------------------------
    -- FIFO Write Enable
    ------------------------------------------------------------------------------
    u_rRxFfWrEn : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rRxFfWrEn <= '0';
            elsif rState = stLoad then
                rRxFfWrEn <= '1';
            else
                rRxFfWrEn <= '0';
            end if;
        end if;
    end process u_rRxFfWrEn;

    ------------------------------------------------------------------------------
    -- State Machine
    ------------------------------------------------------------------------------
    u_rState : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rState <= stIdle;
            else
                case rState is

                    when stIdle =>
                        if rSerDataIn = '0' then
                            rState <= stStart;
                        end if;

                    when stStart =>
                        if rBaudCnt = conv_std_logic_vector(cHalfBaudRate, 10) then
                            rState <= stData;
                        end if;

                    when stData =>
                        if (rDataCnt = 7) and (rBaudEnd = '1') then
                            rState <= stStop;
                        end if;

                    when stStop =>
                        if rBaudEnd = '1' then
                            if rSerDataIn = '1' then
                                rState <= stLoad;
                            else
                                rState <= stIdle;  -- No stop bit found
                            end if;
                        end if;

                    when stLoad =>
                        rState <= stIdle;

                end case;
            end if;
        end if;
    end process u_rState;

end architecture rtl;
