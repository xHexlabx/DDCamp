-------------------------------------------------------------------------------------------------------
-- Copyright (c) 2017, Design Gateway Co., Ltd.
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
-- 1. Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- 2. Redistributions in binary form must reproduce the above copyright notice,
-- this list of conditions and the following disclaimer in the documentation
-- and/or other materials provided with the distribution.
--
-- 3. Neither the name of the copyright holder nor the names of its contributors
-- may be used to endorse or promote products derived from this software
-- without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
-- IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
-- EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Filename     TxSerialABC.vhd
-- Title        Top
--
-- Company      Design Gateway Co., Ltd.
-- Project      DD-Camp
-- PJ No.       
-- Syntax       VHDL
-- Note         

-- Version      1.00
-- Author       B.Attapon
-- Date         2017/11/16
-- Remark       New Creation
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity TxSerialABC Is
	Port
	(
		RstB		: in	std_logic;			-- use push button Key0 (active low)
		Button		: in	std_logic;			-- use push button Key1 (active low)
		Clk50		: in	std_logic;			-- clock input 50 MHz
		
		TxSerData	: out	std_logic;			-- Tx serial data out
		RESERVED	: in	std_logic_vector( 1 downto 0 )
	);
End Entity TxSerialABC;

Architecture rtl Of TxSerialABC Is

----------------------------------------------------------------------------------
-- Component declaration
----------------------------------------------------------------------------------

	Component TxSerial Is
	Port(
		RstB		: in	std_logic;
		Clk			: in	std_logic;
		
		TxFfEmpty	: in	std_logic;
		TxFfRdData	: in	std_logic_vector( 7 downto 0 );
		TxFfRdEn	: out	std_logic;
		
		SerDataOut	: out	std_logic
	);
	End Component TxSerial;

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------

	signal	rRstBCnt	: std_logic_vector( 22 downto 0 ) := (others=>'0');	
	signal	rSysRstB	: std_logic;
	
	signal	rButtonCnt	: std_logic_vector( 22 downto 0 );
	
	signal	TxFfRdEn	: std_logic;
	signal	rTxFfRdEn	: std_logic;	
	signal	rTxFfEmpty	: std_logic;
	signal	rTxFfRdData	: std_logic_vector( 7 downto 0 );
	
Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
				   
----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------

-----------------------------------------------------
-- Power on Reset
	u_rRstBCnt : Process (Clk50) Is
	Begin
		if ( rising_edge(Clk50) ) then
			if ( RstB='0' ) then
				rRstBCnt	<= (others=>'0');
			else
				if ( rRstBCnt(22)='1' ) then
					rRstBCnt	<= rRstBCnt;
				else
					rRstBCnt	<= rRstBCnt + 1;
				end if;
			end if;
		end if;
	End Process u_rRstBCnt;

	rSysRstB	<= rRstBCnt(22);
	
-----------------------------------------------------
-- Debounce Button

	u_rDeCnt : Process (Clk50) Is
	Begin
		if ( rising_edge(Clk50) ) then
			if ( rSysRstB='0' ) then
				rButtonCnt	<= (others=>'0');
			else
				if ( Button='0' ) then
					if ( rButtonCnt(22)='1' ) then
						rButtonCnt	<= rButtonCnt;
					else
						rButtonCnt	<= rButtonCnt + 1;
					end if;
				else
					rButtonCnt	<= (others=>'0');
				end if;
			end if;
		end if;
	End Process u_rDeCnt;
	
-----------------------------------------------------
-- TxSerial

	u_rTxFfEmpty : Process (Clk50) Is
	Begin
		if ( rising_edge(Clk50) ) then
			if ( rSysRstB='0' ) then
				rTxFfEmpty	<= '1';
			else
				rTxFfEmpty	<= not rButtonCnt(22);
			end if;
		end if;
	End Process u_rTxFfEmpty;
	
	u_rTxFfRdEn : Process (Clk50) Is
	Begin
		if ( rising_edge(Clk50) ) then
			rTxFfRdEn	<= TxFfRdEn;
		end if;
	End Process u_rTxFfRdEn;
	
	u_rTxFfRdData : Process (Clk50) Is
	Begin
		if ( rising_edge(Clk50) ) then
			if ( rSysRstB='0' ) then
				-- rTxFfRdData = 'A'
				rTxFfRdData(7 downto 0)	<= x"41";
			else
				-- increment ascii
				if ( rTxFfRdEn='1' ) then
					-- if (rTxFfRdData = 'Z')
					if ( rTxFfRdData(7 downto 0)=x"5A" ) then
						-- rTxFfRdData = 'A'
						rTxFfRdData(7 downto 0)	<= x"41";
					else
						rTxFfRdData(7 downto 0)	<= rTxFfRdData(7 downto 0) + 1;
					end if;
				else
					rTxFfRdData(7 downto 0)	<= rTxFfRdData(7 downto 0);
				end if;
			end if;
		end if;
	End Process u_rTxFfRdData;
	
	u_TxSerial : TxSerial
	Port map(
		RstB		=> rSysRstB		,
		Clk			=> Clk50		,

		TxFfEmpty	=> rTxFfEmpty	,
		TxFfRdData	=> rTxFfRdData	,
		TxFfRdEn	=> TxFfRdEn		,

		SerDataOut	=> TxSerData
	);

End Architecture rtl;