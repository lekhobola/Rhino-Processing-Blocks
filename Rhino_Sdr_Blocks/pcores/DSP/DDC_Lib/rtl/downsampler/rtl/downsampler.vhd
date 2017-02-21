----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:19:50 06/30/2015 
-- Design Name: 
-- Module Name:    downsampler - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Use IEEE.MATH_REAL.ALL;

Library FIR_Lib;
Use FIR_Lib.fir_pkg.all;
Use FIR_Lib.fircomponents.all;

Library CIC_Lib;
Use CIC_Lib.ciccomponents.all;


entity downsampler is
	generic(
		DIN_WIDTH 			 : natural;
		DOUT_WIDTH 			 : natural;
		-- CIC 1 configurations
		NUMBER_OF_STAGES 	  : natural;
		DIFFERENTIAL_DELAY  : natural;
		SAMPLE_RATE_CHANGE  : natural;
		-- Compensating FIR configuratons
		NUMBER_OF_TAPS   	  : natural;  													
		FIR_LATENCY         : natural;  
      COEFF_WIDTH  	     : natural;
		COEFFS		        : coeff_type
	);
	port(
		CLK  : in  std_logic;
		RST  : in  std_logic;
		EN	  : in  std_logic;
		DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		VLD  : out std_logic;
		DOUT : out std_logic_vector(DOUT_WIDTH - 1 downto 0)
	);
end downsampler;

architecture Behavioral of downsampler is
	constant CIC_DOUT_WIDTH : natural := DIN_WIDTH + (NUMBER_OF_STAGES * integer(ceil(log2(real(DIFFERENTIAL_DELAY * SAMPLE_RATE_CHANGE)))));
	--constant FIR_WIDTH      : natural := natural(ceil(log2(real((2 ** (DIN_WIDTH-1)) * (2 ** (COEFF_WIDTH-1)) * NUMBER_OF_TAPS)))) + 1;	
	constant FIR_WIDTH      : natural := DIN_WIDTH;
	
	signal cic_dout      : std_logic_vector(CIC_DOUT_WIDTH - 1 downto 0)  := (others => '0');
	signal fir_dout      : std_logic_vector(FIR_WIDTH - 1 downto 0)        := (others => '0');
	signal cic_vld		   : std_logic;

begin

	ECIMATOR : CIC 
	GENERIC MAP(
		DIN_WIDTH	  		 => DIN_WIDTH,
		NUMBER_OF_STAGES	 => NUMBER_OF_STAGES,
		DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY,
		SAMPLE_RATE_CHANGE => SAMPLE_RATE_CHANGE,
		FILTER_TYPE        => '0',
		CLKIN_PERIOD_NS    => 0.0
	)
	PORT MAP(
		CLK  => clk,
		RST  => rst,
		EN   => EN,
		DIN  => din,
		VLD  => cic_vld,
		DOUT => cic_dout
	);
	
	-- vld <= cic_vld;
	
	CFIR : fir_par
	generic map(
		DIN_WIDTH		  => DIN_WIDTH,
		DOUT_WIDTH  	  => FIR_WIDTH,
		COEFF_WIDTH 	  => COEFF_WIDTH,
		LATENCY			  => FIR_LATENCY,
		NUMBER_OF_TAPS	  => NUMBER_OF_TAPS,
		coeffs			  => COEFFS
	)
	port map(
		clk   => clk,
		rst   => rst,							  
		en    => cic_vld,
		loadc => '0',
		vld   => vld,
		coeff => (others => '0'),
		din   => cic_dout(CIC_DOUT_WIDTH - 1 downto CIC_DOUT_WIDTH - DIN_WIDTH),
		dout  => fir_dout
	);	
	dout <= fir_dout(FIR_WIDTH - 1 downto  FIR_WIDTH - DOUT_WIDTH);
	--dout <= cic_dout(CIC_DOUT_WIDTH - 1 downto  CIC_DOUT_WIDTH - DOUT_WIDTH);
end Behavioral;

