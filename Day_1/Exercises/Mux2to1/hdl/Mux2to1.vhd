library IEEE ; 
use IEEE.std_logic_1164.ALL ;

ENTITY Mux2to1 is
    PORT (
        A      : IN  STD_LOGIC ;
        B      : IN  STD_LOGIC ;
        Sel    : IN  STD_LOGIC ;
        Y      : OUT STD_LOGIC
    ) ;
END ENTITY Mux2to1 ;

ARCHITECTURE rtl of Mux2to1 is
BEGIN 

    Y <= A WHEN (Sel = '0') ELSE B ;

END ARCHITECTURE rtl ;