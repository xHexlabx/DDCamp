library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity BitMapPatt is
    port (
        RstB        : in  std_logic;
        Clk         : in  std_logic;

        RxBmWrEn    : in  std_logic;
        RxBmWrData  : in  std_logic_vector(7 downto 0);

        BmFfWrEn    : out std_logic;
        BmFfWrData  : out std_logic_vector(23 downto 0);
        BmFfWrCnt   : in  std_logic_vector(7 downto 0)
    );
end entity BitMapPatt;

architecture rtl of BitMapPatt is

    ------------------------------------------------------------------------------
    -- Type and Signal Declarations
    ------------------------------------------------------------------------------

    type BitMapPatternStateType is (stIdle, stHeader, stRdData);
    signal rState        : BitMapPatternStateType;

    signal rBmFfWrEn     : std_logic;
    signal rBmFfWrData   : std_logic_vector(23 downto 0);
    signal rHeaderCnt    : std_logic_vector(5 downto 0);
    signal rRGBCnt       : std_logic_vector(1 downto 0);
    signal rPixCnt       : std_logic_vector(19 downto 0);

begin

    ------------------------------------------------------------------------------
    -- Output Assignments
    ------------------------------------------------------------------------------

    BmFfWrData <= rBmFfWrData;
    BmFfWrEn   <= rBmFfWrEn;

    ------------------------------------------------------------------------------
    -- Header Counter
    ------------------------------------------------------------------------------

    u_rHeaderCnt : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rHeaderCnt <= (others => '0');
            else
                if (rState <= stIdle) and (RxBmWrEn = '1') then
                    rHeaderCnt <= (others => '0');
                elsif (rState = stHeader) and (RxBmWrEn = '1') then
                    rHeaderCnt <= rHeaderCnt + 1;
                end if;
            end if;
        end if;
    end process u_rHeaderCnt;

    ------------------------------------------------------------------------------
    -- RGB Counter
    ------------------------------------------------------------------------------

    u_rRGBCnt : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rRGBCnt <= "00";
            else
                if ((rState = stHeader) and (rHeaderCnt = 53)) or (rRGBCnt = 0) then
                    rRGBCnt <= "11";
                elsif (rState = stRdData) and (RxBmWrEn = '1') then
                    rRGBCnt <= rRGBCnt - 1;
                end if;
            end if;
        end if;
    end process u_rRGBCnt;

    ------------------------------------------------------------------------------
    -- Pixel Counter
    ------------------------------------------------------------------------------

    u_rPixCnt : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rPixCnt <= (others => '0');
            else
                if rPixCnt = 786434 - 1 then
                    rPixCnt <= (others => '0');
                elsif rBmFfWrEn = '1' then
                    rPixCnt <= rPixCnt + 1;
                end if;
            end if;
        end if;
    end process u_rPixCnt;

    ------------------------------------------------------------------------------
    -- Bitmap FIFO Write Data
    ------------------------------------------------------------------------------

    u_rBmFfWrData : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rBmFfWrData <= (others => '0');
            else
                if (rState = stRdData) and (RxBmWrEn = '1') then
                    rBmFfWrData <= RxBmWrData & rBmFfWrData(23 downto 8);
                end if;
            end if;
        end if;
    end process u_rBmFfWrData;

    ------------------------------------------------------------------------------
    -- Bitmap FIFO Write Enable
    ------------------------------------------------------------------------------

    u_rBmFfWrEn : process(Clk)
    begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rBmFfWrEn <= '0';
            else
                if rRGBCnt = 0 then
                    rBmFfWrEn <= '1';
                else
                    rBmFfWrEn <= '0';
                end if;
            end if;
        end if;
    end process u_rBmFfWrEn;

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
                        if RxBmWrEn = '1' then
                            rState <= stHeader;
                        end if;

                    when stHeader =>
                        if rHeaderCnt = 54 - 1 then
                            rState <= stRdData;
                        end if;

                    when stRdData =>
                        if rPixCnt = 786434 - 1 then
                            rState <= stIdle;
                        end if;
                end case;
            end if;
        end if;
    end process u_rState;

end architecture rtl;
