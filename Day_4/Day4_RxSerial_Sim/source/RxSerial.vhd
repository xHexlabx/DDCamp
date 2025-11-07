library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity RxSerial Is
Port(
	RstB		: in	std_logic;
	Clk			: in	std_logic;
	
	SerDataIn	: in	std_logic;
	
	RxFfFull	: in	std_logic;
	RxFfWrData	: out	std_logic_vector( 7 downto 0 );
	RxFfWrEn	: out	std_logic
);
End Entity RxSerial;

Architecture rtl Of RxSerial Is

----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------
	-- 100,000,000 / 115200 = 868.05
	constant cBaudFullTick	: integer := 868;
	constant cBaudHalfTick	: integer := 434;

----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	
	signal	rSerDataIn	: std_logic;
	
	-- State Machine
	type SerStateType is ( stIdle, stStart, stData, stStop ); 
	signal	rSerState	: SerStateType; 
	
	-- Counters
	signal	rBaudCnt	: integer range 0 to cBaudFullTick;
	signal	rBitCnt		: integer range 0 to 7;
	
	-- Data Register
	signal	rDataReg	: std_logic_vector( 7 downto 0 );
	
	-- Registered Outputs
	signal	rRxFfWrEn	: std_logic;
	signal	rRxFfWrData	: std_logic_vector( 7 downto 0 );
	
Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
	RxFfWrData	<= rRxFfWrData;
	RxFfWrEn	<= rRxFfWrEn;

----------------------------------------------------------------------------------
-- DFF (Input Synchronizer)
----------------------------------------------------------------------------------
	-- Add Flip-Flop to input pin [cite: 281]
	u_rSerDataIn : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			rSerDataIn		<= SerDataIn;
		end if;
	End Process u_rSerDataIn;

----------------------------------------------------------------------------------
-- RX FSM Logic
----------------------------------------------------------------------------------
	u_RxLogic : process (Clk) is
	begin
		if (rising_edge(Clk)) then
			if (RstB = '0') then
				-- Reset state
				rSerState   <= stIdle;
				rBaudCnt    <= 0;
				rBitCnt     <= 0;
				rDataReg    <= (others => '0');
				rRxFfWrEn   <= '0';
				rRxFfWrData <= (others => '0');
	
			else
				-- Default assignment for pulse signal
				rRxFfWrEn <= '0';
				
				case rSerState is
					
					-- Wait for a START bit (falling edge)
					when stIdle =>
						if (rSerDataIn = '0') then -- Use synchronized signal [cite: 296]
							rSerState <= stStart;
							rBaudCnt  <= 0; -- Start counter
						else
							rSerState <= stIdle;
							rBaudCnt  <= 0;
						end if;
						
						-- Keep other registers [cite: 213]
						rBitCnt     <= rBitCnt;
						rDataReg    <= rDataReg;
						rRxFfWrData <= rRxFfWrData;

					-- Wait for half bit-time to sample middle of START bit
					when stStart =>
						if (rBaudCnt = cBaudHalfTick - 1) then
							if (rSerDataIn = '0') then -- Check if START bit is still low
								rSerState <= stData;
								rBitCnt   <= 0;
							else
								rSerState <= stIdle; -- False start, return to idle
								rBitCnt   <= rBitCnt;
							end if;
							rBaudCnt <= 0; -- Reset counter for next bit
						else
							rSerState <= stStart;
							rBaudCnt  <= rBaudCnt + 1;
							rBitCnt   <= rBitCnt;
						end if;
						
						-- Keep other registers
						rDataReg    <= rDataReg;
						rRxFfWrData <= rRxFfWrData;

					-- Wait for full bit-time, sample data bits
					when stData =>
						if (rBaudCnt = cBaudFullTick - 1) then
							rBaudCnt <= 0;
							-- Shift in LSB first data (D0, D1, ... D7)
							-- rDataReg = {D7, D6, ..., D1, D0}
							rDataReg <= rSerDataIn & rDataReg(7 downto 1);
							
							if (rBitCnt = 7) then -- Last data bit (D7) received
								rSerState <= stStop;
								rBitCnt   <= 0;
							else
								rSerState <= stData;
								rBitCnt   <= rBitCnt + 1;
							end if;
						else
							rBaudCnt  <= rBaudCnt + 1;
							rSerState <= stData;
							rBitCnt   <= rBitCnt;
							rDataReg  <= rDataReg;
						end if;
						
						-- Keep other registers
						rRxFfWrData <= rRxFfWrData;

					-- Wait for full bit-time to sample STOP bit
					when stStop =>
						if (rBaudCnt = cBaudFullTick - 1) then
							rSerState <= stIdle; -- Return to idle
							rBaudCnt  <= 0;
							
							-- Check for valid STOP bit ('1')
							if (rSerDataIn = '1') then
								-- Check if FIFO is not full 
								if (RxFfFull = '0') then
									rRxFfWrEn   <= '1'; -- Send 1-clock pulse 
									rRxFfWrData <= rDataReg;
								else
									-- FIFO is full, drop data
									rRxFfWrEn   <= '0';
									rRxFfWrData <= rRxFfWrData;
								end if;
							else
								-- Framing Error (STOP bit = '0'), drop data
								rRxFfWrEn   <= '0';
								rRxFfWrData <= rRxFfWrData;
							end if;
						else
							rBaudCnt    <= rBaudCnt + 1;
							rSerState   <= stStop;
							rRxFfWrEn   <= '0';
							rRxFfWrData <= rRxFfWrData;
						end if;
						
						-- Keep other registers
						rBitCnt  <= rBitCnt;
						rDataReg <= rDataReg;
						
				end case;
			end if;
		end if;
	end process u_RxLogic;
	
End Architecture rtl;