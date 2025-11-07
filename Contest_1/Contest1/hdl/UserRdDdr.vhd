----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Filename     UserRdDdr.vhd
-- Title        Top
--
-- Company      Design Gateway Co., Ltd.
-- Project      DDCamp
-- PJ No.       
-- Syntax       VHDL
-- Note         

-- Version      1.00
-- Author       B.Attapon
-- Date         2017/12/20
-- Remark       New Creation
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity UserRdDdr Is
	Port
	(
		RstB			: in	std_logic;							-- use push button Key0 (active low)
		Clk				: in	std_logic;							-- clock input 100 MHz

		DipSwitch		: in 	std_logic_vector( 1 downto 0 );
		
		-- HDMICtrl I/F
		HDMIReq			: out	std_logic;
		HDMIBusy		: in	std_logic;
		
		-- RdCtrl I/F
		MemInitDone		: in	std_logic;
		MtDdrRdReq		: out	std_logic;
		MtDdrRdBusy		: in	std_logic;
		MtDdrRdAddr		: out	std_logic_vector( 28 downto 7 );
		
		-- D2URdFf I/F
		D2URdFfWrEn		: in	std_logic;
		D2URdFfWrData	: in	std_logic_vector( 63 downto 0 );
		D2URdFfWrCnt	: out	std_logic_vector( 15 downto 0 );
		
		-- URd2HFf I/F
		URd2HFfWrEn		: out	std_logic;
		URd2HFfWrData	: out	std_logic_vector( 63 downto 0 );
		URd2HFfWrCnt	: in	std_logic_vector( 15 downto 0 )
	);
End Entity UserRdDdr;



Architecture rtl Of UserRdDdr Is

----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------
	constant cTotalChunk : integer := 24576; -- 1 frame = 24,576 chunks (1024 × 768 / 8 pixels)
	
----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------

	type tState Is (stRead, stWaitDDr, stWaitFF);
	signal	rState			: tState;
	signal  cur_DipSwitch	: std_logic_vector(1 downto 0);
	signal  cur_chunkCnt	: std_logic_vector(15 downto 0);
	signal  rdataCnt		: std_logic_vector(4 downto 0);
	signal	rMemInitDone	: std_logic_vector( 1 downto 0 );
	signal	rHDMIReq		: std_logic;
	
Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
	HDMIReq			<= rHDMIReq;
	URd2HFfWrEn 	<= D2URdFfWrEn;
	URd2HFfWrData   <= D2URdFfWrData;
	D2URdFfWrCnt    <= URd2HFfWrCnt;

----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------

	u_rStateMachine : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rState	<= stRead;
				cur_chunkCnt <= (others => '0');
			else
				if( rMemInitDone(1) = '1' ) then
					case rState is					
						when stRead =>
							if(cur_chunkCnt = conv_std_logic_vector(cTotalChunk, cur_chunkCnt'length)) then
								cur_chunkCnt <= (others => '0');
							else
								MtDdrRdReq <= '1';
								MtDdrRdAddr <= DipSwitch & "0000" & cur_chunkCnt;
								rState <= stWaitDDr;
							end if;

						when stWaitDDr =>
							if( MtDdrRdBusy = '1') then
								MtDdrRdReq <= '0';
								cur_chunkCnt <= cur_chunkCnt + 1;
								rState <= stWaitFF;
							else
								rState <= stWaitDDr;	
							end if;

						when stWaitFF =>
							if(MtDdrRdBusy = '0') then
								rState <= stRead;
							else
								rState <= stWaitFF;
							end if;

					end case;
				end if;
					
			end if;
		end if;
	end Process  u_rStateMachine;

	

	u_rMemInitDone : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rMemInitDone	<= "00";
			else
				-- Use rMemInitDone(1) in your design
				rMemInitDone	<= rMemInitDone(0) & MemInitDone;
			end if;
		end if;
	End Process u_rMemInitDone;

	u_rHDMIReq : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rHDMIReq	<= '0';
			else
				if ( HDMIBusy='0' and rMemInitDone(1)='1' ) then
					rHDMIReq	<= '1';
				elsif ( HDMIBusy='1' )  then
					rHDMIReq	<= '0';
				else
					rHDMIReq	<= rHDMIReq;
				end if;
			end if;
		end if;
	End Process u_rHDMIReq;
	
End Architecture rtl;