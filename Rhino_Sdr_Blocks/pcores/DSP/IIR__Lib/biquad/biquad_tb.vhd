-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
library RHINO_IIR_CORE_Lib;
USE RHINO_IIR_CORE_Lib.iir_filter_pkg.all;

ENTITY biquad_tb IS
END biquad_tb;

ARCHITECTURE behavior OF biquad_tb IS 

COMPONENT biquad is
generic(
	IN_WIDTH    : natural := 8;
	COEFF_WIDTH : natural := 8;
	b				: biquad_type;
	a				: biquad_type
);
port(
	clk,rst : in  std_logic;
	x 		  : in  std_logic_vector(7 downto 0);
	y 		  : out std_logic_vector(7 downto 0)
);
end COMPONENT biquad;

 SIGNAL clk,rst :  std_logic := '0';
 SIGNAL x,y :  std_logic_vector(7 downto 0) := (others => '0');
 constant clk_period : time := 10 ns;  

BEGIN

biquad_inst : biquad 
generic map(
	IN_WIDTH    => 8,
	COEFF_WIDTH => 8,
	b				=> (11,0,-11),
	a				=> (128,0,105)
)
port map(
	clk => clk,
	rst => rst,
	x 	 => x,
	y 	 => y
);

-- Clock process definitions
clk_process :process		
begin
	clk <= '0';
	wait for clk_period/2;
	clk <= '1';
	wait for clk_period/2;
end process;

--  Test Bench Statements
  tb : PROCESS
  BEGIN

	  wait for 100 ns; -- wait until global set/reset completes

	  -- Add user defined stimulus here
	  wait until falling_edge(clk);
	  x <= "01100100";
	  wait for clk_period*4;
	  x <= "00000000";

	  wait; -- will wait forever
  END PROCESS tb;
--  End Test Bench 

END;
