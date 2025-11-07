----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Filename     UserWrDdr.vhd
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


Entity UserWrDdr Is
	Port
	(
		RstB			: in	std_logic;							-- use push button Key0 (active low)
		Clk				: in	std_logic;							-- clock input 100 MHz

		-- WrCtrl I/F
		MemInitDone		: in	std_logic;
		MtDdrWrReq		: out	std_logic;
		MtDdrWrBusy		: in	std_logic;
		MtDdrWrAddr		: out	std_logic_vector( 28 downto 7 );
		
		-- T2UWrFf I/F
		T2UWrFfRdEn		: out	std_logic;
		T2UWrFfRdData	: in	std_logic_vector( 63 downto 0 );
		T2UWrFfRdCnt	: in	std_logic_vector( 15 downto 0 );
		
		-- UWr2DFf I/F
		UWr2DFfRdEn		: in	std_logic;
		UWr2DFfRdData	: out	std_logic_vector( 63 downto 0 );
		UWr2DFfRdCnt	: out	std_logic_vector( 15 downto 0 )
	);
End Entity UserWrDdr;


Architecture rtl Of UserWrDdr Is

----------------------------------------------------------------------------------
-- Component declaration
----------------------------------------------------------------------------------

	constant cTotalChunk : integer := 24576; -- 1 frame = 24,576 chunks (1024 × 768 / 8 pixels)
	
----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	
	signal	rMemInitDone	: std_logic_vector( 1 downto 0 );

	type tState Is (stReq, stWaitDDr, stWaitFF);
	signal	rState			: tState;
	signal  cur_DipSwitch	: std_logic_vector(1 downto 0);
	signal  cur_chunkCnt	: std_logic_vector(15 downto 0);
	signal  rdataCnt		: std_logic_vector(4 downto 0);
	
Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
	T2UWrFfRdEn	<= UWr2DFfRdEn;
	UWr2DFfRdData <= T2UWrFfRdData;
	UWr2DFfRdCnt <= T2UWrFfRdCnt;

----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
	u_rStateMachine : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rState	<= stReq;
				cur_chunkCnt <= (others => '0');
				cur_DipSwitch <= "00";
			else
				if( rMemInitDone(1) = '1') then
					case rState is					
						when stReq =>
							if(cur_chunkCnt = conv_std_logic_vector(cTotalChunk, cur_chunkCnt'length)) then
								cur_chunkCnt <= (others => '0');
								cur_DipSwitch <= cur_DipSwitch+1;
							else
								MtDdrWrReq <= '1';
								MtDdrWrAddr <= cur_DipSwitch & "0000" & cur_chunkCnt;
								rState <= stWaitDDr;
							end if;

						when stWaitDDr =>
							if( MtDdrWrBusy = '1') then
								MtDdrWrReq <= '0';
								cur_chunkCnt <= cur_chunkCnt + 1;
								rState <= stWaitFF;
							else
								rState <= stWaitDDr;	
							end if;

						when stWaitFF =>
							if(MtDdrWrBusy = '0') then
								rState <= stReq;
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
	
End Architecture rtl;