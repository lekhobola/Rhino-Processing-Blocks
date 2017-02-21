--********************************************************************************
--* Company:        University of Cape Town									   
--* Engineer:       Lekhobola Joachim Tsoeunyane, lekhobola@gmail.com		       
--********************************************************************************
--* Create Date:    21-June-2014 04:26:41 				 										   
--* Design Name:    Pipelined R2^2 DIF-SDF FFT								       
--* Module Name:    counter.vhd										   
--* Project Name:   RHINO SDR Processing Blocks								   
--* Target Devices: Xilinx - SPARTAN-6											   
--********************************************************************************
--* Dependencies: none
--********************************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--********************************************************************************
--* This module implements a counter which acts a control logic for the FFT. It is
--* used to switch the operating modes of the butterflies and also retrieve 
--* twiddle factor from twiddle factor ROMs and directs this to Stage-Multipliers.
--********************************************************************************
--* params:																	   
--*        counter_data_w - Counter bit width = log2(N), N=FFT length							   
--* ports:																		   
--* 			[in]  clk - System clock - active on the rising edge					   
--* 			[in]  rst - Active high asynchronous reset line
--* 			[out]  c  - Butterfly and ROM control counter 
--********************************************************************************
--* Notes: none  
--********************************************************************************
entity counter is
	generic(
		counter_data_w : natural
	);
	port(
		clk,rst,en : in std_logic;
		c		  	  : out std_logic_vector(counter_data_w - 1 downto 0)
	);
end counter;

architecture Behavioral of counter is
begin
	process(clk,rst)
		variable count : std_logic_vector(counter_data_w - 1 downto 0) := (others => '0');
	begin
		if(rst = '1') then
			count := (others => '0');
		elsif(rising_edge(clk)) then
			if(en ='1') then
				count := count + 1;
			end if;
		end if;
		c <= count;
	end process;
end Behavioral;

