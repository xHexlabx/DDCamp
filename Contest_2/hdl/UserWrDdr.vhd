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
	
	
----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	
	signal	rMemInitDone	: std_logic_vector( 1 downto 0 );

	signal	rMtDdrWrReq		: std_logic;
	signal	rMtDdrWrAddr	: std_logic_vector(28 downto 7);

	type	UserWrStateType	is
		(
			stInit		,
			stCheckFf	,
			stReq		,
			stWtMtDone	
		);
	signal	rState			: UserWrStateType;

	signal rRowReqCnt		: std_logic_vector(4 downto 0);
	
Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------

	--Bypass
	T2UWrFfRdEn		<=	UWr2DFfRdEn;
	UWr2DFfRdData( 63 downto 0 )	<=	T2UWrFfRdData( 63 downto 0 );
	UWr2DFfRdCnt( 15 downto 0 )		<=	T2UWrFfRdCnt( 15 downto 0 );
	
	MtDdrWrReq		<=	rMtDdrWrReq;
	MtDdrWrAddr(28 downto 7)		<=	rMtDdrWrAddr(28 downto 7);

----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
	
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

	u_rMtDdrWrReq: process(Clk)
	begin
		if rising_edge(Clk) then
			if RstB = '0' then
				rMtDdrWrReq		<=	'0';
			else
				if rState = stReq then
					rMtDdrWrReq		<=	'1';
				else
					rMtDdrWrReq		<=	'0';
				end if ;
			end if;
		end if;
	end process u_rMtDdrWrReq;

	u_rMtDdrWrAddr: process(Clk)
	begin
		if rising_edge(Clk) then
			if RstB = '0' then
				-- start at addr = 24544 (last row first col which is the first received pixcel's addr)
				rMtDdrWrAddr(28 downto 7)	<=	"00" & x"05FE0";
			else
				if( (rState = stWtMtDone) and (MtDdrWrBusy = '0') ) then
					-- check if reached first row last col
					if rMtDdrWrAddr(26 downto 7) = 31 then
						rMtDdrWrAddr(28 downto 27)	<= rMtDdrWrAddr(28 downto 27) + 1;
						rMtDdrWrAddr(26 downto 7)	<= x"05FE0";
					-- if writen to the last col then go back to the upper line
					elsif rRowReqCnt = 31 then
						rMtDdrWrAddr(28 downto 7)	<= rMtDdrWrAddr(28 downto 7) - 63;
					else
						rMtDdrWrAddr(28 downto 7)	<= rMtDdrWrAddr(28 downto 7) + 1;
					end if ;
				else
					rMtDdrWrAddr(28 downto 7)	<= rMtDdrWrAddr(28 downto 7);
				end if;
			end if;
		end if;
	end process u_rMtDdrWrAddr;

	u_rRowReqCnt: process(Clk)
	begin
		if rising_edge(Clk) then
			if RstB = '0' then
				rRowReqCnt	<=	(others => '0');
			else
				if( (rState = stWtMtDone) and (MtDdrWrBusy = '0') ) then
					rRowReqCnt	<=	rRowReqCnt + 1;
				else
					rRowReqCnt	<=	rRowReqCnt;
				end if;
			end if;
		end if;
	end process u_rRowReqCnt;

----------------------------------------------------------------------------------
-- State Machine 
----------------------------------------------------------------------------------
	
	u_rState: process(Clk)
	begin
		if rising_edge(Clk) then
			if RstB = '0' then
				rState	<=	stInit;
			else
				case( rState ) is
				
					when stInit =>
						if rMemInitDone(1) = '1' then
							rState	<=	stCheckFf;
						else
							rState	<=	stInit;
						end if ;	
					
					when stCheckFf	=>
						if T2UWrFfRdCnt( 15 downto 4 ) /= 0 then
							rState	<=	stReq;
						else
							rState	<=	stCheckFf;
						end if ;

					when stReq	=>
						if MtDdrWrBusy = '1' then
							rState	<=	stWtMtDone;
						else
							rState	<=	stReq;
						end if ;

					when stWtMtDone	=>
						if MtDdrWrBusy = '0' then
							rState	<=	stCheckFf;
						else
							rState	<=	stWtMtDone;
						end if ;
				
				end case ;
			end if;
		end if;
	end process u_rState;

End Architecture rtl;