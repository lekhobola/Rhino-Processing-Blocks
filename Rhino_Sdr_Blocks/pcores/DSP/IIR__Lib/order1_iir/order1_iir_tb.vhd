-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

  ENTITY order1_iir_tb IS
  END order1_iir_tb;

  ARCHITECTURE behavior OF order1_iir_tb IS 

  -- Component Declaration
   COMPONENT order1_iir is
		generic(
			IN_WIDTH 	: natural; 
			OUT_WIDTH   : natural;
			COEFF_WIDTH : natural;
			COEFF			: integer
		);
		port(
			clk,rst : in  std_logic;
			x 		  : in  std_logic_vector(IN_WIDTH - 1 downto 0);
			y 		  : out std_logic_vector(OUT_WIDTH - 1 downto 0)
		);
	end COMPONENT order1_iir;

	 SIGNAL clk,rst :  std_logic;
	 SIGNAL x :  std_logic_vector(7 downto 0) := (others => '0');
	 signal y :  std_logic_vector(9 downto 0) := (others => '0');
	 CONSTANT clk_period : time := 10 ns;  
	
  BEGIN

  -- Component Instantiation
	order1_iir_inst : order1_iir 
	generic map(
		IN_WIDTH 	=> 8,
		OUT_WIDTH   => 10,
		COEFF_WIDTH => 8,
		COEFF			=> 120
	)
	port map(
		clk => clk,
		rst => rst,
		x 	=> x,
		y 	=> y
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
 END behavior;
