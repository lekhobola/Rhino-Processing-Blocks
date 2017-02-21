-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY interpolator_tb IS
END interpolator_tb;

ARCHITECTURE behavior OF interpolator_tb IS 

-- Component Declaration
		 component interpolator is
			generic(
				DIN_WIDTH	  			 : natural;
				NUMBER_OF_STAGES	 : natural; --N
				DIFFERENTIAL_DELAY : natural; --M
				SAMPLE_RATE_CHANGE : natural;  --R
				CLKIN_PERIOD_NS	 : real
			);
			port(
				CLK  : in  std_logic;
				RST  : in  std_logic;
				DIN  : in  std_logic_vector(DIN_WIDTH - 1 downto 0);
				RDY  : out std_logic;
				VLD  : out std_logic;
				DOUT : out std_logic_vector(DIN_WIDTH + (NUMBER_OF_STAGES * integer(log2(real(DIFFERENTIAL_DELAY * SAMPLE_RATE_CHANGE)))) - 1 downto 0)
			);
		end component;
		
		constant out_width : natural := 10;
		SIGNAL CLK,ND,RST,RDY,vld  :  std_logic := '0';
		SIGNAL DIN  :  std_logic_vector(7 downto 0) := (others => '0');
		SIGNAL DOUT :  std_logic_vector(out_width - 1 downto 0); -- out_width : N*log2(RM)+DIN_WIDTH
		 
		constant clk_period : time := 20 ns;
BEGIN


-- Component Instantiation
		dec_inst : interpolator 
			generic map(
				DIN_WIDTH	  			 => 8,
				NUMBER_OF_STAGES	 => 2,
				DIFFERENTIAL_DELAY => 1,
				SAMPLE_RATE_CHANGE => 2,
				CLKIN_PERIOD_NS => 20.0
			)
			port map(
				CLK => CLK,
				RST => RST,
				DIN => DIN,
				RDY => RDY,
				VLD => VLD,
				DOUT => DOUT
			);

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

	  --RST <= '1';
	  wait until rising_edge(rdy);
	  --RST <= '0';

	  -- Add user defined stimulus here
	  wait until falling_edge(clk);
	  din <= "00001010";
	  wait until falling_edge(clk);
	  din <= "00010100";
	  wait until falling_edge(clk);
	  din <= "00011110";
	  wait until falling_edge(clk);
	  din <= "00101000";
	  wait until falling_edge(clk);
	  din <= "00110010";
	  wait until falling_edge(clk);
	  din <= "00101000";
	  wait until falling_edge(clk);
	  din <= "00011110";
	  wait until falling_edge(clk);
	  din <= "00010100";
	  wait until falling_edge(clk);
	  din <= "00001010";
	  wait until falling_edge(clk);
	  din <= "00000000";
	  wait; -- will wait forever
  END PROCESS tb;
--  End Test Bench 

END;
