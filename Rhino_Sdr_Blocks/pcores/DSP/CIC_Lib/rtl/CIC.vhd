----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:07:24 08/13/2014 
-- Design Name: 
-- Module Name:    cir_filter - Behavioral 
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
USE IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CIC is
	generic(
		DIN_WIDTH	  			 : natural;
		NUMBER_OF_STAGES	 : natural;
		DIFFERENTIAL_DELAY : natural;
		SAMPLE_RATE_CHANGE : natural;
		FILTER_TYPE        : std_logic;
      CLKIN_PERIOD_NS    : real		
	);
	port(
	   CLK  : in  std_logic;
		RST  : in  std_logic;
		EN   : in std_logic;
		DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		VLD  : out std_logic;
		DOUT : out std_logic_vector(DIN_WIDTH + (NUMBER_OF_STAGES * integer(ceil(log2(real(DIFFERENTIAL_DELAY * SAMPLE_RATE_CHANGE))))) - 1 downto 0) -- out_width : N*log2(RM)+DIN_WIDTH
	);
end CIC;

architecture Behavioral of CIC is

	COMPONENT decimator is
		GENERIC(
			DIN_WIDTH	  			 : natural;
			NUMBER_OF_STAGES	 : natural; --N
			DIFFERENTIAL_DELAY : natural; --M
			SAMPLE_RATE_CHANGE : natural;  --R
			CLKIN_PERIOD_NS    : real
		);
		PORT(
			CLK  : in  std_logic;
			RST  : in  std_logic;
			EN   : in std_logic;
			DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
			VLD  : out std_logic;
			DOUT : out std_logic_vector(DIN_WIDTH + (NUMBER_OF_STAGES * integer(ceil(log2(real(DIFFERENTIAL_DELAY * SAMPLE_RATE_CHANGE))))) - 1 downto 0) -- out_width : N*log2(RM)+DIN_WIDTH
		);
	END COMPONENT;
	
	COMPONENT interpolator IS
		GENERIC(
			DIN_WIDTH	  		 : natural;
			NUMBER_OF_STAGES	 : natural; --N
			DIFFERENTIAL_DELAY : natural; --M
			SAMPLE_RATE_CHANGE : natural;  --R
			CLKIN_PERIOD_NS    : real
		);
		PORT(
			CLK  : in  std_logic;
			RST  : in  std_logic;
			DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
			RDY  : out std_logic;
			VLD  : out std_logic;
			DOUT : out std_logic_vector(DIN_WIDTH + (NUMBER_OF_STAGES * integer(ceil(log2(real(DIFFERENTIAL_DELAY * SAMPLE_RATE_CHANGE))))) - 1 downto 0)
		);
	END COMPONENT;
	
begin
	DecimatorGen : if FILTER_TYPE = '0' generate
	decimator_inst : decimator
		GENERIC MAP(
			DIN_WIDTH	  		 => DIN_WIDTH,
			NUMBER_OF_STAGES	 => NUMBER_OF_STAGES,
			DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY,
			SAMPLE_RATE_CHANGE => SAMPLE_RATE_CHANGE,
			CLKIN_PERIOD_NS    => CLKIN_PERIOD_NS
		)
		PORT MAP(
			CLK  => CLK,
			RST  => RST,
			EN   => EN,
			DIN  => DIN,
		   VLD  => VLD,
			DOUT => DOUT
		);
	end generate;
	
	InterpolatorGen : if FILTER_TYPE = '1' generate
	interpolator_inst : interpolator
		GENERIC MAP(
			DIN_WIDTH	  			 => DIN_WIDTH,
			NUMBER_OF_STAGES	 => NUMBER_OF_STAGES,
			DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY,
			SAMPLE_RATE_CHANGE => SAMPLE_RATE_CHANGE,
			CLKIN_PERIOD_NS    => CLKIN_PERIOD_NS
		)
		PORT MAP(
			CLK  => CLK,
			RST  => RST,
			DIN  => DIN,
			RDY  => open,
			VLD  => VLD,
			DOUT => DOUT
		);
	end generate;
end Behavioral;

