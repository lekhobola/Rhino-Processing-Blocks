--********************************************************************************
--* Company:        University of Cape Town									   
--* Engineer:       Lekhobola Joachim Tsoeunyane, lekhobola@gmail.com		       
--********************************************************************************
--* Create Date:    05-Jul-2014 20:18:53  				 										   
--* Design Name:    Pipelined R2^2 DIF-SDF FFT								       
--* Module Name:    fft128_tf_rom_s1.vhd										   
--* Project Name:   RHINO SDR Processing Blocks								   
--* Target Devices: Xilinx - SPARTAN-6											   
--********************************************************************************
--* Dependencies: none															   
--********************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--********************************************************************************
--* This module implements the stage-1 of twiddle factor ROM for a 128-point      
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
entity fft128_tf_rom_s1 is
	generic(
		addr_w : natural := 5;
		data_w : natural := 16
	);
    port (
        addr  : in  std_logic_vector (addr_w - 1 downto 0);
        doutr : out std_logic_vector (data_w - 1 downto 0);
        douti : out  std_logic_vector(data_w - 1 downto 0)
 	);
end fft128_tf_rom_s1;

architecture Behavioral of fft128_tf_rom_s1 is
	type complex is array(0 to 1) of std_logic_vector(data_w - 1 downto 0);
	type rom_type is array(0 to (2 ** addr_w) - 1) of complex;

	constant rom : rom_type := (
								 ("0100000000000000","0000000000000000"),
								 ("0011101100100001","1110011110000010"),
								 ("0010110101000001","1101001010111111"),
								 ("0001100001111110","1100010011011111"),
								 ("0000000000000000","1100000000000000"),
								 ("1110011110000010","1100010011011111"),
								 ("1101001010111111","1101001010111111"),
								 ("1100010011011111","1110011110000010"),
								 ("0100000000000000","0000000000000000"),
								 ("0011111011000101","1111001110000100"),
								 ("0011101100100001","1110011110000010"),
								 ("0011010100110111","1101110001110010"),
								 ("0010110101000001","1101001010111111"),
								 ("0010001110001110","1100101011001001"),
								 ("0001100001111110","1100010011011111"),
								 ("0000110001111100","1100000100111011"),
								 ("0100000000000000","0000000000000000"),
								 ("0011010100110111","1101110001110010"),
								 ("0001100001111110","1100010011011111"),
								 ("1111001110000100","1100000100111011"),
								 ("1101001010111111","1101001010111111"),
								 ("1100000100111011","1111001110000100"),
								 ("1100010011011111","0001100001111110"),
								 ("1101110001110010","0011010100110111"),
								 ("0100000000000000","0000000000000000"),
								 ("0100000000000000","0000000000000000"),
								 ("0100000000000000","0000000000000000"),
								 ("0100000000000000","0000000000000000"),
								 ("0100000000000000","0000000000000000"),
								 ("0100000000000000","0000000000000000"),
								 ("0100000000000000","0000000000000000"),
								 ("0100000000000000","0000000000000000")
							   );
begin
	doutr <= std_logic_vector(rom(conv_integer(addr))(0));
	douti <= std_logic_vector(rom(conv_integer(addr))(1));
end Behavioral;
