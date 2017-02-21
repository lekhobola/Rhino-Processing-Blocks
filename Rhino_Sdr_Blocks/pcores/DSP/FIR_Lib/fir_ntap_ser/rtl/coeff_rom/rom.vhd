--********************************************************************************
--* Company:        University of Cape Town									   
--* Engineer:       Lekhobola Joachim Tsoeunyane, lekhobola@gmail.com		       
--********************************************************************************
--* Create Date:    02-Jul-2014 13:44:11  				 										   
--* Design Name:    Pipelined R2^2 DIF-SDF FFT								       
--* Module Name:    fft8_tf_rom_s0.vhd										   
--* Project Name:   RHINO SDR Processing Blocks								   
--* Target Devices: Xilinx - SPARTAN-6											   
--********************************************************************************
--* Dependencies: none															   
--********************************************************************************
LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
--use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_SIGNED.all;
Use IEEE.MATH_REAL.ALL;

--use work.fir_filter_pkg.all;
Library RHINO_FIR_CORE_Lib;
Use RHINO_FIR_CORE_Lib.fir_pkg.all;

--********************************************************************************
--* This module implements the stage-0 of twiddle factor ROM for a 8-point      
--* pipelined R2^2 DIF-SDF FFT. Each value is a complex number{imaginary,complex} 
--* ******************************************************************************
--* params:																	   
--*        addr_w - rom address bit width									       
--*        data_w - output data bit width										   
--* ports:																		   
--* 			[in]  addr	- Twidde factor ROM address to read					   
--* 			[out] doutr - Twiddle factor read from rom addr - real value	   
--* 			[out] douti - Twidder factor read from rom addr - imaginary value  
--********************************************************************************
--* Notes: Do not modify this file as it is auto-generated using matlab script    
--********************************************************************************
entity rom is
	generic(
		ADDR_WIDTH  : natural := 3;
		COEFF_WIDTH : natural := 16;
		COEFFS		: coeff_type
	);
    port (
        addr  : in  std_logic_vector (ADDR_WIDTH -  1 downto 0);
        dout  : out std_logic_vector (COEFF_WIDTH - 1 downto 0)
 	);
end rom;

architecture Behavioral of rom is
begin
	dout <= conv_std_logic_vector(COEFFS(conv_integer(unsigned(addr))),COEFF_WIDTH);
end Behavioral;
