library IEEE ;
use IEEE.STD_LOGIC_1164.ALL ;

ENTITY DownCounter4bit is
    Port(
        Clk     : IN  STD_LOGIC ;
        RstB    : IN  STD_LOGIC ;
        Ena     : IN  STD_LOGIC ;
        Counter_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END ENTITY DownCounter4bit ;

ARCHITECTURE rtl of DownCounter4bit is

    SIGNAL rCounter : STD_LOGIC_VECTOR (3 DOWNTO 0) ;

    u_rCounter : PROCESS (Clk)
    BEGIN
        IF (rising_edge(Clk)) THEN
            IF (RstB = '0') THEN
                rCounter <= "1111" ;
            ELSIF (Ena = '1') THEN
                rCounter <= rCounter - "0001" ;
            ELSE 
                rCounter <= rCounter ;
            END IF ;
        END IF ;
    END PROCESS u_rCounter ;

    Counter_out <= rCounter ;

END ARCHITECTURE rtl ;