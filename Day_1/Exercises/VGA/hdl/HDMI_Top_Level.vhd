library IEEE;
use IEEE.std_logic_1164.ALL;

ENTITY HDMI_Top_Level IS
    PORT (
        Clk_50    : IN  STD_LOGIC;
        RstB      : IN  STD_LOGIC;

        I2C_SCL   : OUT STD_LOGIC;
        I2C_SDA   : INOUT STD_LOGIC;

        HDMI_TX_CLK : OUT STD_LOGIC;
        HDMI_TX_HS  : OUT STD_LOGIC;
        HDMI_TX_VS  : OUT STD_LOGIC;
        HDMI_TX_DE  : OUT STD_LOGIC;
        HDMI_TX_D   : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
    );
END ENTITY HDMI_Top_Level;


ARCHITECTURE rtl OF HDMI_Top_Level IS

    COMPONENT vga_pll IS
        PORT (
            inclk0 : IN  STD_LOGIC := '0';
            c0     : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT VGA_Color_Generator IS
        PORT (
            Clk      : IN  STD_LOGIC;
            RstB     : IN  STD_LOGIC;
            HSync      : OUT STD_LOGIC;
            VSync      : OUT STD_LOGIC;
            DataEnable : OUT STD_LOGIC;
            VGA_Red    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            VGA_Green  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            VGA_Blue   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT I2C_Controller IS
        PORT (
            Clk_50  : IN  STD_LOGIC;
            RstB    : IN  STD_LOGIC;
            I2C_SCL : OUT STD_LOGIC;
            I2C_SDA : INOUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL s_Pixel_Clk_65MHz : STD_LOGIC;
    SIGNAL s_HSync           : STD_LOGIC;
    SIGNAL s_VSync           : STD_LOGIC;
    SIGNAL s_DataEnable      : STD_LOGIC;
    SIGNAL s_VGA_Red         : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL s_VGA_Green       : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL s_VGA_Blue        : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

    inst_pll : vga_pll
        PORT MAP (
            inclk0 => Clk_50,
            c0     => s_Pixel_Clk_65MHz
        );

    inst_i2c : I2C_Controller
        PORT MAP (
            Clk_50  => Clk_50,
            RstB    => RstB,
            I2C_SCL => I2C_SCL,
            I2C_SDA => I2C_SDA
        );

    inst_vga_gen : VGA_Color_Generator
        PORT MAP (
            Clk        => s_Pixel_Clk_65MHz,
            RstB       => RstB,
            HSync      => s_HSync,
            VSync      => s_VSync,
            DataEnable => s_DataEnable,
            VGA_Red    => s_VGA_Red,
            VGA_Green  => s_VGA_Green,
            VGA_Blue   => s_VGA_Blue
        );

    HDMI_TX_CLK <= s_Pixel_Clk_65MHz;
    HDMI_TX_HS  <= s_HSync;
    HDMI_TX_VS  <= s_VSync;
    HDMI_TX_DE  <= s_DataEnable;
    
    HDMI_TX_D <= s_VGA_Blue & s_VGA_Green & s_VGA_Red;

END ARCHITECTURE rtl;