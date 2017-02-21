-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;
library IIR_Lib;
USE IIR_Lib.iir_pkg.all;

ENTITY order2_iir_tb IS
END order2_iir_tb;

ARCHITECTURE behavior OF order2_iir_tb IS 

COMPONENT order2_iir is
generic(
	IN_WIDTH    : natural := 8;
	COEFF_WIDTH : natural := 9;
	b				: sos_type(0 to 0);
	a				: sos_type(0 to 0);
	INDEX			: natural := 0
);
port(
	clk,rst : in  std_logic;
	x 		  : in  std_logic_vector(7 downto 0);
	y 		  : out std_logic_vector(7 downto 0)
);
end COMPONENT order2_iir;

 SIGNAL clk,rst :  std_logic := '0';
 SIGNAL x,y :  std_logic_vector(7 downto 0) := (others => '0');
 constant clk_period : time := 10 ns;  

BEGIN

order2_iir_inst : order2_iir 
generic map(
	IN_WIDTH    => 8,
	COEFF_WIDTH => 8,
	b				=> (11,0,-11),
	a				=> (128,0,105),
	INDEX			=> 0
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
	  wait until falling_edge(clk);
	  x <= "00000000";

	  wait; -- will wait forever
  END PROCESS tb;
--  End Test Bench 

END;
