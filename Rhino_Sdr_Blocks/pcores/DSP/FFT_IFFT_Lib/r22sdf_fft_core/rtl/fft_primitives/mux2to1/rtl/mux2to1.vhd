--********************************************************************************
--* Company:        University of Cape Town									   
--* Engineer:       Lekhobola Joachim Tsoeunyane, lekhobola@gmail.com		       
--********************************************************************************
--* Create Date:    21-June-2014 23:57:43 				 										   
--* Design Name:    Pipelined R2^2 DIF-SDF FFT								       
--* Module Name:    mux2to1.vhd										   
--* Project Name:   RHINO SDR Processing Blocks								   
--* Target Devices: Xilinx - SPARTAN-6											   
--********************************************************************************
--* Dependencies: none
--********************************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--********************************************************************************
--* This module implements a 2 to 1 multiplexer. This is used by butterfliers and   
--* controlled by a control counter to swithch between operating modes. 
--********************************************************************************
--* params:																	   
--*        mux2to1_data_w - Bit width of the input lines									   
--* ports:																		   
--* 			[in]  sel - Multiplexer control line, 0 selects line-1 and 1 selects line-2					   
--* 			[in]  x1  - Input data in the first line
--* 			[in]  x2  - Input data in the second line
--*         [out] y   - Output data
--********************************************************************************
--* Notes: none   
--********************************************************************************
entity mux2to1 is
	generic(
		mux2to1_data_w : integer
	);
	port(
		sel : in  std_logic;
		x1  : in  std_logic_vector (mux2to1_data_w - 1 downto 0);
		x2  : in  std_logic_vector (mux2to1_data_w - 1 downto 0);
		y	 : out std_logic_vector (mux2to1_data_w - 1 downto 0)
	);
end mux2to1;

architecture Behavioral of mux2to1 is
begin
	with sel select
		y <= x1 when '0',
			  x2 when '1';
end Behavioral;

