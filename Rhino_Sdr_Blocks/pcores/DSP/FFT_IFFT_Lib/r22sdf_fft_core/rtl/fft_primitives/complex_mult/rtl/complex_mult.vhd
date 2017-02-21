--********************************************************************************
--* Company:        University of Cape Town									   
--* Engineer:       Lekhobola Joachim Tsoeunyane, lekhobola@gmail.com		       
--********************************************************************************
--* Create Date:    21-June-2014 03:56:39  				 										   
--* Design Name:    Pipelined R2^2 DIF-SDF FFT								       
--* Module Name:    complex_mult.vhd										   
--* Project Name:   RHINO SDR Processing Blocks								   
--* Target Devices: Xilinx - SPARTAN-6											   
--********************************************************************************
--* Dependencies: none
--********************************************************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
--********************************************************************************
--* This implements a Radix 2^2 single-path delay feedback FFT twidle factor
--* Multiplier
--********************************************************************************
--* params:																	   
--*        dataa_w - Input A bit width									       
--*        datab_w - Input B bit width										   
--* ports:																		   
--* 			[in]  ar - Real-part of input A					   
--* 			[in]  ai - Imaginary-part of in A
--* 			[in]  br - Real-par of input B 
--*         [in]  bi - Imaginary-part of input B
--*         [out] cr - Real-part of output
--*			[out] ci - Imaginary-part of output
--********************************************************************************
--* Notes: Input A is fed from Stage Ouput and Input B is twiddle factor from ROM.
--********************************************************************************
entity complex_mult is
	generic(
		dataa_w	: natural := 9;
		datab_w	: natural := 9
	);
	port(
		ar : in  std_logic_vector(dataa_w - 1 downto 0);
		ai : in  std_logic_vector(dataa_w - 1 downto 0);
		br : in  std_logic_vector(datab_w - 1 downto 0);
		bi : in  std_logic_vector(datab_w - 1 downto 0);
		cr : out std_logic_vector(dataa_w + datab_w - 1 downto 0);
		ci : out std_logic_vector(dataa_w + datab_w - 1 downto 0)
	);
end complex_mult;

architecture Behavioral of complex_mult is
	signal ar_br_mult : std_logic_vector(dataa_w + datab_w - 1 downto 0) := (others => '0');
	signal ai_bi_mult : std_logic_vector(dataa_w + datab_w - 1 downto 0) := (others => '0');
	signal ai_br_mult : std_logic_vector(dataa_w + datab_w - 1 downto 0) := (others => '0');
	signal ar_bi_mult : std_logic_vector(dataa_w + datab_w - 1 downto 0) := (others => '0');
begin
	ar_br_mult <= ar * br;
	ai_bi_mult <= ai * bi;
	ai_br_mult <= ai * br;
	ar_bi_mult <= ar * bi;
	
	cr <= ar_br_mult - ai_bi_mult;
	ci <= ai_br_mult + ar_bi_mult;
end Behavioral;

