----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:40:00 08/07/2014 
-- Design Name: 
-- Module Name:    orderN_iir - Behavioral 
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
Library IEEE;
Use IEEE.STD_LOGIC_1164.ALL;

Library  IIR_Lib;
Use IIR_Lib.iir_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity orderN_iir is
	generic(
		DIN_WIDTH   : natural := 9;
		DOUT_WIDTH  : natural := 9;
		COEFF_WIDTH : natural := 9;
		b				: sos_type;
		a				: sos_type;
		STAGES      : natural := 0
	);
	port(
		clk,rst : in  std_logic;
		din	  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
		dout	  : out std_logic_vector(DOUT_WIDTH - 1 downto 0)
	);
end orderN_iir;

architecture Behavioral of orderN_iir is

	COMPONENT order2_iir IS
	GENERIC(
		IN_WIDTH    : natural := 9;
		COEFF_WIDTH : natural := 9;
		b				: sos_type(0 to STAGES - 1);
		a				: sos_type(0 to STAGES - 1);
		INDEX			: natural := 0
	);
	PORT(
		clk,rst : in  std_logic;
		x 		  : in  std_logic_vector(IN_WIDTH - 1 downto 0);
		y 		  : out std_logic_vector(IN_WIDTH - 1 downto 0)
	);
	END COMPONENT order2_iir;
	
	type dout_type is array (0 to STAGES - 1) of std_logic_vector(DIN_WIDTH - 1 downto 0);
	signal yin   : dout_type := (others =>(others => '0'));
	signal yout  : dout_type := (others =>(others => '0'));
begin

	BiquadCascade : for i in 0 to STAGES - 1 generate
	begin
		-- first stage
		cascade_IIR2: if STAGES > 1 generate
		begin
			BiquadFirst: if i = 0 generate
			order2_iir_first : order2_iir 
			generic map(
				IN_WIDTH    => DIN_WIDTH,
				COEFF_WIDTH => COEFF_WIDTH,
				b	         => b,
		      a	         => a,
				INDEX			=> i
			)
			port map(
				clk => clk,
				rst => rst,
				x 	 => din,
				y 	 => yout(i)
			);
			end generate;
			
			BiquadN: if i > 0 and i < STAGES - 1 generate
			order2_iir_N : order2_iir 
			generic map(
				IN_WIDTH    => DIN_WIDTH,
				COEFF_WIDTH => COEFF_WIDTH,
				b	         => b,
		      a	         => a,
				INDEX			=> i
			)
			port map(
				clk => clk,
				rst => rst,
				x 	 => yout(i-1),
				y 	 => yout(i)
			);
			end generate;
			
			BiquadLast: if i = STAGES - 1 generate
			order2_iir_last : order2_iir 
			generic map(
				IN_WIDTH    => DIN_WIDTH,
				COEFF_WIDTH => COEFF_WIDTH,
				b	         => b,
		      a	         => a,
				INDEX			=> i
			)
			port map(
				clk => clk,
				rst => rst,
				x 	 => yout(i-1),
				y 	 => dout
			);
			end generate;
		end generate;
	end generate BiquadCascade;
end Behavioral;

