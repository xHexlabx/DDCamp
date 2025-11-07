library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity TxSerial Is
Port(
	RstB		: in	std_logic;
	Clk			: in	std_logic;
	
	TxFfEmpty	: in	std_logic;
	TxFfRdData	: in	std_logic_vector( 7 downto 0 );
	TxFfRdEn	: out	std_logic;
	
	SerDataOut	: out	std_logic
);
End Entity TxSerial;

Architecture rtl Of TxSerial Is

----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------


Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------

	
End Architecture rtl;