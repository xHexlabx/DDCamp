library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

ENTITY VGA_Color_Generator IS
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
END ENTITY VGA_Color_Generator;

ARCHITECTURE rtl OF VGA_Color_Generator IS

    CONSTANT H_DISPLAY   : INTEGER := 1024;
    CONSTANT H_FP        : INTEGER := 24;
    CONSTANT H_SYNC      : INTEGER := 136;
    CONSTANT H_BP        : INTEGER := 160;
    CONSTANT H_TOTAL     : INTEGER := H_DISPLAY + H_FP + H_SYNC + H_BP; -- 1344

    CONSTANT V_DISPLAY   : INTEGER := 768;
    CONSTANT V_FP        : INTEGER := 3;
    CONSTANT V_SYNC      : INTEGER := 6;
    CONSTANT V_BP        : INTEGER := 29;
    CONSTANT V_TOTAL     : INTEGER := V_DISPLAY + V_FP + V_SYNC + V_BP; -- 806

    SIGNAL r_h_count : INTEGER RANGE 0 TO H_TOTAL-1;
    SIGNAL r_v_count : INTEGER RANGE 0 TO V_TOTAL-1;

    SIGNAL r_HSync      : STD_LOGIC;
    SIGNAL r_VSync      : STD_LOGIC;
    SIGNAL r_DataEnable : STD_LOGIC;

    SIGNAL r_VGA_Red    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL r_VGA_Green  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL r_VGA_Blue   : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

    vga_timing_proc : PROCESS (Clk)
    BEGIN
        IF (rising_edge(Clk)) THEN
            IF (RstB = '0') THEN
                r_h_count    <= 0;
                r_v_count    <= 0;
                r_HSync      <= '1';
                r_VSync      <= '1';
                r_DataEnable <= '0';
            ELSE
                IF (r_h_count = H_TOTAL - 1) THEN
                    r_h_count <= 0;
                    IF (r_v_count = V_TOTAL - 1) THEN
                        r_v_count <= 0;
                    ELSE
                        r_v_count <= r_v_count + 1;
                    END IF;
                ELSE
                    r_h_count <= r_h_count + 1;
                END IF;

                IF (r_h_count >= H_DISPLAY + H_FP) AND 
                   (r_h_count < H_DISPLAY + H_FP + H_SYNC) THEN
                    r_HSync <= '0';
                ELSE
                    r_HSync <= '1';
                END IF;

                IF (r_v_count >= V_DISPLAY + V_FP) AND 
                   (r_v_count < V_DISPLAY + V_FP + V_SYNC) THEN
                    r_VSync <= '0';
                ELSE
                    r_VSync <= '1';
                END IF;

                IF (r_h_count < H_DISPLAY) AND (r_v_count < V_DISPLAY) THEN
                    r_DataEnable <= '1';
                ELSE
                    r_DataEnable <= '0';
                END IF;
                
            END IF;
        END IF;
    END PROCESS vga_timing_proc;

    color_bar_proc : PROCESS (Clk)
        CONSTANT RED   : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
        CONSTANT GREEN : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
        CONSTANT BLUE  : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
        CONSTANT BLACK : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
        CONSTANT WHITE : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    BEGIN
        IF (rising_edge(Clk)) THEN
            IF (r_DataEnable = '1') THEN
                
                IF (r_h_count < 128) THEN
                    r_VGA_Red   <= WHITE;
                    r_VGA_Green <= WHITE;
                    r_VGA_Blue  <= WHITE;
                ELSIF (r_h_count < 256) THEN
                    r_VGA_Red   <= RED;
                    r_VGA_Green <= GREEN;
                    r_VGA_Blue  <= BLACK;
                ELSIF (r_h_count < 384) THEN
                    r_VGA_Red   <= BLACK;
                    r_VGA_Green <= GREEN;
                    r_VGA_Blue  <= BLUE;
                ELSIF (r_h_count < 512) THEN
                    r_VGA_Red   <= BLACK;
                    r_VGA_Green <= GREEN;
                    r_VGA_Blue  <= BLACK;
                ELSIF (r_h_count < 640) THEN
                    r_VGA_Red   <= RED;
                    r_VGA_Green <= BLACK;
                    r_VGA_Blue  <= BLUE;
                ELSIF (r_h_count < 768) THEN
                    r_VGA_Red   <= RED;
                    r_VGA_Green <= BLACK;
                    r_VGA_Blue  <= BLACK;
                ELSIF (r_h_count < 896) THEN
                    r_VGA_Red   <= BLACK;
                    r_VGA_Green <= BLACK;
                    r_VGA_Blue  <= BLUE;
                ELSE
                    r_VGA_Red   <= BLACK;
                    r_VGA_Green <= BLACK;
                    r_VGA_Blue  <= BLACK;
                END IF;
                
            ELSE
                r_VGA_Red   <= (OTHERS => '0');
                r_VGA_Green <= (OTHERS => '0');
                r_VGA_Blue  <= (OTHERS => '0');
            END IF;
        END IF;
    END PROCESS color_bar_proc;

    HSync      <= r_HSync;
    VSync      <= r_VSync;
    DataEnable <= r_DataEnable;
    VGA_Red    <= r_VGA_Red;
    VGA_Green  <= r_VGA_Green;
    VGA_Blue   <= r_VGA_Blue;

END ARCHITECTURE rtl;